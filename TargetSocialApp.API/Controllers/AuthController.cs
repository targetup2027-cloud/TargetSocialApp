using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Auth;
using TargetSocialApp.Application.Features.Auth.Requests;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var response = await _authService.RegisterAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var response = await _authService.LoginAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            var response = await _authService.RefreshTokenAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var response = await _authService.ForgotPasswordAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var response = await _authService.ResetPasswordAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailRequest request)
        {
            var response = await _authService.VerifyEmailAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleLogin([FromBody] SocialLoginRequest request)
        {
            request.Provider = "Google";
            var response = await _authService.SocialLoginAsync(request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

      
        [HttpPost("otp/request")]
        public async Task<IActionResult> RequestOtp([FromBody] OtpRequest request)
        {
            var response = await _authService.RequestOtpAsync(request);
            if (!response.Succeeded)
            {
                if (response.Message.Contains("Too many requests") || response.Message.Contains("locked"))
                    return StatusCode(429, ApiResponseWrapper.Create(response, 429));

                return BadRequest(ApiResponseWrapper.Create(response, 400));
            }
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("otp/verify")]
        public async Task<IActionResult> VerifyOtp([FromBody] OtpVerifyRequest request)
        {
            var response = await _authService.VerifyOtpAsync(request);
            if (!response.Succeeded)
            {
                if (response.Message.Contains("locked"))
                    return StatusCode(429, ApiResponseWrapper.Create(response, 429));

                return BadRequest(ApiResponseWrapper.Create(response, 400));
            }
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
