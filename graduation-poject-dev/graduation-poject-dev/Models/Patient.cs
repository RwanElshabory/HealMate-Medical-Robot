namespace MedicalRobot.API.Models
{
    public class Patient
    {
        public int PatientId { get; set; }
        public string FullName { get; set; }
        public int Age { get; set; }
        public string Gender { get; set; }
        public string MedicalHistory { get; set; }
        public string RoomNumber { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Foreign keys & navigation properties
        public int? UserId { get; set; }       
        public User? User { get; set; }

        public int? DoctorId { get; set; }    
        public User? Doctor { get; set; }

        public int? NurseId { get; set; }      
        public User? Nurse { get; set; }
    }
}
