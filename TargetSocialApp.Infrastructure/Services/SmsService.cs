using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Interfaces;

namespace TargetSocialApp.Infrastructure.Services
{
    public class SmsService : ISmsService
    {
        public Task<(bool Success, string Message)> SendVerificationAsync(string phoneNumber, string channel)
        {
            // Mock implementation: Always returns success in development
            return Task.FromResult((true, "pending"));
        }

        public Task<(bool Success, string Message)> VerifyCodeAsync(string phoneNumber, string code)
        {
            // Mock implementation: Consider "123456" as a valid code for testing
            if (code == "123456")
            {
                return Task.FromResult((true, "approved"));
            }
            return Task.FromResult((false, "Invalid code"));
        }
    }
}
