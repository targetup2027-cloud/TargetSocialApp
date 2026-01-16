using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Friends;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    public class FriendsController : ControllerBase
    {
        private readonly IFriendService _friendService;

        public FriendsController(IFriendService friendService)
        {
            _friendService = friendService;
        }

        [HttpPost("api/friends/request/{receiverId}")]
        public async Task<IActionResult> SendRequest(int receiverId)
        {
            int requesterId = 1; // Claims
            var response = await _friendService.SendFriendRequestAsync(requesterId, receiverId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPut("api/friends/accept/{requestId}")]
        public async Task<IActionResult> AcceptRequest(int requestId)
        {
            int userId = 1;
            var response = await _friendService.AcceptFriendRequestAsync(userId, requestId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPut("api/friends/reject/{requestId}")]
        public async Task<IActionResult> RejectRequest(int requestId)
        {
            int userId = 1;
            var response = await _friendService.RejectFriendRequestAsync(userId, requestId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpDelete("api/friends/cancel/{requestId}")]
        public async Task<IActionResult> CancelRequest(int requestId)
        {
            int userId = 1;
            var response = await _friendService.CancelFriendRequestAsync(userId, requestId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpDelete("api/friends/{targetUserId}")]
        public async Task<IActionResult> Unfriend(int targetUserId)
        {
            int userId = 1;
            var response = await _friendService.UnfriendAsync(userId, targetUserId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpGet("api/friends")]
        public async Task<IActionResult> GetFriends()
        {
            int userId = 1;
            var response = await _friendService.GetFriendsListAsync(userId);
            return Ok(response);
        }

        [HttpGet("api/friends/requests")]
        public async Task<IActionResult> GetReceivedRequests()
        {
            int userId = 1;
            var response = await _friendService.GetReceivedRequestsAsync(userId);
            return Ok(response);
        }

        [HttpGet("api/friends/sent-requests")]
        public async Task<IActionResult> GetSentRequests()
        {
            int userId = 1;
            var response = await _friendService.GetSentRequestsAsync(userId);
            return Ok(response);
        }

        [HttpGet("api/friends/suggestions")]
        public async Task<IActionResult> GetSuggestions()
        {
            int userId = 1;
            var response = await _friendService.GetFriendSuggestionsAsync(userId);
            return Ok(response);
        }

        [HttpPost("api/users/{userId}/follow")]
        public async Task<IActionResult> FollowUser(int userId)
        {
            int followerId = 1; 
            var response = await _friendService.FollowUserAsync(followerId, userId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpDelete("api/users/{userId}/unfollow")]
        public async Task<IActionResult> UnfollowUser(int userId)
        {
            int followerId = 1;
            var response = await _friendService.UnfollowUserAsync(followerId, userId);
            return Ok(response);
        }

        [HttpGet("api/users/{userId}/followers")]
        public async Task<IActionResult> GetFollowers(int userId)
        {
            var response = await _friendService.GetFollowersAsync(userId);
            return Ok(response);
        }

        [HttpGet("api/users/{userId}/following")]
        public async Task<IActionResult> GetFollowing(int userId)
        {
            var response = await _friendService.GetFollowingAsync(userId);
            return Ok(response);
        }
    }
}
