using System;
using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace TargetSocialApp.Infrastructure.Persistence
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            try
            {
                var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: true)
                    .AddEnvironmentVariables();

                var configuration = builder.Build();

                var provider = Environment.GetEnvironmentVariable("EF_PROVIDER")
                               ?? configuration["EF_PROVIDER"]
                               ?? "Npgsql"; // changed default to Npgsql

                var connectionString = Environment.GetEnvironmentVariable("DefaultConnection")
                                       ?? configuration.GetConnectionString("DefaultConnection");

                if (string.IsNullOrWhiteSpace(connectionString))
                    throw new InvalidOperationException("Connection string not found. Set 'DefaultConnection' in appsettings.json or env var.");

                var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
                var migrationsAssembly = typeof(ApplicationDbContext).Assembly.FullName;

                if (provider.Equals("Npgsql", StringComparison.OrdinalIgnoreCase))
                {
                    optionsBuilder.UseLazyLoadingProxies()
                                  .UseNpgsql(connectionString, npgsql => npgsql.MigrationsAssembly(migrationsAssembly));
                }
                else if (provider.Equals("SqlServer", StringComparison.OrdinalIgnoreCase))
                {
                    optionsBuilder.UseLazyLoadingProxies()
                                  .UseSqlServer(connectionString, sql => sql.MigrationsAssembly(migrationsAssembly));
                }
                else
                {
                    throw new InvalidOperationException($"Unsupported EF_PROVIDER '{provider}'. Use 'SqlServer' or 'Npgsql'.");
                }

                return new ApplicationDbContext(optionsBuilder.Options);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException("DesignTimeDbContextFactory failed: " + ex.Message, ex);
            }
        }
    }
}

