using System.Text;
using System.Threading.Tasks;
using AuthService.Data;     // AppDbContext
using AuthService.Models;   // OtpCode


namespace AuthService.Services
{
    public class OtpService
    {
        private readonly AppDbContext _context;

        public OtpService(AppDbContext context)
        {
            _context = context;
        }

        public string GenerateOtpCode(int length = 6)
        {
            var random = new Random();
            var code = new StringBuilder();

            for (int i = 0; i < length; i++)
            {
                code.Append(random.Next(0, 10)); 
            }

            return code.ToString();
        }

        public async Task<OtpCode> CreateAndSaveOtpAsync(int userId, int minutesValid = 5)
        {
            var code = GenerateOtpCode();

            var otp = new OtpCode
            {
                UserId = userId,
                Code = code,
                ExpireAt = DateTime.UtcNow.AddMinutes(minutesValid),
                IsUsed = false
            };

            _context.OtpCodes.Add(otp);
            await _context.SaveChangesAsync();

            return otp;
        }
    }
}
