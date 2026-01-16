using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Posts.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Posts
{
    public interface IPostService
    {
        // CRUD
        Task<Response<Post>> CreatePostAsync(int userId, CreatePostRequest request);
        Task<Response<Post>> GetPostByIdAsync(int postId);
        Task<Response<Post>> UpdatePostAsync(int userId, int postId, UpdatePostRequest request);
        Task<Response<string>> DeletePostAsync(int userId, int postId);

        // Feed
        Task<Response<List<Post>>> GetFeedAsync(int userId);
        Task<Response<List<Post>>> GetFriendsFeedAsync(int userId);
        Task<Response<List<Post>>> GetFollowingFeedAsync(int userId);
        Task<Response<List<Post>>> GetUserPostsAsync(int userId); // For User Profile

        // Actions
        Task<Response<string>> LikePostAsync(int userId, int postId); // Simplified Toggle
        Task<Response<string>> ReactToPostAsync(int userId, int postId, PostReactionRequest request);
        Task<Response<List<PostReaction>>> GetPostReactionsAsync(int postId);
        Task<Response<string>> SharePostAsync(int userId, int postId); 
        Task<Response<string>> SavePostAsync(int userId, int postId);
        Task<Response<string>> UnsavePostAsync(int userId, int postId);
        Task<Response<List<Post>>> GetSavedPostsAsync(int userId);

        // Media
        Task<Response<string>> UploadMediaAsync(UploadPostMediaRequest request);
    }
}
