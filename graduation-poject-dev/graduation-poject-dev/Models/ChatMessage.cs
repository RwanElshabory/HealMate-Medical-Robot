using MedicalRobot.API.Models;

public class ChatMessage
{
    public int MessageId { get; set; }
    public int SenderId { get; set; }
    public int ReceiverId { get; set; }
    public string Type { get; set; } = "text"; // text | image | voice
    public string ContentPath { get; set; } = default!;
    public DateTime SentAt { get; set; } = DateTime.UtcNow;

    // ✅ جديد
    public bool IsRead { get; set; } = false;

    // علاقات (optional)
    public User? Sender { get; set; }
    public User? Receiver { get; set; }
}
