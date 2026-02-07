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
using Microsoft.Extensions.Caching.Memory;

namespace TargetSocialApp.Application.Features.Auth
{
    public class AuthService : AppService, IAuthService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IValidator<RegisterRequest> _registerValidator;
        private readonly IValidator<LoginRequest> _loginValidator;
        private readonly IConfiguration _configuration;
        private readonly IMemoryCache _cache;
        private readonly IPasswordHasher _passwordHasher;
        private readonly ITokenService _tokenService;
        private readonly ISmsService _smsService;

        public AuthService(
            IUnitOfWork unitOfWork,
            IGenericRepository<User> userRepository,
            IValidator<RegisterRequest> registerValidator,
            IValidator<LoginRequest> loginValidator,
            IConfiguration configuration,
            IMemoryCache cache,
            IPasswordHasher passwordHasher,
            ITokenService tokenService,
            ISmsService smsService)
        {
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
            _configuration = configuration;
            _cache = cache;
            _passwordHasher = passwordHasher;
            _tokenService = tokenService;
            _smsService = smsService;
        }

        public async Task<Response<string>> RegisterAsync(RegisterRequest request)
        {
            var validationResult = await DoValidationAsync<RegisterRequest, string>(request, _registerValidator);
            if (validationResult != null) return validationResult;

            var existingUser = await _userRepository.GetTableNoTracking().FirstOrDefaultAsync(x => x.Email == request.Email);
            if (existingUser != null)
                return Response<string>.Failure("Email already exists");

            string passwordHash = _passwordHasher.HashPassword(request.Password);

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
            if (user == null || !_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
                return Response<AuthResponse>.Failure("Invalid credentials");

            var authResponse = await _tokenService.GenerateTokensAsync(user);

            return Response<AuthResponse>.Success(authResponse);
        }

        public async Task<Response<string>> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            // Placeholder logic until email service is fully implemented
            return Response<string>.Success("Reset password link sent (simulated)");
        }

        public async Task<Response<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request)
        {
             // Placeholder logic until refresh token strategy is finalized
            var dummyResponse = new AuthResponse { AccessToken = "new_dummy_token", RefreshToken = "new_dummy_refresh" };
            return Response<AuthResponse>.Success(dummyResponse);
        }

        public async Task<Response<string>> ResetPasswordAsync(ResetPasswordRequest request)
        {
            // Placeholder logic 
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
                            PasswordHash = _passwordHasher.HashPassword(Guid.NewGuid().ToString()), // Secure random password
                            DateOfBirth = DateTime.UtcNow, 
                            Gender = Gender.Other
                        };

                        await _userRepository.AddAsync(user);
                        await _unitOfWork.CompleteAsync();
                    }

                    var authResponse = await _tokenService.GenerateTokensAsync(user);
                    return Response<AuthResponse>.Success(authResponse);

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
            // Placeholder logic
            return Response<string>.Success("Email verified successfully");
        }
        
        public async Task<Response<string>> RequestOtpAsync(OtpRequest request)
        {
            var requestKey = $"otp_req_{request.PhoneNumber}";
            if (_cache.TryGetValue(requestKey, out int attempts) && attempts >= 3)
            {
                return Response<string>.Failure("Too many requests. Please wait 10 minutes.");
            }

            var result = await _smsService.SendVerificationAsync(request.PhoneNumber, request.Channel);

            if (result.Success)
            {
                _cache.Set(requestKey, attempts + 1, TimeSpan.FromMinutes(10));
                return Response<string>.Success(result.Message); // e.g. "pending"
            }
            else
            {
                return Response<string>.Failure(result.Message);
            }
        }

        public async Task<Response<string>> VerifyOtpAsync(OtpVerifyRequest request)
        {
            var lockoutKey = $"otp_lock_{request.PhoneNumber}";
            if (_cache.TryGetValue(lockoutKey, out int failedAttempts) && failedAttempts >= 5)
            {
                return Response<string>.Failure("Account temporarily locked due to multiple failed attempts. Try again in 15 minutes.");
            }

            var result = await _smsService.VerifyCodeAsync(request.PhoneNumber, request.Code);

            if (result.Success)
            {
                _cache.Remove(lockoutKey);
                return Response<string>.Success("Verification successful");
            }
            else
            {
                _cache.Set(lockoutKey, failedAttempts + 1, TimeSpan.FromMinutes(15));
                return Response<string>.Failure(result.Message); // e.g., "Invalid code"
            }
        }
    }
}
