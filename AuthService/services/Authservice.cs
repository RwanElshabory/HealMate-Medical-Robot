using AuthService.Data;
using AuthService.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;


namespace AuthService.Hospitalsystem
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _db;
        private readonly IConfiguration _cfg;
        private readonly IPasswordHasher<User> _passwordHasher;

        public AuthService(AppDbContext db, IConfiguration cfg, IPasswordHasher<User> passwordHasher)
        {
            _db = db;
            _cfg = cfg;
            _passwordHasher = passwordHasher;
        }

        
        private bool IsStrongPassword(string? password)
        {
            if (string.IsNullOrWhiteSpace(password)) return false;
            var pattern = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&].{8,}$";
            return Regex.IsMatch(password, pattern);
        }

        public async Task<bool> RegisterAsync(RegisterDto dto)
        {
            if (await _db.Users.AnyAsync(u => u.Email == dto.Email.ToLowerInvariant()))
                return false;

            if (!IsStrongPassword(dto.Password))
                throw new ArgumentException("Password must be at least 8 characters and include upper/lowercase letters, numbers, and symbols.");

            var user = new User
            {
                Email = dto.Email.ToLowerInvariant(),
                Role = dto.Role ?? "User"
            };

            user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);

            _db.Users.Add(user);
            await _db.SaveChangesAsync();
            return true;
        }

        public async Task<AuthResultDto?> LoginAsync(LoginDto dto)
        {
            var user = await _db.Users.SingleOrDefaultAsync(u => u.Email == dto.Email.ToLowerInvariant());
            if (user == null)
                return null;

            var verify = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
            if (verify == PasswordVerificationResult.Failed)
                return null;

            var jwtSection = _cfg.GetSection("Jwt");
            var key = jwtSection.GetValue<string>("Key") ?? throw new InvalidOperationException("JWT key missing");
            var issuer = jwtSection.GetValue<string>("Issuer") ?? "AuthService";
            var audience = jwtSection.GetValue<string>("Audience") ?? "AuthClients";
            var expireMinutes = jwtSection.GetValue<int>("ExpireMinutes");

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email)
            };

            if (!string.IsNullOrEmpty(user.Role))
                claims.Add(new Claim(ClaimTypes.Role, user.Role));

            var keyBytes = Encoding.UTF8.GetBytes(key);
            var creds = new SigningCredentials(new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256);
            var expires = DateTime.UtcNow.AddMinutes(expireMinutes);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            var tokenStr = new JwtSecurityTokenHandler().WriteToken(token);
            // create refresh token
            var refreshToken = GenerateRefreshToken();
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(1); 
            await _db.SaveChangesAsync();

            return new AuthResultDto 
            { 
                Token = tokenStr, 
                Expiration = expires,
                RefreshToken = refreshToken,
                Role = user.Role,
                User = new
                {
                 id = user.Id,
                 email = user.Email,
                 role = user.Role
                }


            };

        }
        private string GenerateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = System.Security.Cryptography.RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }


        public async Task<AuthResultDto?> RefreshTokenAsync(RefreshTokenRequestDto dto)
        {
            
            var user = await _db.Users.SingleOrDefaultAsync(u =>
                u.RefreshToken == dto.RefreshToken &&
                u.RefreshTokenExpiryTime > DateTime.UtcNow);

            if (user == null)
                return null; 

            
            var jwtSection = _cfg.GetSection("Jwt");
            var key = jwtSection.GetValue<string>("Key") ?? throw new InvalidOperationException("JWT key missing");
            var issuer = jwtSection.GetValue<string>("Issuer") ?? "AuthService";
            var audience = jwtSection.GetValue<string>("Audience") ?? "AuthClients";
            var expireMinutes = jwtSection.GetValue<int>("ExpireMinutes");

            
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email)
            };

            if (!string.IsNullOrEmpty(user.Role))
                claims.Add(new Claim(ClaimTypes.Role, user.Role));

            
            var keyBytes = Encoding.UTF8.GetBytes(key);
            var creds = new SigningCredentials(new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256);
            var expires = DateTime.UtcNow.AddMinutes(expireMinutes);

            var token = new JwtSecurityToken(
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: expires,
                signingCredentials: creds
            );

            var newAccessToken = new JwtSecurityTokenHandler().WriteToken(token);

            
            var newRefreshToken = GenerateRefreshToken();
            user.RefreshToken = newRefreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);
            await _db.SaveChangesAsync();

            return new AuthResultDto
            {
                Token = newAccessToken,
                Expiration = expires,
                RefreshToken = newRefreshToken
            };
        }
        public async Task<bool> LogoutAsync(string userId)
        {
            
            var user = await _db.Users.FindAsync(int.Parse(userId));
            if (user == null)
                return false;

            
            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;

            await _db.SaveChangesAsync();
            return true;
        }
        
    }
}
