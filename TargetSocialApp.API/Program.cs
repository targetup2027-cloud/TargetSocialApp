using TargetSocialApp.Application;
using TargetSocialApp.Infrastructure;

namespace TargetSocialApp.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
            Console.WriteLine($"[Diagnosis] PORT env var: '{Environment.GetEnvironmentVariable("PORT")}'");
            Console.WriteLine($"[Diagnosis] Binding to: http://0.0.0.0:{port}");
            builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

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

            var app = builder.Build();

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
            app.UseAuthorization();

            app.MapControllers();
            app.MapHub<TargetSocialApp.API.Hubs.ChatHub>("/chatHub");
            app.MapHub<TargetSocialApp.API.Hubs.NotificationHub>("/notificationHub");

            app.Run();
        }
    }
}
