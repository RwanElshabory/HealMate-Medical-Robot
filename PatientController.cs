using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.Common;
using System.Security.Claims;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/patient")]
    [Authorize(Roles = "Patient")]
    public class PatientController : ControllerBase
    {
        private readonly AppDbContext _db;

        public PatientController(AppDbContext db)
        {
            _db = db;
        }

        private int GetPatientId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null) throw new Exception("Patient ID not found");
            return int.Parse(claim.Value);
        }

        [HttpGet("reports")]
        public async Task<IActionResult> GetMyReports()
        {
            var patientId = GetPatientId();
            var reports = await _db.Reports
                .Where(r => r.PatientId == patientId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(new ApiResponse<object>(reports, "Reports retrieved successfully"));
        }

        [HttpGet("medicine")]
        public async Task<IActionResult> GetMyMedicine()
        {
            var patientId = GetPatientId();
            var medicine = await _db.MedicineSchedules
                .Where(m => m.PatientId == patientId)
                .OrderBy(m => m.ScheduledTime)
                .ToListAsync();

            return Ok(new ApiResponse<object>(medicine, "Medicine retrieved successfully"));
        }

        [HttpGet("chat")]
        public async Task<IActionResult> GetMyChat()
        {
            var patientId = GetPatientId();
            var chat = await _db.ChatMessages
                .Where(c => c.SenderId == patientId || c.ReceiverId == patientId)
                .OrderBy(c => c.SentAt)
                .ToListAsync();

            return Ok(new ApiResponse<object>(chat, "Chat retrieved successfully"));
        }

        [HttpGet("vitals")]
        public async Task<IActionResult> GetVitals()
        {
            var patientId = GetPatientId();
            var vitals = await _db.VitalSigns
                .Where(v => v.PatientId == patientId)
                .OrderByDescending(v => v.RecordedAt)
                .ToListAsync();

            return Ok(new ApiResponse<object>(vitals, "Vitals retrieved successfully"));
        }

        [HttpGet("{id}/vitals")]
        public async Task<IActionResult> GetVitals(int id)
        {
            var patientId = GetPatientId();
            if (id != patientId) return Forbid();

            var vitals = await _db.VitalSigns
                .Where(v => v.PatientId == id)
                .OrderByDescending(v => v.RecordedAt)
                .ToListAsync();

            return Ok(new ApiResponse<object>(vitals, "Vitals retrieved successfully"));
        }
    }
}