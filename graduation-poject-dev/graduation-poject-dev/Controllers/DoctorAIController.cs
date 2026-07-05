using Microsoft.AspNetCore.Mvc;
using MedicalRobot.API.DTOs;
using MedicalRobot.API.Common;
using Microsoft.AspNetCore.Authorization;

namespace MedicalRobot.API.Controllers
{
    [ApiController]
    [Route("api/doctor/ai")]
    [Authorize(Roles = "Doctor")]
    public class DoctorAIController : ControllerBase
    {
        [HttpPost("predict")]
        public IActionResult PredictDisease([FromBody] PredictDiseaseDto dto)
        {
            if (dto == null || dto.Symptoms == null || !dto.Symptoms.Any())
                return BadRequest(new ApiResponse<string>("Symptoms are required"));

            var symptoms = dto.Symptoms.Select(s => s.ToLower()).ToList();
            string disease;
            double confidence;

            if (symptoms.Contains("fever") && symptoms.Contains("cough"))
            {
                disease = "Flu";
                confidence = 85;
            }
            else if (symptoms.Contains("chest pain"))
            {
                disease = "Heart problem";
                confidence = 90;
            }
            else
            {
                disease = "Unknown";
                confidence = 50;
            }

            return Ok(new ApiResponse<PredictDiseaseResultDto>(
                new PredictDiseaseResultDto { PredictedDisease = disease, Confidence = confidence },
                "Prediction completed successfully"
            ));
        }
    }
}