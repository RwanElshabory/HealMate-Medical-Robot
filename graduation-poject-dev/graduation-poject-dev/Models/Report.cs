namespace MedicalRobot.API.Models
{
    public class Report
    {
        public int ReportId { get; set; }
        public int PatientId { get; set; }
        public int DoctorId { get; set; }

        public string Title { get; set; } = default!;
        public string Notes { get; set; } = default!;

        public string? ImageUrl { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // العلاقات
        public Patient? Patient { get; set; }
        public User? Doctor { get; set; }
    
}
}
