using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Data;
using MedicalRobot.API.Models;
using MedicalRobot.API.DTOs;

namespace MedicalRobot.API.Services
{
    public class NurseService
    {
        private readonly AppDbContext _db;

        public NurseService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<object> GetPatientsForNurse(int nurseId)
        {
            var patients = await _db.Patients
                .Where(p => p.NurseId == nurseId)
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

            return patients;
        }

        public async Task<VitalSign?> AddVitalSign(int patientId, VitalSign vital)
        {
            var patient = await _db.Patients.FindAsync(patientId);
            if (patient == null) return null;

            vital.PatientId = patientId;
            vital.RecordedAt = DateTime.UtcNow;

            _db.VitalSigns.Add(vital);
            await _db.SaveChangesAsync();

            return vital;
        }
    }
}
