using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Domain.Entities;

using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Application.Features.Friends.DTOs;

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
        Task<Response<List<UserDto>>> GetFriendsListAsync(int userId);
        Task<Response<List<FriendshipDto>>> GetReceivedRequestsAsync(int userId);
        Task<Response<List<FriendshipDto>>> GetSentRequestsAsync(int userId);
        Task<Response<List<UserDto>>> GetFriendSuggestionsAsync(int userId);

        // Following
        Task<Response<string>> FollowUserAsync(int followerId, int followingId);
        Task<Response<string>> UnfollowUserAsync(int followerId, int followingId);
        Task<Response<List<UserDto>>> GetFollowersAsync(int userId);
        Task<Response<List<UserDto>>> GetFollowingAsync(int userId);
    }
}
