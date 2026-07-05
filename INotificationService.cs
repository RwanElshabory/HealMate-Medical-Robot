using MedicalRobot.API.Models;

namespace MedicalRobot.API.Services
{
    public interface INotificationService
    {
        Task SendNotificationAsync(int receiverId, string title, string body, object? data = null);
        Task RegisterDeviceTokenAsync(int userId, string fcmToken);
    }
}
