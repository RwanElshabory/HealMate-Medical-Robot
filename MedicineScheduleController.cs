using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.Models;
using MedicalRobot.API.DTOs;
using MedicalRobot.API.Common;
using System.Security.Claims;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/nurse/medicine")]
    [Authorize(Roles = "Nurse")]
    public class MedicineScheduleController : ControllerBase
    {
        private readonly AppDbContext _db;

        public MedicineScheduleController(AppDbContext db)
        {
            _db = db;
        }

        private int GetNurseId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null) throw new Exception("Nurse ID not found");
            return int.Parse(claim.Value);
        }

        [HttpGet("{patientId:int}")]
        public async Task<IActionResult> GetSchedule(int patientId)
        {
            var nurseId = GetNurseId();
            var patient = await _db.Patients.FirstOrDefaultAsync(p => p.PatientId == patientId && p.NurseId == nurseId);
            if (patient == null) return Forbid();

            var schedules = await _db.MedicineSchedules
                .Where(m => m.PatientId == patientId && m.NurseId == nurseId)
                .OrderBy(m => m.ScheduledTime)
                .Select(m => new
                {
                    m.Id,
                    m.PatientId,
                    m.NurseId,
                    m.MedicineName,
                    m.Dose,
                    m.ScheduledTime,
                    m.IsGiven,
                    m.GivenAt
                })
                .ToListAsync();

            return Ok(new ApiResponse<object>(schedules, "Medicine schedule retrieved successfully"));
        }

        [HttpPost]
        public async Task<IActionResult> AddMedicine([FromBody] MedicineScheduleDto dto)
        {
            var nurseId = GetNurseId();
            var schedule = new MedicineSchedule
            {
                PatientId = dto.PatientId,
                NurseId = nurseId,
                MedicineName = dto.MedicineName,
                Dose = dto.Dose,
                ScheduledTime = dto.ScheduledTime,
                IsGiven = false,
                GivenAt = null
            };

            _db.MedicineSchedules.Add(schedule);
            await _db.SaveChangesAsync();

            return Ok(new ApiResponse<MedicineSchedule>(schedule, "Medicine added successfully"));
        }

        [HttpPost("mark-given/{id:int}")]
        public async Task<IActionResult> MarkGiven(int id)
        {
            var nurseId = GetNurseId();
            var schedule = await _db.MedicineSchedules.FirstOrDefaultAsync(x => x.Id == id && x.NurseId == nurseId);
            if (schedule == null) return NotFound(new ApiResponse<string>("Medicine schedule not found"));

            schedule.IsGiven = true;
            schedule.GivenAt = DateTime.UtcNow;
            await _db.SaveChangesAsync();

            return Ok(new ApiResponse<MedicineSchedule>(schedule, "Medicine marked as given"));
        }
    }
}