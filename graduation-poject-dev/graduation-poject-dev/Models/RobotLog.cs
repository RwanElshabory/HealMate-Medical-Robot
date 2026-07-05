namespace MedicalRobot.API.Models
{
    public class RobotLog
    {
        public int LogId { get; set; }   // ✅ Primary Key
        public int DoctorId { get; set; }
        public int? PatientId { get; set; }
        public string Action { get; set; }
        public string Parameters { get; set; }
        public string Status { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
