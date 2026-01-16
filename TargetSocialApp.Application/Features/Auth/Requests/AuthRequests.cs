using System;

namespace TargetSocialApp.Application.Features.Auth.Requests
{
    public class RefreshTokenRequest
    {
        public string Token { get; set; } = null!;
        public string RefreshToken { get; set; } = null!;
    }

    public class ForgotPasswordRequest
    {
        public string Email { get; set; } = null!;
    }

    public class ResetPasswordRequest
    {
        public string Email { get; set; } = null!;
        public string Token { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
        public string ConfirmPassword { get; set; } = null!;
    }

    public class VerifyEmailRequest
    {
        public string UserId { get; set; } = null!;
        public string Token { get; set; } = null!;
    }

    public class SocialLoginRequest
    {
        public string Provider { get; set; } = null!; // Google, Facebook, Apple
        public string ProviderToken { get; set; } = null!;
    }
}
