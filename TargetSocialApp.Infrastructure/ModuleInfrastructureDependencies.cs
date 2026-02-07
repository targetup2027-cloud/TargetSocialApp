using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Infrastructure.Persistence;
using TargetSocialApp.Infrastructure.Persistence.Repositories;

namespace TargetSocialApp.Infrastructure
{
    public static class ModuleInfrastructureDependencies
    {
        public static IServiceCollection AddInfrastructureDependencies(this IServiceCollection services, IConfiguration configuration)
        {
            // 1️⃣ اقرأ من Environment Variable أولًا
         var connectionString = Environment.GetEnvironmentVariable("CONNECTION_STRING") 
                       ?? configuration.GetConnectionString("DefaultConnection");

        try
        {
            services.AddDbContext<ApplicationDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error connecting to database: " + ex.Message);
            throw;
        }


            // 2️⃣ Services
            services.AddTransient(typeof(IGenericRepository<>), typeof(GenericRepository<>));
            services.AddTransient<IUnitOfWork, UnitOfWork>();
            
            // 3️⃣ Infrastructure Services
            services.AddTransient<IPasswordHasher, Services.PasswordHasher>();
            services.AddTransient<ITokenService, Services.TokenService>();
            services.AddTransient<ISmsService, Services.SmsService>();
            services.AddTransient<IFileService, Services.FileService>();

            return services;
        }
    }
}
