using AuthService.Models;
using Microsoft.EntityFrameworkCore;

namespace AuthService.Data
{
    public class AppDbContext : DbContext
    {
        public DbSet<OtpCode> OtpCodes { get; set; }
        public AppDbContext(DbContextOptions<AppDbContext> opts) : base(opts) { }
        public DbSet<User> Users => Set<User>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
            base.OnModelCreating(modelBuilder);
        }
    }
}
