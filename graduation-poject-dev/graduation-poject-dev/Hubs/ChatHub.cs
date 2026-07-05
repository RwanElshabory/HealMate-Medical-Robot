using Microsoft.AspNetCore.SignalR;
using MedicalRobot.API.Data;
using MedicalRobot.API.Models;
using MedicalRobot.API.Services;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace MedicalRobot.API.Hubs
{
    [Authorize]
    public class ChatHub : Hub
    {
        private readonly AppDbContext _db;
        private readonly INotificationService _notificationService;

        public ChatHub(AppDbContext db, INotificationService notificationService)
        {
            _db = db;
            _notificationService = notificationService;
        }

        private int GetCurrentUserId()
        {
            var claim = Context.User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null) throw new System.Exception("User ID not found");
            return int.Parse(claim.Value);
        }

        private string GetCurrentUserRole()
        {
            return Context.User.FindFirst(ClaimTypes.Role)?.Value ?? "";
        }

        public async Task JoinRoom(int userA, int userB)
        {
            var currentUserId = GetCurrentUserId();
            var currentUserRole = GetCurrentUserRole();

            if (currentUserId != userA && currentUserId != userB)
                throw new HubException("You are not allowed to join this room");

            if (currentUserRole == "Patient")
            {
                var patient = await _db.Patients.FindAsync(currentUserId);
                if (patient == null) throw new HubException("Patient not found");
                var otherUserId = currentUserId == userA ? userB : userA;
                if (otherUserId != patient.DoctorId && otherUserId != patient.NurseId)
                    throw new HubException("Patients can only chat with assigned Doctor/Nurse");
            }

            var room = GetRoom(userA, userB);
            await Groups.AddToGroupAsync(Context.ConnectionId, room);
        }

        public async Task SendMessage(int receiverId, string type, string content)
        {
            var senderId = GetCurrentUserId();
            var currentUserRole = GetCurrentUserRole();

            if (!System.Enum.TryParse<MessageType>(type, true, out var msgType))
                throw new HubException("Invalid message type");

            if (currentUserRole == "Patient")
            {
                var patient = await _db.Patients.FindAsync(senderId);
                if (patient == null) throw new HubException("Patient not found");
                if (receiverId != patient.DoctorId && receiverId != patient.NurseId)
                    throw new HubException("Patients can only send messages to assigned Doctor/Nurse");
            }

            var msg = new ChatMessage
            {
                SenderId = senderId,
                ReceiverId = receiverId,
                Type = msgType,
                ContentPath = content,
                SentAt = DateTime.UtcNow,
                IsRead = false
            };

            _db.ChatMessages.Add(msg);
            await _db.SaveChangesAsync();

            var room = GetRoom(senderId, receiverId);
            await Clients.Group(room).SendAsync("ReceiveMessage", msg);

            var sender = await _db.Users.FindAsync(senderId);
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
                receiverId,
                notificationTitle,
                notificationBody,
                notificationData
            );
        }

        public async Task MarkMessagesAsRead(int[] messageIds)
        {
            var currentUserId = GetCurrentUserId();
            var messages = await _db.ChatMessages
                .Where(m => messageIds.Contains(m.MessageId))
                .ToListAsync();

            var unauthorized = messages.Where(m => m.ReceiverId != currentUserId).ToList();
            if (unauthorized.Any())
                throw new HubException("You can only mark your own received messages as read");

            messages.ForEach(m => m.IsRead = true);
            await _db.SaveChangesAsync();

            foreach (var msg in messages)
            {
                var room = GetRoom(msg.SenderId, msg.ReceiverId);
                await Clients.Group(room).SendAsync("MessageRead", new
                {
                    MessageId = msg.MessageId,
                    ReceiverId = msg.ReceiverId
                });
            }
        }

        private string GetRoom(int a, int b) => a < b ? $"room_{a}_{b}" : $"room_{b}_{a}";
    }
}
