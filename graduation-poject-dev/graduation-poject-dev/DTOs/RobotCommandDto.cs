namespace MedicalRobot.API.DTOs
{
    public class RobotCommandDto
    {

        public int DoctorId { get; set; }       // who sent
        public int? PatientId { get; set; }     // optional context
        public string Command { get; set; }     // e.g. "MOVE_UP" or "DELIVER_MED"
        public string? Parameters { get; set; } // optional JSON string
    }
}
