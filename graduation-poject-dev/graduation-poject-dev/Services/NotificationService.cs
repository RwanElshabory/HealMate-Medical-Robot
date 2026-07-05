using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.Models;
using System.Text;
using System.Text.Json;

namespace MedicalRobot.API.Services
{
    public class NotificationService : INotificationService
    {
        private readonly AppDbContext _db;
        private readonly IConfiguration _config;
        private readonly HttpClient _httpClient;

        public NotificationService(AppDbContext db, IConfiguration config)
        {
            _db = db;
            _config = config;
            _httpClient = new HttpClient();
        }

        public async Task SendNotificationAsync(int receiverId, string title, string body, object? data = null)
        {
            var receiver = await _db.Users.FirstOrDefaultAsync(u => u.UserId == receiverId);
            if (receiver == null || string.IsNullOrEmpty(receiver.FcmToken))
                return;

            var fcmKey = _config["Firebase:ServerKey"];
            var fcmUrl = _config["Firebase:ApiUrl"];

            if (string.IsNullOrEmpty(fcmKey) || string.IsNullOrEmpty(fcmUrl))
                return;

            var payload = new
            {
                to = receiver.FcmToken,
                notification = new
                {
                    title = title,
                    body = body,
                    sound = "default",
                    badge = "1"
                },
                data = data ?? new { },
                priority = "high"
            };

            var json = JsonSerializer.Serialize(payload);
            var request = new HttpRequestMessage(HttpMethod.Post, fcmUrl)
            {
                Content = new StringContent(json, Encoding.UTF8, "application/json")
            };
            request.Headers.Add("Authorization", $"key={fcmKey}");
            request.Headers.Add("Sender", $"id={_config["Firebase:SenderId"]}");

            await _httpClient.SendAsync(request);
        }

        public async Task RegisterDeviceTokenAsync(int userId, string fcmToken)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user != null)
            {
                user.FcmToken = fcmToken;
                await _db.SaveChangesAsync();
            }
        }
    }
}
