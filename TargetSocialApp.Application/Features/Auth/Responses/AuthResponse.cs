namespace TargetSocialApp.Application.Features.Auth.Responses
{
    public class AuthResponse
    {
        public string AccessToken { get; set; } = null!;
        public string RefreshToken { get; set; } = null!;
        public int UserId { get; set; }
        public string Email { get; set; } = null!;
    }
}
