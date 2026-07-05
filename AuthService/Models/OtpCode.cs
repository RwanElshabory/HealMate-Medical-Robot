namespace AuthService.Models   
{
    public class OtpCode
    {
        public int Id { get; set; }

        public int? UserId { get; set; } 
        public string? Code { get; set; }

        public DateTime ExpireAt { get; set; }
        public bool IsUsed { get; set; } = false;
    }
}
