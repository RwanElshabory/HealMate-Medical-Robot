namespace MedicalRobot.API.DTOs
{
    public class CreateReportDto
    {
        public int PatientId { get; set; }
        public string Title { get; set; } = default!;
        public string Notes { get; set; } = default!;
        public IFormFile? Image { get; set; }
    }
}
