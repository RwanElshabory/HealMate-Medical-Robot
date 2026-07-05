namespace MedicalRobot.API.DTOs
{
    public class SendMessageDto
    {
        public int SenderId { get; set; }
        public int ReceiverId { get; set; }
        public string Type { get; set; } = "text";
        public string ContentUrl { get; set; }
    }
}
