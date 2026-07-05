namespace MedicalRobot.API.Models
{
    public class PatientDto
    {
        public int PatientId { get; set; }
        public string FullName { get; set; } = "";
        public int Age { get; set; }
        public string Gender { get; set; } = "";
        public string? MedicalHistory { get; set; }
        public string? RoomNumber { get; set; }
    }
}
