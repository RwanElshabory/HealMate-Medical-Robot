using System.ComponentModel.DataAnnotations.Schema;

namespace MedicalRobot.API.Models
{
    public class VitalSign
    {
        public int Id { get; set; }
        public int PatientId { get; set; }
        public string? BloodPressure { get; set; }
        public string? HeartRate { get; set; }
        public string? Temperature { get; set; }
        public string? RespiratoryRate { get; set; }
        public DateTime RecordedAt { get; set; }

        [ForeignKey("PatientId")]
        public Patient? Patient { get; set; }
    }
}
