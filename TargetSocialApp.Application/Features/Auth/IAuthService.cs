using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Auth.Requests;
using TargetSocialApp.Application.Features.Auth.Responses;

namespace TargetSocialApp.Application.Features.Auth
{
    public interface IAuthService
    {
        Task<Response<string>> RegisterAsync(RegisterRequest request);
        Task<Response<AuthResponse>> LoginAsync(LoginRequest request);
        Task<Response<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request);
        Task<Response<string>> ForgotPasswordAsync(ForgotPasswordRequest request);
        Task<Response<string>> ResetPasswordAsync(ResetPasswordRequest request);
        Task<Response<string>> VerifyEmailAsync(VerifyEmailRequest request);
        Task<Response<AuthResponse>> SocialLoginAsync(SocialLoginRequest request);
        Task<Response<string>> RequestOtpAsync(OtpRequest request);
        Task<Response<string>> VerifyOtpAsync(OtpVerifyRequest request);
    }
}
