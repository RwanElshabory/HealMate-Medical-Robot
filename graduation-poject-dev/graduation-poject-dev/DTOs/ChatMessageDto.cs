namespace MedicalRobot.API.DTOs
{
    public class ChatMessageDto
    {
        public int SenderId { get; set; }
        public int ReceiverId { get; set; }
        public string Type { get; set; } = "text"; // text | image | voice
        public string Content { get; set; } = default!;
        public DateTime SentAt { get; set; } = DateTime.UtcNow;

    }
}