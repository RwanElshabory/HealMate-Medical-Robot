using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.Common;
using MedicalRobot.API.Models;
using MedicalRobot.API.DTOs;
using Microsoft.AspNetCore.Authorization;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/nurses")]
    [Authorize(Roles = "Doctor")]
    public class NursesController : ControllerBase
    {
        private readonly AppDbContext _db;

        public NursesController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetNurses()
        {
            var nurses = await _db.Users
                .Where(u => u.Role == UserRole.Nurse)
                .Select(n => new NursesDto
                {
                    NurseId = n.UserId,
                    FullName = n.Name
                })
                .ToListAsync();

            return Ok(new ApiResponse<object>(nurses, "Nurses retrieved successfully"));
        }
    }
}