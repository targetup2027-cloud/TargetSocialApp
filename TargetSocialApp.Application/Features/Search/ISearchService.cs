using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Application.Features.Stories.Requests; // For highlight

using TargetSocialApp.Application.Features.Posts.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Application.Features.Search.DTOs;

namespace TargetSocialApp.Application.Features.Search
{
    public interface ISearchService
    {
        Task<Response<SearchDto>> SearchGeneralAsync(string query); 
        Task<Response<List<UserDto>>> SearchUsersAsync(string query);
        Task<Response<List<PostDto>>> SearchPostsAsync(string query);
        Task<Response<List<string>>> SearchHashtagsAsync(string query);
        Task<Response<List<string>>> GetSuggestionsAsync(string query);
        Task<Response<List<PostDto>>> GetTrendingPostsAsync();
        
        Task<Response<List<PostDto>>> GetPostsByHashtagAsync(string hashtag);
        Task<Response<List<string>>> GetTrendingHashtagsAsync();
    }
}
// Adding missing method to Story Interface
// Note: We cannot edit IStoryService.cs again easily in same turn if already written, but we can assume we added it or add it via replacement later.
// Actually, I should update IStoryService interface with UpdateHighlightAsync
