using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Friends
{
    public class FriendService : AppService, IFriendService
    {
        private readonly IGenericRepository<Friendship> _friendshipRepository;
        private readonly IGenericRepository<Following> _followingRepository;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IUnitOfWork _unitOfWork;

        public FriendService(
            IGenericRepository<Friendship> friendshipRepository,
            IGenericRepository<Following> followingRepository,
            IGenericRepository<User> userRepository,
            IUnitOfWork unitOfWork)
        {
            _friendshipRepository = friendshipRepository;
            _followingRepository = followingRepository;
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<string>> AcceptFriendRequestAsync(int userId, int requestId)
        {
            var friendship = await _friendshipRepository.GetByIdAsync(requestId);
            if (friendship == null) return Response<string>.Failure("Request not found");
            
            if (friendship.ReceiverId != userId) return Response<string>.Failure("Unauthorized");

            friendship.Status = FriendshipStatus.Accepted;
            await _friendshipRepository.UpdateAsync(friendship);
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Friend request accepted");
        }

        public async Task<Response<string>> CancelFriendRequestAsync(int userId, int requestId)
        {
            var friendship = await _friendshipRepository.GetByIdAsync(requestId);
            if (friendship == null) return Response<string>.Failure("Request not found");
            
            if (friendship.RequesterId != userId) return Response<string>.Failure("Unauthorized"); // User canceling their own request

            await _friendshipRepository.DeleteAsync(friendship);
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Request canceled");
        }

        public async Task<Response<string>> FollowUserAsync(int followerId, int followingId)
        {
             if (followerId == followingId) return Response<string>.Failure("Cannot follow self");

             var exists = await _followingRepository.GetTableNoTracking()
                 .AnyAsync(f => f.FollowerId == followerId && f.FollowingId == followingId);
             
             if (exists) return Response<string>.Success("Already following");

             await _followingRepository.AddAsync(new Following
             {
                 FollowerId = followerId,
                 FollowingId = followingId
             });
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Followed successfully");
        }

        public async Task<Response<List<User>>> GetFollowersAsync(int userId)
        {
             var followers = await _followingRepository.GetTableNoTracking()
                 .Where(f => f.FollowingId == userId)
                 .Include(f => f.Follower)
                 .Select(f => f.Follower)
                 .ToListAsync();
             return Response<List<User>>.Success(followers);
        }

        public async Task<Response<List<User>>> GetFollowingAsync(int userId)
        {
             var followings = await _followingRepository.GetTableNoTracking()
                 .Where(f => f.FollowerId == userId)
                 .Include(f => f.FollowingUser)
                 .Select(f => f.FollowingUser)
                 .ToListAsync();
             return Response<List<User>>.Success(followings);
        }

        public async Task<Response<List<User>>> GetFriendsListAsync(int userId)
        {
             var friendships = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => (f.RequesterId == userId || f.ReceiverId == userId) && f.Status == FriendshipStatus.Accepted)
                 .Include(f => f.Requester)
                 .Include(f => f.Receiver)
                 .ToListAsync();

             var friends = friendships
                 .Select(f => f.RequesterId == userId ? f.Receiver : f.Requester)
                 .ToList();

             return Response<List<User>>.Success(friends);
        }

        public async Task<Response<List<User>>> GetFriendSuggestionsAsync(int userId)
        {
             // Very basic Suggestion: Users not friends and not self
             // In real world: Mutual friends algo
             var friendsIds = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => (f.RequesterId == userId || f.ReceiverId == userId))
                 .Select(f => f.RequesterId == userId ? f.ReceiverId : f.RequesterId)
                 .ToListAsync();
             
             friendsIds.Add(userId); // Exclude self

             var suggestions = await _userRepository.GetTableNoTracking()
                 .Where(u => !friendsIds.Contains(u.Id))
                 .Take(10)
                 .ToListAsync();
             
             return Response<List<User>>.Success(suggestions);
        }

        public async Task<Response<List<Friendship>>> GetReceivedRequestsAsync(int userId)
        {
             var requests = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => f.ReceiverId == userId && f.Status == FriendshipStatus.Pending)
                 .Include(f => f.Requester) // Include sender details
                 .ToListAsync();
             return Response<List<Friendship>>.Success(requests);
        }

        public async Task<Response<List<Friendship>>> GetSentRequestsAsync(int userId)
        {
             var requests = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => f.RequesterId == userId && f.Status == FriendshipStatus.Pending)
                 .Include(f => f.Receiver)
                 .ToListAsync();
             return Response<List<Friendship>>.Success(requests);
        }

        public async Task<Response<string>> RejectFriendRequestAsync(int userId, int requestId)
        {
            var friendship = await _friendshipRepository.GetByIdAsync(requestId);
            if (friendship == null) return Response<string>.Failure("Request not found");
            
            if (friendship.ReceiverId != userId) return Response<string>.Failure("Unauthorized");

            friendship.Status = FriendshipStatus.Rejected;
            await _friendshipRepository.UpdateAsync(friendship); // Or delete based on business rule
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Request rejected");
        }

        public async Task<Response<string>> SendFriendRequestAsync(int requesterId, int receiverId)
        {
            if (requesterId == receiverId) return Response<string>.Failure("Cannot friend self");

            var existing = await _friendshipRepository.GetTableNoTracking()
                .FirstOrDefaultAsync(f => 
                    (f.RequesterId == requesterId && f.ReceiverId == receiverId) ||
                    (f.RequesterId == receiverId && f.ReceiverId == requesterId));
            
            if (existing != null)
            {
                if (existing.Status == FriendshipStatus.Accepted) return Response<string>.Success("Already friends");
                if (existing.Status == FriendshipStatus.Pending && existing.RequesterId == requesterId) return Response<string>.Success("Request already sent");
                if (existing.Status == FriendshipStatus.Blocked) return Response<string>.Failure("Cannot add friend");
            }

            await _friendshipRepository.AddAsync(new Friendship
            {
                RequesterId = requesterId,
                ReceiverId = receiverId,
                Status = FriendshipStatus.Pending
            });
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Friend request sent");
        }

        public async Task<Response<string>> UnfollowUserAsync(int followerId, int followingId)
        {
             var following = await _followingRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(f => f.FollowerId == followerId && f.FollowingId == followingId);
             
             if (following == null) return Response<string>.Failure("Not following");

             await _followingRepository.DeleteAsync(following);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Unfollowed");
        }

        public async Task<Response<string>> UnfriendAsync(int userId, int targetUserId)
        {
             var friendship = await _friendshipRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(f => 
                     (f.RequesterId == userId && f.ReceiverId == targetUserId) ||
                     (f.RequesterId == targetUserId && f.ReceiverId == userId));
             
             if (friendship == null) return Response<string>.Failure("Friendship not found");

             await _friendshipRepository.DeleteAsync(friendship);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Unfriended");
        }
    }
}
