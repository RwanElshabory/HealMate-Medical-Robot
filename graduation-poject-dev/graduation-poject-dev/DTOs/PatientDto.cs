namespace MedicalRobot.API.DTOs
{
    public class PatientDto
    {
        public int PatientId { get; set; }
        public string FullName { get; set; } = default!;
        public int? Age { get; set; }
        public string? Gender { get; set; }
        public string? MedicalHistory { get; set; }
        public string? RoomNumber { get; set; }
    }
}
