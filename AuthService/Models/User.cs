using System.ComponentModel.DataAnnotations;

namespace AuthService.Models
{
    public class User
    {
        public int Id { get; set; }

        [Required, MaxLength(200)]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Role { get; set; }

        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiryTime { get; set; }
        public bool BiometricEnabled { get; set; }

         
    }
}
