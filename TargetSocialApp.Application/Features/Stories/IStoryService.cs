using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Stories.Requests;
using TargetSocialApp.Domain.Entities;

using TargetSocialApp.Application.Features.Stories.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;

namespace TargetSocialApp.Application.Features.Stories
{
    public interface IStoryService
    {
        Task<Response<StoryDto>> CreateStoryAsync(int userId, CreateStoryRequest request);
        Task<Response<List<StoryDto>>> GetFriendsStoriesAsync(int userId); // Active stories
        Task<Response<StoryDto>> GetStoryByIdAsync(int storyId);
        Task<Response<string>> DeleteStoryAsync(int userId, int storyId);
        
        Task<Response<string>> ViewStoryAsync(int userId, int storyId);
        Task<Response<List<UserDto>>> GetStoryViewersAsync(int userId, int storyId); // Check ownership

        // Highlights
        Task<Response<StoryHighlightDto>> CreateHighlightAsync(int userId, CreateHighlightRequest request);
        Task<Response<StoryHighlightDto>> UpdateHighlightAsync(int userId, int highlightId, CreateHighlightRequest request);
        Task<Response<List<StoryHighlightDto>>> GetUserHighlightsAsync(int userId);
        Task<Response<string>> DeleteHighlightAsync(int userId, int highlightId);
    }
}
