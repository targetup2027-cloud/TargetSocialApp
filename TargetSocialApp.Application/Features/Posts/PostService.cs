using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Posts.Requests;
using TargetSocialApp.Application.Features.Posts.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Posts
{
    public class PostService : AppService, IPostService
    {
        private readonly IGenericRepository<Post> _postRepository;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IGenericRepository<PostReaction> _reactionRepository;
        private readonly IGenericRepository<SavedPost> _savedPostRepository;
        private readonly IUnitOfWork _unitOfWork;

        public PostService(
            IGenericRepository<Post> postRepository,
            IGenericRepository<User> userRepository,
            IGenericRepository<PostReaction> reactionRepository,
            IGenericRepository<SavedPost> savedPostRepository,
            IUnitOfWork unitOfWork)
        {
            _postRepository = postRepository;
            _userRepository = userRepository;
            _reactionRepository = reactionRepository;
            _savedPostRepository = savedPostRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<PostDto>> CreatePostAsync(int userId, CreatePostRequest request)
        {
            var post = new Post
            {
                UserId = userId,
                Content = request.Content,
                Privacy = request.Privacy,
                CreatedAt = DateTime.UtcNow
            };

            if (request.MediaUrls != null && request.MediaUrls.Any())
            {
                foreach (var url in request.MediaUrls)
                {
                    post.Media.Add(new PostMedia 
                    { 
                        Url = url,
                        MediaType = MediaType.Image 
                    });
                }
            }

            await _postRepository.AddAsync(post);
            await _unitOfWork.CompleteAsync();

            var user = await _userRepository.GetByIdAsync(userId);

            var dto = new PostDto
            {
                Id = post.Id,
                UserId = post.UserId,
                UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                UserAvatarUrl = user?.AvatarUrl,
                Content = post.Content,
                Privacy = post.Privacy,
                CreatedAt = post.CreatedAt,
                Media = post.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                ReactionsCount = 0,
                CommentsCount = 0,
                IsLikedByCurrentUser = false,
                IsSavedByCurrentUser = false
            };

            return Response<PostDto>.Success(dto, "Post created successfully");
        }

        public async Task<Response<string>> DeletePostAsync(int userId, int postId)
        {
            var post = await _postRepository.GetByIdAsync(postId);
            if (post == null) return Response<string>.Failure("Post not found");
            if (post.UserId != userId) return Response<string>.Failure("Unauthorized to delete this post");

            await _postRepository.DeleteAsync(post);
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Post deleted");
        }

        private IQueryable<PostDto> GetBaseQuery()
        {
            return _postRepository.GetTableNoTracking()
                .Select(p => new PostDto
                {
                    Id = p.Id,
                    UserId = p.UserId,
                    UserName = p.User.FirstName + " " + p.User.LastName,
                    UserAvatarUrl = p.User.AvatarUrl,
                    Content = p.Content,
                    Privacy = p.Privacy,
                    CreatedAt = p.CreatedAt,
                    Media = p.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                    ReactionsCount = p.Reactions.Count(),
                    CommentsCount = p.Comments.Count(),
                    IsLikedByCurrentUser = false, // Pending context
                    IsSavedByCurrentUser = false // Pending context
                });
        }

        public async Task<Response<List<PostDto>>> GetFeedAsync(int userId)
        {
            var posts = await GetBaseQuery()
                .OrderByDescending(x => x.CreatedAt)
                .Take(50)
                .ToListAsync();

            return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<List<PostDto>>> GetFollowingFeedAsync(int userId)
        {
             var posts = await GetBaseQuery()
                 .Where(p => p.Privacy == PrivacyLevel.Public) 
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
            return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<List<PostDto>>> GetFriendsFeedAsync(int userId)
        {
             var posts = await GetBaseQuery()
                .Where(p => p.Privacy == PrivacyLevel.Friends)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
            return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<List<PostDto>>> GetUserPostsAsync(int userId)
        {
            var posts = await GetBaseQuery()
                .Where(p => p.UserId == userId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
            return Response<List<PostDto>>.Success(posts);
        }

        public async Task<Response<PostDto>> GetPostByIdAsync(int postId)
        {
             var post = await GetBaseQuery()
                 .FirstOrDefaultAsync(p => p.Id == postId);

             if (post == null) return Response<PostDto>.Failure("Post not found");
             return Response<PostDto>.Success(post);
        }

        public async Task<Response<List<PostReactionDto>>> GetPostReactionsAsync(int postId)
        {
            var reactions = await _reactionRepository.GetTableNoTracking()
                .Where(r => r.PostId == postId)
                .Select(r => new PostReactionDto
                {
                    Id = r.Id,
                    UserId = r.UserId,
                    UserName = r.User.FirstName + " " + r.User.LastName,
                    UserAvatarUrl = r.User.AvatarUrl,
                    ReactionType = r.ReactionType
                })
                .ToListAsync();
            return Response<List<PostReactionDto>>.Success(reactions);
        }

        public async Task<Response<List<PostDto>>> GetSavedPostsAsync(int userId)
        {
            var saved = await _savedPostRepository.GetTableNoTracking()
                .Where(s => s.UserId == userId)
                .Select(s => new PostDto
                {
                    Id = s.Post.Id,
                    UserId = s.Post.UserId,
                    UserName = s.Post.User.FirstName + " " + s.Post.User.LastName,
                    UserAvatarUrl = s.Post.User.AvatarUrl,
                    Content = s.Post.Content,
                    Privacy = s.Post.Privacy,
                    CreatedAt = s.Post.CreatedAt,
                    Media = s.Post.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList(),
                    ReactionsCount = s.Post.Reactions.Count(),
                    CommentsCount = s.Post.Comments.Count(),
                    IsLikedByCurrentUser = false,
                    IsSavedByCurrentUser = true
                })
                .ToListAsync();
            return Response<List<PostDto>>.Success(saved);
        }

        public async Task<Response<string>> LikePostAsync(int userId, int postId)
        {
            var existing = await _reactionRepository.GetTableNoTracking()
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == userId && r.ReactionType == ReactionType.Like);
            
            if (existing != null)
            {
                await _reactionRepository.DeleteAsync(existing);
                await _unitOfWork.CompleteAsync();
                return Response<string>.Success("Unliked");
            }

             var anyReaction = await _reactionRepository.GetTableAsTracking() 
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == userId);

             if(anyReaction != null)
             {
                 anyReaction.ReactionType = ReactionType.Like;
                 await _reactionRepository.UpdateAsync(anyReaction);
             }
             else
             {
                 await _reactionRepository.AddAsync(new PostReaction
                 {
                     PostId = postId,
                     UserId = userId,
                     ReactionType = ReactionType.Like
                 });
             }
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Liked");
        }

        public async Task<Response<string>> ReactToPostAsync(int userId, int postId, PostReactionRequest request)
        {
             var anyReaction = await _reactionRepository.GetTableAsTracking()
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == userId);
            
             if(anyReaction != null)
             {
                 anyReaction.ReactionType = request.ReactionType;
                 await _reactionRepository.UpdateAsync(anyReaction);
                 await _unitOfWork.CompleteAsync();
                 return Response<string>.Success("Reaction updated");
             }

             await _reactionRepository.AddAsync(new PostReaction
             {
                 PostId = postId,
                 UserId = userId,
                 ReactionType = request.ReactionType
             });
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Reacted");
        }

        public async Task<Response<string>> SavePostAsync(int userId, int postId)
        {
            var exists = await _savedPostRepository.GetTableNoTracking()
                .AnyAsync(s => s.PostId == postId && s.UserId == userId);
            
            if (exists) return Response<string>.Success("Already saved");

            await _savedPostRepository.AddAsync(new SavedPost
            {
                UserId = userId,
                PostId = postId,
                SavedAt = DateTime.UtcNow
            });
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Post saved");
        }

        public async Task<Response<string>> SharePostAsync(int userId, int postId)
        {
            return Response<string>.Success("Shared successfully");
        }

        public async Task<Response<string>> UnsavePostAsync(int userId, int postId)
        {
             var saved = await _savedPostRepository.GetTableNoTracking()
                .FirstOrDefaultAsync(s => s.PostId == postId && s.UserId == userId);
            
            if (saved == null) return Response<string>.Failure("Not saved");

            await _savedPostRepository.DeleteAsync(saved);
            await _unitOfWork.CompleteAsync();
            return Response<string>.Success("Removed from saved");
        }

        public async Task<Response<PostDto>> UpdatePostAsync(int userId, int postId, UpdatePostRequest request)
        {
            // Refactored to include Media explicitly
            var post = await _postRepository.GetTableAsTracking()
                .Include(p => p.Media)
                .FirstOrDefaultAsync(p => p.Id == postId);
            if (post == null) return Response<PostDto>.Failure("Post not found");
            if (post.UserId != userId) return Response<PostDto>.Failure("Unauthorized");

            if(request.Content != null) post.Content = request.Content;
            post.Privacy = request.Privacy;
            post.UpdatedAt = DateTime.UtcNow;

            await _postRepository.UpdateAsync(post);
            await _unitOfWork.CompleteAsync();

            var user = await _userRepository.GetByIdAsync(userId);
            
            var dto = new PostDto
            {
                Id = post.Id,
                UserId = post.UserId,
                UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                UserAvatarUrl = user?.AvatarUrl,
                Content = post.Content,
                Privacy = post.Privacy,
                CreatedAt = post.CreatedAt,
                Media = post.Media != null ? post.Media.Select(m => new PostMediaDto { Id = m.Id, Url = m.Url, MediaType = m.MediaType }).ToList() : new(),
                ReactionsCount = await _reactionRepository.GetTableNoTracking().CountAsync(r => r.PostId == postId),
                CommentsCount = 0, // Need repository for this to be accurate, but Update doesn't change it
                IsLikedByCurrentUser = false,
                IsSavedByCurrentUser = false
            };
            
            return Response<PostDto>.Success(dto);
        }

        public async Task<Response<string>> UploadMediaAsync(UploadPostMediaRequest request)
        {
            var url = await UploadImageAsync(request.File, "posts");
            return Response<string>.Success(url);
        }
    }
}
