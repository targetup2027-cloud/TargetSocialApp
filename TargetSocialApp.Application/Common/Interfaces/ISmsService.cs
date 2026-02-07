
using System.Threading.Tasks;

namespace TargetSocialApp.Application.Common.Interfaces;

public interface ISmsService
{
    Task<(bool Success, string Message)> SendVerificationAsync(string phoneNumber, string channel);
    Task<(bool Success, string Message)> VerifyCodeAsync(string phoneNumber, string code);
}
