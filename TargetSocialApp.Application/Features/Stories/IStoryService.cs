using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Stories.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Stories
{
    public interface IStoryService
    {
        Task<Response<Story>> CreateStoryAsync(int userId, CreateStoryRequest request);
        Task<Response<List<Story>>> GetFriendsStoriesAsync(int userId); // Active stories
        Task<Response<Story>> GetStoryByIdAsync(int storyId);
        Task<Response<string>> DeleteStoryAsync(int userId, int storyId);
        
        Task<Response<string>> ViewStoryAsync(int userId, int storyId);
        Task<Response<List<User>>> GetStoryViewersAsync(int userId, int storyId); // Check ownership

        // Highlights
        Task<Response<StoryHighlight>> CreateHighlightAsync(int userId, CreateHighlightRequest request);
        Task<Response<StoryHighlight>> UpdateHighlightAsync(int userId, int highlightId, CreateHighlightRequest request);
        Task<Response<List<StoryHighlight>>> GetUserHighlightsAsync(int userId);
        Task<Response<string>> DeleteHighlightAsync(int userId, int highlightId);
    }
}
