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

namespace TargetSocialApp.Application.Features.Auth
{
    public class AuthService : AppService, IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IValidator<RegisterRequest> _registerValidator;
        private readonly IValidator<LoginRequest> _loginValidator;

        public AuthService(
            IUnitOfWork unitOfWork,
            IGenericRepository<User> userRepository,
            IValidator<RegisterRequest> registerValidator,
            IValidator<LoginRequest> loginValidator)
        {
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
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
            // Placeholder
            return Response<AuthResponse>.Success(new AuthResponse { AccessToken = "social_dummy_token", RefreshToken = "social_dummy_refresh" });
        }

        public async Task<Response<string>> VerifyEmailAsync(VerifyEmailRequest request)
        {
            // Placeholder
            return Response<string>.Success("Email verified successfully");
        }
    }
}
