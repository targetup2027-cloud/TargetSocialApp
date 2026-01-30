using System;
using System.Threading.Tasks;
using FluentValidation;
using Mapster;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Auth.Requests;
using TargetSocialApp.Application.Features.Auth.Responses;
using TargetSocialApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Auth
{
    public class AuthService : AppService, IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IValidator<RegisterRequest> _registerValidator;
        private readonly IValidator<LoginRequest> _loginValidator;
        private readonly IConfiguration _configuration;

        public AuthService(
            IUnitOfWork unitOfWork,
            IGenericRepository<User> userRepository,
            IValidator<RegisterRequest> registerValidator,
            IValidator<LoginRequest> loginValidator,
            IConfiguration configuration)
        {
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
            _configuration = configuration;
        }

        public async Task<Response<string>> RegisterAsync(RegisterRequest request)
        {
            var validationResult = await DoValidationAsync<RegisterRequest, string>(request, _registerValidator);
            if (validationResult != null) return validationResult;

            var existingUser = await _userRepository.GetTableNoTracking().FirstOrDefaultAsync(x => x.Email == request.Email);
            if (existingUser != null)
                return Response<string>.Failure("Email already exists");

            string passwordHash = request.Password; // Placeholder for BCrypt

            var user = request.Adapt<User>();
            user.PasswordHash = passwordHash;
            
            await _userRepository.AddAsync(user);
            await _unitOfWork.CompleteAsync();

            return Response<string>.Success("User registered successfully");
        }

        public async Task<Response<AuthResponse>> LoginAsync(LoginRequest request)
        {
            var validationResult = await DoValidationAsync<LoginRequest, AuthResponse>(request, _loginValidator);
            if (validationResult != null) return validationResult;

            var user = await _userRepository.GetTableNoTracking().FirstOrDefaultAsync(x => x.Email == request.Email);
            if (user == null || user.PasswordHash != request.Password)
                return Response<AuthResponse>.Failure("Invalid credentials");

            string accessToken = "dummy_token"; 
            string refreshToken = Guid.NewGuid().ToString();

            return Response<AuthResponse>.Success(new AuthResponse
            {
                AccessToken = accessToken,
                RefreshToken = refreshToken,
                UserId = user.Id,
                Email = user.Email
            });
        }

        public async Task<Response<string>> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            // Placeholder
            return Response<string>.Success("Reset password link sent (simulated)");
        }

        public async Task<Response<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request)
        {
             // Placeholder
            return Response<AuthResponse>.Success(new AuthResponse { AccessToken = "new_dummy_token", RefreshToken = "new_dummy_refresh" });
        }

        public async Task<Response<string>> ResetPasswordAsync(ResetPasswordRequest request)
        {
            // Placeholder
            return Response<string>.Success("Password reset successfully");
        }

        public async Task<Response<AuthResponse>> SocialLoginAsync(SocialLoginRequest request)
        {
            if (request.Provider.Equals("Google", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    var settings = new GoogleJsonWebSignature.ValidationSettings()
                    {
                        Audience = new[] { _configuration["Authentication:Google:ClientId"] }
                    };

                    var payload = await GoogleJsonWebSignature.ValidateAsync(request.ProviderToken, settings);

                    var user = await _userRepository.GetTableNoTracking().FirstOrDefaultAsync(x => x.Email == payload.Email);
                    if (user == null)
                    {
                        user = new User
                        {
                            FirstName = payload.GivenName,
                            LastName = payload.FamilyName,
                            Email = payload.Email,
                            // UserName = payload.Email, // Removed as property doesn't exist
                            PasswordHash = Guid.NewGuid().ToString(), // Random password for social users
                            DateOfBirth = DateTime.UtcNow, // Default to now if not provided
                            Gender = Gender.Other // Default gender
                            // Add other necessary fields
                        };

                        await _userRepository.AddAsync(user);
                        await _unitOfWork.CompleteAsync();
                    }

                    // Generate Tokens (Should use a real TokenService)
                    string accessToken = "dummy_social_token";
                    string refreshToken = Guid.NewGuid().ToString();

                    return Response<AuthResponse>.Success(new AuthResponse
                    {
                        AccessToken = accessToken,
                        RefreshToken = refreshToken,
                        UserId = user.Id,
                        Email = user.Email
                    });

                }
                catch (InvalidJwtException)
                {
                    return Response<AuthResponse>.Failure("Invalid Google Token");
                }
                catch (Exception ex)
                {
                    return Response<AuthResponse>.Failure($"Authentication failed: {ex.Message}");
                }
            }

            return Response<AuthResponse>.Failure("Provider not supported");
        }

        public async Task<Response<string>> VerifyEmailAsync(VerifyEmailRequest request)
        {
            // Placeholder
            return Response<string>.Success("Email verified successfully");
        }
    }
}
