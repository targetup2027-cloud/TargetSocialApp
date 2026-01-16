using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Friends
{
    public interface IFriendService
    {
        // Friend Requests
        Task<Response<string>> SendFriendRequestAsync(int requesterId, int receiverId);
        Task<Response<string>> AcceptFriendRequestAsync(int userId, int requestId);
        Task<Response<string>> RejectFriendRequestAsync(int userId, int requestId);
        Task<Response<string>> CancelFriendRequestAsync(int userId, int requestId);
        Task<Response<string>> UnfriendAsync(int userId, int targetUserId);

        // Lists
        Task<Response<List<User>>> GetFriendsListAsync(int userId);
        Task<Response<List<Friendship>>> GetReceivedRequestsAsync(int userId);
        Task<Response<List<Friendship>>> GetSentRequestsAsync(int userId);
        Task<Response<List<User>>> GetFriendSuggestionsAsync(int userId);

        // Following
        Task<Response<string>> FollowUserAsync(int followerId, int followingId);
        Task<Response<string>> UnfollowUserAsync(int followerId, int followingId);
        Task<Response<List<User>>> GetFollowersAsync(int userId);
        Task<Response<List<User>>> GetFollowingAsync(int userId);
    }
}
