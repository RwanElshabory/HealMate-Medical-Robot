using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.DTOs;
using MedicalRobot.API.Models;
using MedicalRobot.API.Common;
using System.Security.Claims;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/robot")]
    [Authorize(Roles = "Doctor")]
    public class RobotController : ControllerBase
    {
        private readonly AppDbContext _db;

        public RobotController(AppDbContext db)
        {
            _db = db;
        }

        private int GetDoctorId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim == null) throw new Exception("Doctor ID not found");
            return int.Parse(claim.Value);
        }

        [HttpPost("command")]
        public async Task<IActionResult> SendCommand([FromBody] RobotCommandDto cmd)
        {
            if (cmd == null)
                return BadRequest(new ApiResponse<string>("Invalid request"));

            var doctorId = GetDoctorId();
            var doctor = await _db.Users.FindAsync(doctorId);
            if (doctor == null)
                return BadRequest(new ApiResponse<string>("Doctor not found"));

            var log = new RobotLog
            {
                DoctorId = doctorId,
                PatientId = cmd.PatientId ?? 0,
                Action = cmd.Command,
                Parameters = cmd.Parameters ?? "",
                Status = RobotStatus.Queued,
                Timestamp = DateTime.UtcNow
            };

            _db.RobotLogs.Add(log);
            await _db.SaveChangesAsync();

            log.Status = RobotStatus.Sent;
            await _db.SaveChangesAsync();

            return Ok(new ApiResponse<object>(
                new { logId = log.LogId, status = log.Status.ToString() },
                "Command sent successfully"
            ));
        }

        [HttpGet("logs")]
        public async Task<IActionResult> GetLogs([FromQuery] int? patientId)
        {
            var doctorId = GetDoctorId();
            var query = _db.RobotLogs.Where(x => x.DoctorId == doctorId);

            if (patientId.HasValue)
                query = query.Where(x => x.PatientId == patientId.Value);

            var logs = await query
                .OrderByDescending(x => x.Timestamp)
                .Take(200)
                .ToListAsync();

            return Ok(new ApiResponse<object>(logs, "Logs retrieved successfully"));
        }

        [HttpGet("status")]
        public IActionResult GetStatus()
        {
            return Ok(new ApiResponse<object>(
                new { status = "Online", battery = 90, currentAction = "Idle" },
                "Robot status retrieved successfully"
            ));
        }

        [HttpGet("commands")]
        public IActionResult GetAvailableCommands()
        {
            var commands = new[] { "forward", "backward", "left", "right", "stop", "MoveToRoom" };
            return Ok(new ApiResponse<object>(commands, "Available robot commands"));
        }
    }
}