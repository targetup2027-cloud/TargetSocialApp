using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Search;

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
            return Ok(response);
        }

        [HttpGet("users")]
        public async Task<IActionResult> SearchUsers([FromQuery] string query)
        {
            var response = await _searchService.SearchUsersAsync(query);
            return Ok(response);
        }

        [HttpGet("posts")]
        public async Task<IActionResult> SearchPosts([FromQuery] string query)
        {
            var response = await _searchService.SearchPostsAsync(query);
            return Ok(response);
        }

        [HttpGet("hashtags")]
        public async Task<IActionResult> SearchHashtags([FromQuery] string query)
        {
            var response = await _searchService.SearchHashtagsAsync(query);
            return Ok(response);
        }

        [HttpGet("suggestions")]
        public async Task<IActionResult> GetSuggestions([FromQuery] string query)
        {
            var response = await _searchService.GetSuggestionsAsync(query);
            return Ok(response);
        }

        [HttpGet("trending")]
        public async Task<IActionResult> GetTrending()
        {
            var response = await _searchService.GetTrendingPostsAsync();
            return Ok(response);
        }
    }
}
