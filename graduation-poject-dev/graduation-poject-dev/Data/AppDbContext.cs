using Microsoft.EntityFrameworkCore;
using MedicalRobot.API.Models;

namespace MedicalRobot.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Patient> Patients { get; set; }
        public DbSet<Report> Reports { get; set; }
        public DbSet<RobotLog> RobotLogs { get; set; }
        public DbSet<ChatMessage> ChatMessage { get; set; }



        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Email unique
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();
            modelBuilder.Entity<ChatMessage>()
              .HasKey(m => m.MessageId);


            // علاقة Doctor ↔ Patients
            modelBuilder.Entity<Patient>()
                .HasOne(p => p.Doctor)
                .WithMany(u => u.PatientsAsDoctor)
                .HasForeignKey(p => p.DoctorId)
                .OnDelete(DeleteBehavior.Restrict);

            // علاقة Nurse ↔ Patients
            modelBuilder.Entity<Patient>()
                .HasOne(p => p.Nurse)
                .WithMany(u => u.PatientsAsNurse)
                .HasForeignKey(p => p.NurseId)
                .OnDelete(DeleteBehavior.Restrict);

            // علاقة Report ↔ Doctor
            modelBuilder.Entity<Report>()
                .HasOne(r => r.Doctor)
                .WithMany(u => u.ReportsWritten)
                .HasForeignKey(r => r.DoctorId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<RobotLog>()
    .HasKey(r => r.LogId);


            // علاقة Report ↔ Patient
            modelBuilder.Entity<Report>()
                .HasOne(r => r.Patient)
                .WithMany()
                .HasForeignKey(r => r.PatientId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
