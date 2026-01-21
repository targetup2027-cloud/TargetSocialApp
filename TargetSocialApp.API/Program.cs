using TargetSocialApp.Application;
using TargetSocialApp.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace TargetSocialApp.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // -----------------------------
            // 1️⃣ Connection String Setup
            // -----------------------------
            // يقرأ من Environment Variable أولًا
            var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING")
                                   ?? builder.Configuration.GetConnectionString("DefaultConnection");

            // -----------------------------
            // 2️⃣ Layer Dependencies
            // -----------------------------
            builder.Services.AddInfrastructureDependencies(builder.Configuration);
            builder.Services.AddApplicationDependencies();

            // -----------------------------
            // 3️⃣ Controllers
            // -----------------------------
            builder.Services.AddControllers();

            // -----------------------------
            // 4️⃣ Swagger
            // -----------------------------
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // -----------------------------
            // 5️⃣ CORS
            // -----------------------------
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyMethod()
                           .AllowAnyHeader();
                });
            });

            // -----------------------------
            // 6️⃣ SignalR
            // -----------------------------
            builder.Services.AddSignalR();
            builder.Services.AddTransient<TargetSocialApp.Application.Common.Interfaces.IChatNotifier,
                                          TargetSocialApp.API.Services.ChatNotifier>();

            // -----------------------------
            // 7️⃣ Build App
            // -----------------------------
            var app = builder.Build();

            // -----------------------------
            // 8️⃣ HTTP Request Pipeline
            // -----------------------------
        
            app.UseSwagger();
            app.UseSwaggerUI();
            

            app.UseHttpsRedirection();
            app.UseCors("AllowAll");
            app.UseAuthorization();

            app.MapControllers();
            app.MapHub<TargetSocialApp.API.Hubs.ChatHub>("/chatHub");
            app.MapHub<TargetSocialApp.API.Hubs.NotificationHub>("/notificationHub");

            app.Run();
        }
    }
}
