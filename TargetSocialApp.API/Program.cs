using TargetSocialApp.Application;
using TargetSocialApp.Infrastructure;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using Serilog;

namespace TargetSocialApp.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // -----------------------------
            // 0️⃣ Serilog Configuration
            // -----------------------------
            builder.Host.UseSerilog((context, services, configuration) => configuration
                .ReadFrom.Configuration(context.Configuration)
                .Enrich.FromLogContext()
                .WriteTo.Console()
                .WriteTo.File("logs/log-.txt", rollingInterval: RollingInterval.Day));

            // -----------------------------
            // 1️⃣ Layer Dependencies
            // -----------------------------
            builder.Services.AddInfrastructureDependencies(builder.Configuration);
            builder.Services.AddApplicationDependencies();

            // -----------------------------
            // 2️⃣ Controllers
            // -----------------------------
            builder.Services.AddControllers();

            // -----------------------------
            // 3️⃣ Swagger
            // -----------------------------
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // -----------------------------
            // 4️⃣ CORS
            // -----------------------------
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", policy =>
                {
                    policy.AllowAnyOrigin()
                          .AllowAnyMethod()
                          .AllowAnyHeader();
                });
            });

            // -----------------------------
            // 5️⃣ SignalR
            // -----------------------------
            builder.Services.AddSignalR();
            builder.Services.AddTransient<
                TargetSocialApp.Application.Common.Interfaces.IChatNotifier,
                TargetSocialApp.API.Services.ChatNotifier>();

            // -----------------------------
            // 5.5️⃣ Rate Limiting
            // -----------------------------
            builder.Services.AddRateLimiter(options =>
            {
                options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? httpContext.Request.Headers.Host.ToString(),
                        factory: partition => new FixedWindowRateLimiterOptions
                        {
                            AutoReplenishment = true,
                            PermitLimit = 100,
                            QueueLimit = 0,
                            Window = TimeSpan.FromMinutes(1)
                        }));
                
                options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            });

            var app = builder.Build();

            // -----------------------------
            // Diagnosis: Serilog Request Logging
            // -----------------------------
            app.UseSerilogRequestLogging();

            // -----------------------------
            // 6️⃣ Root Health Check (مهم ل Railway)
            // -----------------------------
            app.MapGet("/", () => "TargetSocialApp API is running 🚀");

            // -----------------------------
            // 7️⃣ Pipeline
            // -----------------------------
            app.UseSwagger();
            app.UseSwaggerUI();

            // ❌ شيل HTTPS Redirection
            // app.UseHttpsRedirection();

            app.UseCors("AllowAll");
            app.UseRateLimiter(); // Add Rate Limiter Middleware
            app.UseAuthorization();

            app.MapControllers();
            app.MapHub<TargetSocialApp.API.Hubs.ChatHub>("/chatHub");
            app.MapHub<TargetSocialApp.API.Hubs.NotificationHub>("/notificationHub");



            // -----------------------------
            // 8️⃣ Data Seeding
            // -----------------------------
            using (var scope = app.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                try
                {
                    var context = services.GetRequiredService<TargetSocialApp.Infrastructure.Persistence.ApplicationDbContext>();
                    // Move to Infrastructure Seeding namespace
                    var seeder = new TargetSocialApp.Infrastructure.Persistence.Seeding.DataSeeder(context);
                    seeder.SeedAsync().Wait();
                }
                catch (Exception ex)
                {
                    var logger = services.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "An error occurred while seeding the database.");
                }
            }

            app.Run();
        }
    }
}
