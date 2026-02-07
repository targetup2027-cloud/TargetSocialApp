using TargetSocialApp.Application.Features.Auth.Responses;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Common.Interfaces;

public interface ITokenService
{
    Task<AuthResponse> GenerateTokensAsync(User user);
    Task<string> GenerateRefreshTokenAsync();
    Task<string> GenerateAccessTokenAsync(User user);
}
