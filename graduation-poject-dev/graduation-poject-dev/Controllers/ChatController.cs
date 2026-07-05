using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.DTOs;
using MedicalRobot.API.Models;
using MedicalRobot.API.Common;
using MedicalRobot.API.Hubs;
using MedicalRobot.API.Services;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/chat")]
    [Authorize(Roles = "Doctor,Nurse,Patient")]
    public class ChatController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly IHubContext<ChatHub> _hub;
        private readonly INotificationService _notificationService;

        public ChatController(AppDbContext db, IHubContext<ChatHub> hub, INotificationService notificationService)
        {
            _db = db;
            _hub = hub;
            _notificationService = notificationService;
        }

        [HttpGet("history/{userA:int}/{userB:int}")]
        public async Task<IActionResult> GetHistory(
            int userA,
            int userB,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 50)
        {
            var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var currentUserRole = User.FindFirst(ClaimTypes.Role)?.Value ?? "";

            if (currentUserRole == "Patient" && currentUserId != userA && currentUserId != userB)
                return Forbid();

            var query = _db.ChatMessages
                .Where(m =>
                    (m.SenderId == userA && m.ReceiverId == userB) ||
                    (m.SenderId == userB && m.ReceiverId == userA))
                .OrderByDescending(m => m.SentAt);

            var total = await query.CountAsync();

            var messages = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .OrderBy(m => m.SentAt)
                .Select(m => new ChatMessageDto
                {
                    SenderId = m.SenderId,
                    ReceiverId = m.ReceiverId,
                    Type = m.Type.ToString(),
                    Content = m.ContentPath,
                    SentAt = m.SentAt
                })
                .ToListAsync();

            return Ok(new ApiResponse<object>(new
            {
                total,
                page,
                pageSize,
                messages
            }));
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] SendMessageDto dto)
        {
            if (!Enum.TryParse<MessageType>(dto.Type, true, out var type))
                return BadRequest(new ApiResponse<string>("Invalid message type"));

            var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var currentUserRole = User.FindFirst(ClaimTypes.Role)?.Value ?? "";

            if (currentUserRole == "Patient")
            {
                var patient = await _db.Patients.FindAsync(currentUserId);
                if (patient == null)
                    return NotFound(new ApiResponse<string>("Patient not found"));
                if (dto.ReceiverId != patient.DoctorId && dto.ReceiverId != patient.NurseId)
                    return Forbid();
            }

            var msg = new ChatMessage
            {
                SenderId = currentUserId,
                ReceiverId = dto.ReceiverId,
                Type = type,
                ContentPath = dto.ContentUrl,
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            _db.ChatMessages.Add(msg);
            await _db.SaveChangesAsync();

            await _hub.Clients.User(dto.ReceiverId.ToString())
                .SendAsync("ReceiveMessage", msg);

            var sender = await _db.Users.FindAsync(currentUserId);
            var notificationTitle = sender?.Name ?? "New Message";
            var notificationBody = msg.Type == MessageType.Text ? msg.ContentPath : $"Sent a {msg.Type}";
            var notificationData = new
            {
                messageId = msg.MessageId,
                senderId = msg.SenderId,
                receiverId = msg.ReceiverId,
                type = msg.Type.ToString()
            };

            await _notificationService.SendNotificationAsync(
                dto.ReceiverId,
                notificationTitle,
                notificationBody,
                notificationData
            );

            return Ok(new ApiResponse<object>(new
            {
                msg.MessageId,
                msg.SenderId,
                msg.ReceiverId,
                Type = msg.Type.ToString(),
                msg.ContentPath,
                msg.SentAt,
                msg.IsRead
            }, "Message saved successfully"));
        }

        [HttpGet("{userId:int}")]
        public async Task<IActionResult> GetUserChat(int userId)
        {
            var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");
            var currentUserRole = User.FindFirst(ClaimTypes.Role)?.Value ?? "";

            if (currentUserRole == "Patient" && currentUserId != userId)
                return Forbid();

            var messages = await _db.ChatMessages
                .Where(m => m.SenderId == userId || m.ReceiverId == userId)
                .OrderBy(m => m.SentAt)
                .Select(m => new ChatMessageDto
                {
                    SenderId = m.SenderId,
                    ReceiverId = m.ReceiverId,
                    Type = m.Type.ToString(),
                    Content = m.ContentPath,
                    SentAt = m.SentAt
                })
                .ToListAsync();

            return Ok(new ApiResponse<object>(messages, "User chat retrieved successfully"));
        }

        [HttpPost("mark-as-read")]
        public async Task<IActionResult> MarkAsRead([FromBody] int[] messageIds)
        {
            var currentUserId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "0");

            var messages = await _db.ChatMessages
                .Where(m => messageIds.Contains(m.MessageId))
                .ToListAsync();

            if (!messages.Any())
                return NotFound(new ApiResponse<string>("No messages found"));

            var unauthorized = messages.Where(m => m.ReceiverId != currentUserId).ToList();
            if (unauthorized.Any())
                return Forbid();

            messages.ForEach(m => m.IsRead = true);
            await _db.SaveChangesAsync();

            return Ok(new ApiResponse<object>(null, "Messages marked as read"));
        }
    }
}
