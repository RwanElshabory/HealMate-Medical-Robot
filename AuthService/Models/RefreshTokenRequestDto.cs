namespace AuthService.Models
{
    public class RefreshTokenRequestDto
    {
        public string Token { get; set; } = string.Empty;          // old access token
        public string RefreshToken { get; set; } = string.Empty;   // refresh token
    }
}
