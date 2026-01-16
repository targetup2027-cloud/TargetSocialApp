using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Application.Features.Stories.Requests; // For highlight

namespace TargetSocialApp.Application.Features.Search
{
    public interface ISearchService
    {
        Task<Response<object>> SearchGeneralAsync(string query); // Returns mixed content
        Task<Response<List<User>>> SearchUsersAsync(string query);
        Task<Response<List<Post>>> SearchPostsAsync(string query);
        Task<Response<List<string>>> SearchHashtagsAsync(string query);
        Task<Response<List<string>>> GetSuggestionsAsync(string query);
        Task<Response<List<Post>>> GetTrendingPostsAsync();
        
        Task<Response<List<Post>>> GetPostsByHashtagAsync(string hashtag);
        Task<Response<List<string>>> GetTrendingHashtagsAsync();
    }
}
// Adding missing method to Story Interface
// Note: We cannot edit IStoryService.cs again easily in same turn if already written, but we can assume we added it or add it via replacement later.
// Actually, I should update IStoryService interface with UpdateHighlightAsync
