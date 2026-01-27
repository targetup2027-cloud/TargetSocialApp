using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Friends.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
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
            
            if (friendship.RequesterId != userId) return Response<string>.Failure("Unauthorized"); 

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

        public async Task<Response<List<UserDto>>> GetFollowersAsync(int userId)
        {
             var followers = await _followingRepository.GetTableNoTracking()
                 .Where(f => f.FollowingId == userId)
                 .Select(f => new UserDto
                 {
                     Id = f.Follower.Id,
                     FirstName = f.Follower.FirstName,
                     LastName = f.Follower.LastName,
                     Email = f.Follower.Email,
                     PhoneNumber = f.Follower.PhoneNumber,
                     Bio = f.Follower.Bio,
                     AvatarUrl = f.Follower.AvatarUrl,
                     CoverPhotoUrl = f.Follower.CoverPhotoUrl,
                     IsEmailVerified = f.Follower.IsEmailVerified,
                     CreatedAt = f.Follower.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<UserDto>>.Success(followers);
        }

        public async Task<Response<List<UserDto>>> GetFollowingAsync(int userId)
        {
             var followings = await _followingRepository.GetTableNoTracking()
                 .Where(f => f.FollowerId == userId)
                 .Select(f => new UserDto
                 {
                     Id = f.FollowingUser.Id,
                     FirstName = f.FollowingUser.FirstName,
                     LastName = f.FollowingUser.LastName,
                     Email = f.FollowingUser.Email,
                     PhoneNumber = f.FollowingUser.PhoneNumber,
                     Bio = f.FollowingUser.Bio,
                     AvatarUrl = f.FollowingUser.AvatarUrl,
                     CoverPhotoUrl = f.FollowingUser.CoverPhotoUrl,
                     IsEmailVerified = f.FollowingUser.IsEmailVerified,
                     CreatedAt = f.FollowingUser.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<UserDto>>.Success(followings);
        }

        public async Task<Response<List<UserDto>>> GetFriendsListAsync(int userId)
        {
             // Complex selection: Need to pick the OTHER user.
             // EF Core Select can handle conditionals? yes.
             var friends = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => (f.RequesterId == userId || f.ReceiverId == userId) && f.Status == FriendshipStatus.Accepted)
                 .Select(f => f.RequesterId == userId ? 
                     new UserDto
                     {
                         Id = f.Receiver.Id,
                         FirstName = f.Receiver.FirstName,
                         LastName = f.Receiver.LastName,
                         Email = f.Receiver.Email,
                         PhoneNumber = f.Receiver.PhoneNumber,
                         Bio = f.Receiver.Bio,
                         AvatarUrl = f.Receiver.AvatarUrl,
                         CoverPhotoUrl = f.Receiver.CoverPhotoUrl,
                         IsEmailVerified = f.Receiver.IsEmailVerified,
                         CreatedAt = f.Receiver.CreatedAt
                     } : 
                     new UserDto
                     {
                         Id = f.Requester.Id,
                         FirstName = f.Requester.FirstName,
                         LastName = f.Requester.LastName,
                         Email = f.Requester.Email,
                         PhoneNumber = f.Requester.PhoneNumber,
                         Bio = f.Requester.Bio,
                         AvatarUrl = f.Requester.AvatarUrl,
                         CoverPhotoUrl = f.Requester.CoverPhotoUrl,
                         IsEmailVerified = f.Requester.IsEmailVerified,
                         CreatedAt = f.Requester.CreatedAt
                     })
                 .ToListAsync();

             return Response<List<UserDto>>.Success(friends);
        }

        public async Task<Response<List<UserDto>>> GetFriendSuggestionsAsync(int userId)
        {
             var friendsIds = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => (f.RequesterId == userId || f.ReceiverId == userId))
                 .Select(f => f.RequesterId == userId ? f.ReceiverId : f.RequesterId)
                 .ToListAsync();
             
             friendsIds.Add(userId); 

             var suggestions = await _userRepository.GetTableNoTracking()
                 .Where(u => !friendsIds.Contains(u.Id))
                 .Take(10)
                 .Select(u => new UserDto
                 {
                     Id = u.Id,
                     FirstName = u.FirstName,
                     LastName = u.LastName,
                     Email = u.Email,
                     PhoneNumber = u.PhoneNumber,
                     Bio = u.Bio,
                     AvatarUrl = u.AvatarUrl,
                     CoverPhotoUrl = u.CoverPhotoUrl,
                     IsEmailVerified = u.IsEmailVerified,
                     CreatedAt = u.CreatedAt
                 })
                 .ToListAsync();
             
             return Response<List<UserDto>>.Success(suggestions);
        }

        public async Task<Response<List<FriendshipDto>>> GetReceivedRequestsAsync(int userId)
        {
             var requests = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => f.ReceiverId == userId && f.Status == FriendshipStatus.Pending)
                 .Select(f => new FriendshipDto
                 {
                     Id = f.Id,
                     RequesterId = f.RequesterId,
                     RequesterName = f.Requester.FirstName + " " + f.Requester.LastName,
                     RequesterAvatarUrl = f.Requester.AvatarUrl,
                     ReceiverId = f.ReceiverId,
                     ReceiverName = f.Receiver.FirstName + " " + f.Receiver.LastName,
                     ReceiverAvatarUrl = f.Receiver.AvatarUrl,
                     Status = f.Status,
                     CreatedAt = f.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<FriendshipDto>>.Success(requests);
        }

        public async Task<Response<List<FriendshipDto>>> GetSentRequestsAsync(int userId)
        {
             var requests = await _friendshipRepository.GetTableNoTracking()
                 .Where(f => f.RequesterId == userId && f.Status == FriendshipStatus.Pending)
                 .Select(f => new FriendshipDto
                 {
                     Id = f.Id,
                     RequesterId = f.RequesterId,
                     RequesterName = f.Requester.FirstName + " " + f.Requester.LastName,
                     RequesterAvatarUrl = f.Requester.AvatarUrl,
                     ReceiverId = f.ReceiverId,
                     ReceiverName = f.Receiver.FirstName + " " + f.Receiver.LastName,
                     ReceiverAvatarUrl = f.Receiver.AvatarUrl,
                     Status = f.Status,
                     CreatedAt = f.CreatedAt
                 })
                 .ToListAsync();
             return Response<List<FriendshipDto>>.Success(requests);
        }

        public async Task<Response<string>> RejectFriendRequestAsync(int userId, int requestId)
        {
            var friendship = await _friendshipRepository.GetByIdAsync(requestId);
            if (friendship == null) return Response<string>.Failure("Request not found");
            
            if (friendship.ReceiverId != userId) return Response<string>.Failure("Unauthorized");

            friendship.Status = FriendshipStatus.Rejected;
            await _friendshipRepository.UpdateAsync(friendship); 
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
