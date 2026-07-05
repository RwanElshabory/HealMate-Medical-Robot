using System.Threading.Tasks;
using AuthService.Models;

namespace AuthService.Hospitalsystem
{
    public interface IAuthService
    {
        Task<bool> RegisterAsync(RegisterDto dto);
        Task<AuthResultDto?> LoginAsync(LoginDto dto);
        Task<AuthResultDto?> RefreshTokenAsync(RefreshTokenRequestDto dto);
        Task<bool> LogoutAsync(string userId);
        
    }
}
