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
using Twilio;
using Twilio.Rest.Verify.V2.Service;
using Twilio.Exceptions;

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

        public AuthService(
            IUnitOfWork unitOfWork,
            IGenericRepository<User> userRepository,
            IValidator<RegisterRequest> registerValidator,
            IValidator<LoginRequest> loginValidator,
            IConfiguration configuration,
            IMemoryCache cache)
        {
            _unitOfWork = unitOfWork;
            _userRepository = userRepository;
            _registerValidator = registerValidator;
            _loginValidator = loginValidator;
            _configuration = configuration;
            _cache = cache;
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
        public async Task<Response<string>> RequestOtpAsync(OtpRequest request)
        {
            var accountSid = _configuration["Authentication:Twilio:AccountSid"];
            var authToken = _configuration["Authentication:Twilio:AuthToken"];
            var serviceSid = _configuration["Authentication:Twilio:ServiceSid"];

            var requestKey = $"otp_req_{request.PhoneNumber}";
            if (_cache.TryGetValue(requestKey, out int attempts) && attempts >= 3)
            {
                return Response<string>.Failure("Too many requests. Please wait 10 minutes.");
            }

            try
            {
                TwilioClient.Init(accountSid, authToken);

                var verification = await VerificationResource.CreateAsync(
                    to: request.PhoneNumber,
                    channel: request.Channel,
                    pathServiceSid: serviceSid
                );

                _cache.Set(requestKey, attempts + 1, TimeSpan.FromMinutes(10));

                return Response<string>.Success(verification.Status);
            }
            catch (TwilioException ex)
            {
                return Response<string>.Failure(ex.Message);
            }
            catch (Exception ex)
            {
                return Response<string>.Failure($"An error occurred: {ex.Message}");
            }
        }

        public async Task<Response<string>> VerifyOtpAsync(OtpVerifyRequest request)
        {
            var accountSid = _configuration["Authentication:Twilio:AccountSid"];
            var authToken = _configuration["Authentication:Twilio:AuthToken"];
            var serviceSid = _configuration["Authentication:Twilio:ServiceSid"];

            var lockoutKey = $"otp_lock_{request.PhoneNumber}";
            if (_cache.TryGetValue(lockoutKey, out int failedAttempts) && failedAttempts >= 5)
            {
                return Response<string>.Failure("Account temporarily locked due to multiple failed attempts. Try again in 15 minutes.");
            }

            try
            {
                TwilioClient.Init(accountSid, authToken);

                var verificationCheck = await VerificationCheckResource.CreateAsync(
                    to: request.PhoneNumber,
                    code: request.Code,
                    pathServiceSid: serviceSid
                );

                if (verificationCheck.Status == "approved")
                {
                    _cache.Remove(lockoutKey);
                    return Response<string>.Success("Verification successful");
                }
                else
                {
                    _cache.Set(lockoutKey, failedAttempts + 1, TimeSpan.FromMinutes(15));
                    return Response<string>.Failure("Invalid code");
                }
            }
            catch (TwilioException ex)
            {
                return Response<string>.Failure(ex.Message);
            }
            catch (Exception ex)
            {
                return Response<string>.Failure($"An error occurred: {ex.Message}");
            }
        }
    }
}
