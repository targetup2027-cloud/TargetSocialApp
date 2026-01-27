using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Privacy;
using TargetSocialApp.Application.Features.Privacy.Requests;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api")]
    public class PrivacyController : ControllerBase
    {
        private readonly IPrivacyService _privacyService;

        public PrivacyController(IPrivacyService privacyService)
        {
            _privacyService = privacyService;
        }

        [HttpGet("privacy/settings")]
        public async Task<IActionResult> GetSettings()
        {
            int userId = 1;
            var response = await _privacyService.GetPrivacySettingsAsync(userId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("privacy/settings")]
        public async Task<IActionResult> UpdateSettings([FromBody] UpdatePrivacySettingsRequest request)
        {
            int userId = 1;
            var response = await _privacyService.UpdatePrivacySettingsAsync(userId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("users/{userId}/block")]
        public async Task<IActionResult> BlockUser(int userId)
        {
            int currentUserId = 1;
            var response = await _privacyService.BlockUserAsync(currentUserId, userId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("users/{userId}/unblock")]
        public async Task<IActionResult> UnblockUser(int userId)
        {
            int currentUserId = 1;
            var response = await _privacyService.UnblockUserAsync(currentUserId, userId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("users/blocked")]
        public async Task<IActionResult> GetBlockedUsers()
        {
            int currentUserId = 1;
            var response = await _privacyService.GetBlockedUsersAsync(currentUserId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("auth/change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            int currentUserId = 1;
            var response = await _privacyService.ChangePasswordAsync(currentUserId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("auth/enable-2fa")]
        public async Task<IActionResult> Enable2FA()
        {
            int currentUserId = 1;
            var response = await _privacyService.Enable2FAAsync(currentUserId);
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
