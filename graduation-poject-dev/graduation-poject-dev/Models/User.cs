namespace MedicalRobot.API.Models
{
    public class User
    {
        public int UserId { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // ✅ Firebase Cloud Messaging token for push notifications
        public string? FcmToken { get; set; }

        // العلاقات العكسية
        public ICollection<Patient>? PatientsAsDoctor { get; set; }
        public ICollection<Patient>? PatientsAsNurse { get; set; }
        public ICollection<Patient>? PatientAccounts { get; set; }

        // 👇 العلاقة العكسية مع الـReports اللي كتبها الدكتور
        public ICollection<Report>? ReportsWritten { get; set; }
    }
}
