using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Users;
using TargetSocialApp.Application.Features.Users.Requests;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUser(int userId)
        {
            var response = await _userService.GetUserByIdAsync(userId);
            if (!response.Succeeded) return NotFound(ApiResponseWrapper.Create(response, 404));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            // In real app, get UserId from User.Claims
            int currentUserId = 1; // Placeholder
            var response = await _userService.GetUserByIdAsync(currentUserId);
            if (!response.Succeeded) return NotFound(ApiResponseWrapper.Create(response, 404));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("me")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            int currentUserId = 1; // Claims
            var response = await _userService.UpdateProfileAsync(currentUserId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("me/avatar")]
        public async Task<IActionResult> UpdateAvatar([FromForm] UpdateAvatarRequest request)
        {
            int currentUserId = 1; 
            var response = await _userService.UpdateAvatarAsync(currentUserId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("me/cover")]
        public async Task<IActionResult> UpdateCover([FromForm] UpdateCoverRequest request)
        {
            int currentUserId = 1; 
            var response = await _userService.UpdateCoverAsync(currentUserId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("me/avatar")]
        public async Task<IActionResult> DeleteAvatar()
        {
            int currentUserId = 1; 
            var response = await _userService.DeleteAvatarAsync(currentUserId);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
