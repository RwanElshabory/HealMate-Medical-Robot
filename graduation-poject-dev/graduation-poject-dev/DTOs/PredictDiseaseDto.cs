namespace MedicalRobot.API.DTOs
{
    public class PredictDiseaseDto
    {
        public int PatientId { get; set; }
        public int Age { get; set; }
        public string Gender { get; set; } = default!;
        public List<string> Symptoms { get; set; } = new();
    }

    public class PredictDiseaseResultDto
    {
        public string PredictedDisease { get; set; } = default!;
        public double Confidence { get; set; } // 0-100%
    }
}
