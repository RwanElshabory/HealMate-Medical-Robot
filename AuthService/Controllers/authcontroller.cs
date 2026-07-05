using AuthService.Models;
using AuthService.Hospitalsystem;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using AuthService.Data;
using AuthService.Services;
using Microsoft.EntityFrameworkCore;




namespace AuthService.Controllers
{
    
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _auth;
        private readonly AppDbContext _db;
        private readonly OtpService _otpService;
        public AuthController(IAuthService auth , AppDbContext db, OtpService otpService)  
        {
        _db = db;
        _auth = auth;
        _otpService = otpService;
        }
        

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var ok = await _auth.RegisterAsync(dto);
            if (!ok) return Conflict(new { message = "Email already exists" });
            return Ok(new { message = "Registered" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            var res = await _auth.LoginAsync(dto);
            if (res == null) return Unauthorized(new { message = "Invalid credentials" });
            return Ok(res);
        }

        [HttpGet("me")]
        [Authorize]
        public IActionResult Me()
        {
            var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
            var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            return Ok(new { email, role });
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequestDto dto)
        {
            var result = await _auth.RefreshTokenAsync(dto);
            if (result == null)
                return Unauthorized("Invalid refresh token");

            return Ok(result);
        }
        
        [HttpPost("logout")]
        [Authorize] 
        public async Task<IActionResult> Logout()
        {
            
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized();

            var ok = await _auth.LogoutAsync(userId);
            if (!ok) return BadRequest("User not found");

            return Ok("Logged out successfully");
        }

        [Authorize]
        [HttpPost("enable-biometric")]
        public async Task<IActionResult> EnableBiometric()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userId, out var id))
                return BadRequest("Invalid user id");

            var user = await _db.Users.FindAsync(id);

            if (user == null) return NotFound();

              user.BiometricEnabled = true;
              await _db.SaveChangesAsync();

              return Ok("Biometric login enabled.");
        }

        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request)
        {
            
            var user = await _db.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest("User not found");

            var otp = await _otpService.CreateAndSaveOtpAsync(user.Id);

            
            return Ok(new { message = "OTP generated", code = otp.Code });
        }

       
        [HttpPost("verify-otp")]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequest request)
        {
            var user = await _db.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest("User not found");

            var otp = await _db.OtpCodes
                .Where(o => o.UserId == user.Id && !o.IsUsed && o.Code == request.Code)
                .OrderByDescending(o => o.Id)
                .FirstOrDefaultAsync();

            if (otp == null)
                return BadRequest("Invalid code");

            if (otp.ExpireAt < DateTime.UtcNow)
                return BadRequest("Code expired");

            otp.IsUsed = true;
            await _db.SaveChangesAsync();

            return Ok("OTP verified successfully");
        }

    }
}
