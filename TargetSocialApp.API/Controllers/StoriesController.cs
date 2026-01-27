using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Stories;
using TargetSocialApp.Application.Features.Stories.Requests;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    public class StoriesController : ControllerBase
    {
        private readonly IStoryService _storyService;

        public StoriesController(IStoryService storyService)
        {
            _storyService = storyService;
        }

        [HttpPost("api/stories")]
        public async Task<IActionResult> CreateStory([FromForm] CreateStoryRequest request)
        {
            int userId = 1; 
            var response = await _storyService.CreateStoryAsync(userId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/stories")]
        public async Task<IActionResult> GetStories()
        {
            int userId = 1;
            var response = await _storyService.GetFriendsStoriesAsync(userId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/stories/{storyId}")]
        public async Task<IActionResult> GetStory(int storyId)
        {
            var response = await _storyService.GetStoryByIdAsync(storyId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("api/stories/{storyId}")]
        public async Task<IActionResult> DeleteStory(int storyId)
        {
            int userId = 1;
            var response = await _storyService.DeleteStoryAsync(userId, storyId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("api/stories/{storyId}/view")]
        public async Task<IActionResult> ViewStory(int storyId)
        {
            int userId = 1; 
            var response = await _storyService.ViewStoryAsync(userId, storyId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/stories/{storyId}/viewers")]
        public async Task<IActionResult> GetViewers(int storyId)
        {
            int userId = 1;
            var response = await _storyService.GetStoryViewersAsync(userId, storyId);
            if (!response.Succeeded) return Unauthorized(ApiResponseWrapper.Create(response, 401));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("api/stories/highlights")]
        public async Task<IActionResult> CreateHighlight([FromForm] CreateHighlightRequest request)
        {
            int userId = 1;
            var response = await _storyService.CreateHighlightAsync(userId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("api/stories/highlights/{highlightId}")]
        public async Task<IActionResult> UpdateHighlight(int highlightId, [FromForm] CreateHighlightRequest request)
        {
            int userId = 1;
            var response = await _storyService.UpdateHighlightAsync(userId, highlightId, request);
            if(!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/users/{userId}/highlights")]
        public async Task<IActionResult> GetUserHighlights(int userId)
        {
            var response = await _storyService.GetUserHighlightsAsync(userId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("api/stories/highlights/{highlightId}")]
        public async Task<IActionResult> DeleteHighlight(int highlightId)
        {
            int userId = 1;
            var response = await _storyService.DeleteHighlightAsync(userId, highlightId);
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
