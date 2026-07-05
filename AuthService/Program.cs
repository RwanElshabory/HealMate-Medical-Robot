using AuthService.Data;
using AuthService.Hospitalsystem;
using AuthService.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Threading.RateLimiting;




var builder = WebApplication.CreateBuilder(args);

var cfg = builder.Configuration;
cfg.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(cfg.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IPasswordHasher<AuthService.Models.User>, PasswordHasher<AuthService.Models.User>>();
builder.Services.AddScoped<IAuthService, AuthService.Hospitalsystem.AuthService>();


var jwtSection = cfg.GetSection("Jwt");
var key = jwtSection.GetValue<string>("Key") ?? throw new InvalidOperationException("JWT Key not found");
var issuer = jwtSection.GetValue<string>("Issuer");
var audience = jwtSection.GetValue<string>("Audience");

var keyBytes = Encoding.UTF8.GetBytes(key);
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false; // true in production
    options.SaveToken = true;
    options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = issuer,
        ValidateAudience = true,
        ValidAudience = audience,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(keyBytes),
        ValidateLifetime = true
    };
});

builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "anonymous",
            factory: partition => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,               // number of request
                Window = TimeSpan.FromMinutes(1), 
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 2                   
            })
    );
});
builder.Services.AddAuthorization();
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddScoped<OtpService>();
builder.Services.AddSwaggerGen();
builder.WebHost.UseUrls("https://localhost:7145");

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.UseRateLimiter();
app.Run();
