using System;

namespace AuthService.Models
{
    public class RegisterDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? Role { get; set; }
    }

    public class LoginDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
 
    public class AuthResultDto
    {
    public string Token { get; set; } = string.Empty;
    public DateTime Expiration { get; set; }
    public string RefreshToken { get; set; } = string.Empty;
    public string Role { get; set; }= string.Empty;
    public object User { get; set; }= string.Empty;
    }
    public class SendOtpRequest
    {
    public string? Email { get; set; }
    }

    public class VerifyOtpRequest
    {
    public string? Email { get; set; }
    public string? Code { get; set; }
    }
   


}
