
using TargetSocialApp.Application;
using TargetSocialApp.Infrastructure;

namespace TargetSocialApp.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            // 1. Layer Dependencies
            builder.Services.AddInfrastructureDependencies(builder.Configuration);
            builder.Services.AddApplicationDependencies();

            // 2. Controllers
            builder.Services.AddControllers();

            // 3. Swagger
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            // 4. CORS
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll",
                    builder =>
                    {
                        builder.AllowAnyOrigin()
                               .AllowAnyMethod()
                               .AllowAnyHeader();
                    });
            });

            // 5. SignalR
            builder.Services.AddSignalR();
            builder.Services.AddTransient<TargetSocialApp.Application.Common.Interfaces.IChatNotifier, TargetSocialApp.API.Services.ChatNotifier>();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

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