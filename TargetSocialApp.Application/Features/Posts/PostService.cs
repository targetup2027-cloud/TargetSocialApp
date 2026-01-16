using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Posts.Requests;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Posts
{
    public class PostService : AppService, IPostService
    {
        private readonly IGenericRepository<Post> _postRepository;
        private readonly IGenericRepository<PostReaction> _reactionRepository;
        private readonly IGenericRepository<SavedPost> _savedPostRepository;
        private readonly IUnitOfWork _unitOfWork;

        public PostService(
            IGenericRepository<Post> postRepository,
            IGenericRepository<PostReaction> reactionRepository,
            IGenericRepository<SavedPost> savedPostRepository,
            IUnitOfWork unitOfWork)
        {
            _postRepository = postRepository;
            _reactionRepository = reactionRepository;
            _savedPostRepository = savedPostRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<Post>> CreatePostAsync(int userId, CreatePostRequest request)
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
                        MediaType = MediaType.Image // Simplification: assuming images for now or parsed from URL
                    });
                }
            }

            await _postRepository.AddAsync(post);
            await _unitOfWork.CompleteAsync();

            return Response<Post>.Success(post, "Post created successfully");
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

        public async Task<Response<List<Post>>> GetFeedAsync(int userId)
        {
            // Simplified Feed: All public posts + posts by friends
            // In real app, this needs complex query with friends logic
            var posts = await _postRepository.GetTableNoTracking()
                .OrderByDescending(x => x.CreatedAt)
                .Take(50)
                .ToListAsync();

            return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<List<Post>>> GetFollowingFeedAsync(int userId)
        {
            // Placeholder: would join with Following table
             var posts = await _postRepository.GetTableNoTracking()
                 .Where(p => p.Privacy == PrivacyLevel.Public) 
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
            return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<List<Post>>> GetFriendsFeedAsync(int userId)
        {
             // Placeholder: would join with Friendship table
             var posts = await _postRepository.GetTableNoTracking()
                .Where(p => p.Privacy == PrivacyLevel.Friends) // Just an example filter
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
            return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<List<Post>>> GetUserPostsAsync(int userId)
        {
            var posts = await _postRepository.GetTableNoTracking()
                .Where(p => p.UserId == userId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();
            return Response<List<Post>>.Success(posts);
        }

        public async Task<Response<Post>> GetPostByIdAsync(int postId)
        {
             var post = await _postRepository.GetByIdAsync(postId);
             if (post == null) return Response<Post>.Failure("Post not found");
             return Response<Post>.Success(post);
        }

        public async Task<Response<List<PostReaction>>> GetPostReactionsAsync(int postId)
        {
            var reactions = await _reactionRepository.GetTableNoTracking()
                .Where(r => r.PostId == postId)
                .ToListAsync();
            return Response<List<PostReaction>>.Success(reactions);
        }

        public async Task<Response<List<Post>>> GetSavedPostsAsync(int userId)
        {
            var saved = await _savedPostRepository.GetTableNoTracking()
                .Where(s => s.UserId == userId)
                .Include(s => s.Post)
                .Select(s => s.Post)
                .ToListAsync();
            return Response<List<Post>>.Success(saved);
        }

        public async Task<Response<string>> LikePostAsync(int userId, int postId)
        {
            // Toggle like
            var existing = await _reactionRepository.GetTableNoTracking()
                .FirstOrDefaultAsync(r => r.PostId == postId && r.UserId == userId && r.ReactionType == ReactionType.Like);
            
            if (existing != null)
            {
                await _reactionRepository.DeleteAsync(existing);
                await _unitOfWork.CompleteAsync();
                return Response<string>.Success("Unliked");
            }

            // Remove other reactions? Or just add Like. Typically Facebook replaces reaction.
            // Let's assume we treat Like as a reaction. If other reaction exists, update it.
             var anyReaction = await _reactionRepository.GetTableAsTracking() // Tracking for update
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
            // Sharing typically creates a new post referencing the original, or just increments count
            // For MVP, just return success
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

        public async Task<Response<Post>> UpdatePostAsync(int userId, int postId, UpdatePostRequest request)
        {
            var post = await _postRepository.GetByIdAsync(postId);
            if (post == null) return Response<Post>.Failure("Post not found");
            if (post.UserId != userId) return Response<Post>.Failure("Unauthorized");

            if(request.Content != null) post.Content = request.Content;
            post.Privacy = request.Privacy;
            post.UpdatedAt = DateTime.UtcNow;

            await _postRepository.UpdateAsync(post);
            await _unitOfWork.CompleteAsync();
            return Response<Post>.Success(post);
        }

        public async Task<Response<string>> UploadMediaAsync(UploadPostMediaRequest request)
        {
            var url = await UploadImageAsync(request.File, "posts");
            return Response<string>.Success(url);
        }
    }
}
