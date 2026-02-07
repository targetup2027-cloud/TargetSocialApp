using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Search;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService _searchService;

        public SearchController(ISearchService searchService)
        {
            _searchService = searchService;
        }

        [HttpGet]
        public async Task<IActionResult> Search([FromQuery] string query)
        {
            var response = await _searchService.SearchGeneralAsync(query);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("users")]
        public async Task<IActionResult> SearchUsers([FromQuery] string query)
        {
            var response = await _searchService.SearchUsersAsync(query);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("posts")]
        public async Task<IActionResult> SearchPosts([FromQuery] string query)
        {
            var response = await _searchService.SearchPostsAsync(query);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("hashtags")]
        public async Task<IActionResult> SearchHashtags([FromQuery] string query)
        {
            var response = await _searchService.SearchHashtagsAsync(query);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("suggestions")]
        public async Task<IActionResult> GetSuggestions([FromQuery] string query)
        {
            var response = await _searchService.GetSuggestionsAsync(query);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("trending")]
        public async Task<IActionResult> GetTrending()
        {
            var response = await _searchService.GetTrendingPostsAsync();
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
