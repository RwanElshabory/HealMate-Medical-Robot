using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.DTOs;
using MedicalRobot.API.Models;
using MedicalRobot.API.Common;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/doctor")]
    [Authorize(Roles = "Doctor")]
    public class DoctorController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly IWebHostEnvironment _env;

        public DoctorController(AppDbContext db, IWebHostEnvironment env)
        {
            _db = db;
            _env = env;
        }

        private int GetDoctorId(int? fallbackId = null)
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim != null) return int.Parse(claim.Value);
            if (fallbackId.HasValue) return fallbackId.Value;
            throw new Exception("DoctorId not provided");
        }

        [HttpGet("patients")]
        public async Task<IActionResult> GetPatients([FromQuery] int? doctorId)
        {
            var id = GetDoctorId(doctorId);
            var patients = await _db.Patients
                .Where(p => p.DoctorId == id)
                .Select(p => new PatientDto
                {
                    PatientId = p.PatientId,
                    FullName = p.FullName,
                    Age = p.Age,
                    Gender = p.Gender,
                    MedicalHistory = p.MedicalHistory,
                    RoomNumber = p.RoomNumber
                })
                .ToListAsync();

            return Ok(new ApiResponse<List<PatientDto>>(patients, "Patients retrieved successfully"));
        }

        [HttpGet("patients/{patientId:int}")]
        public async Task<IActionResult> GetPatient(int patientId, [FromQuery] int? doctorId)
        {
            var id = GetDoctorId(doctorId);
            var p = await _db.Patients.FirstOrDefaultAsync(x => x.PatientId == patientId && x.DoctorId == id);
            if (p == null) return NotFound(new ApiResponse<string>("Patient not found"));

            return Ok(new ApiResponse<PatientDto>(
                new PatientDto
                {
                    PatientId = p.PatientId,
                    FullName = p.FullName,
                    Age = p.Age,
                    Gender = p.Gender,
                    MedicalHistory = p.MedicalHistory,
                    RoomNumber = p.RoomNumber
                },
                "Patient retrieved successfully"
            ));
        }

        [HttpGet("patients/search")]
        public async Task<IActionResult> SearchPatients([FromQuery] string? q, [FromQuery] int? doctorId)
        {
            var id = GetDoctorId(doctorId);
            var query = _db.Patients.Where(p => p.DoctorId == id);
            if (!string.IsNullOrWhiteSpace(q)) query = query.Where(p => p.FullName.Contains(q));

            var results = await query
                .Select(p => new PatientDto
                {
                    PatientId = p.PatientId,
                    FullName = p.FullName,
                    Age = p.Age,
                    Gender = p.Gender,
                    MedicalHistory = p.MedicalHistory,
                    RoomNumber = p.RoomNumber
                })
                .ToListAsync();

            return Ok(new ApiResponse<List<PatientDto>>(results, "Search completed successfully"));
        }

        [HttpGet("reports")]
        public async Task<IActionResult> GetReports([FromQuery] int? doctorId)
        {
            var id = GetDoctorId(doctorId);
            var reports = await _db.Reports
                .Where(r => r.DoctorId == id)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new { r.ReportId, r.Title, r.Notes, r.ImageUrl, r.CreatedAt, r.PatientId })
                .ToListAsync();

            return Ok(new ApiResponse<object>(reports, "Reports retrieved successfully"));
        }

        [HttpPost("reports")]
        public async Task<IActionResult> AddReport([FromForm] CreateReportDto dto, [FromQuery] int? doctorId)
        {
            var id = GetDoctorId(doctorId);
            var patient = await _db.Patients.FindAsync(dto.PatientId);
            if (patient == null) return BadRequest(new ApiResponse<string>("Patient not found"));

            string? imageUrl = null;
            if (dto.Image != null)
            {
                var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads", "reports");
                Directory.CreateDirectory(uploadsFolder);
                var fileName = Guid.NewGuid() + Path.GetExtension(dto.Image.FileName);
                var filePath = Path.Combine(uploadsFolder, fileName);
                using var stream = new FileStream(filePath, FileMode.Create);
                await dto.Image.CopyToAsync(stream);
                imageUrl = $"/uploads/reports/{fileName}";
            }

            var report = new Report
            {
                PatientId = dto.PatientId,
                DoctorId = id,
                Title = dto.Title,
                Notes = dto.Notes,
                ImageUrl = imageUrl,
                CreatedAt = DateTime.UtcNow
            };

            _db.Reports.Add(report);
            await _db.SaveChangesAsync();

            return Ok(new ApiResponse<Report>(report, "Report created successfully"));
        }

        [HttpPut("reports/{id:int}")]
        public async Task<IActionResult> UpdateReport(int id, [FromForm] CreateReportDto dto, [FromQuery] int? doctorId)
        {
            var doctor = GetDoctorId(doctorId);
            var report = await _db.Reports.FirstOrDefaultAsync(r => r.ReportId == id && r.DoctorId == doctor);
            if (report == null) return NotFound(new ApiResponse<string>("Report not found"));

            report.Title = dto.Title;
            report.Notes = dto.Notes;

            if (dto.Image != null)
            {
                var uploadsFolder = Path.Combine(_env.WebRootPath, "uploads", "reports");
                Directory.CreateDirectory(uploadsFolder);
                var fileName = Guid.NewGuid() + Path.GetExtension(dto.Image.FileName);
                var filePath = Path.Combine(uploadsFolder, fileName);
                using var stream = new FileStream(filePath, FileMode.Create);
                await dto.Image.CopyToAsync(stream);
                report.ImageUrl = $"/uploads/reports/{fileName}";
            }

            await _db.SaveChangesAsync();
            return Ok(new ApiResponse<string>("Report updated successfully"));
        }

        [HttpDelete("reports/{id:int}")]
        public async Task<IActionResult> DeleteReport(int id, [FromQuery] int? doctorId)
        {
            var doctor = GetDoctorId(doctorId);
            var report = await _db.Reports.FirstOrDefaultAsync(r => r.ReportId == id && r.DoctorId == doctor);
            if (report == null) return NotFound(new ApiResponse<string>("Report not found"));

            _db.Reports.Remove(report);
            await _db.SaveChangesAsync();
            return Ok(new ApiResponse<string>("Report deleted successfully"));
        }
    }
}