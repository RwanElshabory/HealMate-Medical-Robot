using Microsoft.AspNetCore.Mvc;
using MedicalRobot.API.Models;
using MedicalRobot.API.Services;
using MedicalRobot.API.Common;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/nurse")]
    [Authorize(Roles = "Nurse")]
    public class NurseController : ControllerBase
    {
        private readonly NurseService _service;

        public NurseController(NurseService service)
        {
            _service = service;
        }

        private int GetNurseId(int? fallbackId = null)
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (claim != null) return int.Parse(claim.Value);
            if (fallbackId.HasValue) return fallbackId.Value;
            throw new Exception("NurseId not provided");
        }

        [HttpGet("{nurseId}/patients")]
        public async Task<IActionResult> GetPatients(int nurseId)
        {
            var currentNurseId = GetNurseId(nurseId);
            if (nurseId != currentNurseId) return Forbid();

            var patients = await _service.GetPatientsForNurse(currentNurseId);
            return Ok(new ApiResponse<object>(patients, "Nurse patients retrieved successfully"));
        }

        [HttpPost("{patientId}/vitals")]
        public async Task<IActionResult> AddVitalSign(int patientId, [FromBody] VitalSign vital)
        {
            if (vital == null) return BadRequest(new ApiResponse<string>("Vital data is required"));

            var result = await _service.AddVitalSign(patientId, vital);
            if (result == null) return NotFound(new ApiResponse<string>("Patient not found"));

            return Ok(new ApiResponse<VitalSign>(result, "Vital sign added successfully"));
        }
    }
}