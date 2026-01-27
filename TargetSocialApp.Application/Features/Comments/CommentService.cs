using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Application.Features.Comments.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Comments
{
    public class CommentService : AppService, ICommentService
    {
        private readonly IGenericRepository<Comment> _commentRepository;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IGenericRepository<CommentReaction> _reactionRepository;
        private readonly IUnitOfWork _unitOfWork;

        public CommentService(
            IGenericRepository<Comment> commentRepository,
            IGenericRepository<User> userRepository,
            IGenericRepository<CommentReaction> reactionRepository,
            IUnitOfWork unitOfWork)
        {
            _commentRepository = commentRepository;
            _userRepository = userRepository;
            _reactionRepository = reactionRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<CommentDto>> AddCommentAsync(int userId, int postId, CreateCommentRequest request)
        {
             var comment = new Comment
             {
                 UserId = userId,
                 PostId = postId,
                 Content = request.Content,
                 CreatedAt = DateTime.UtcNow
             };
             
             await _commentRepository.AddAsync(comment);
             await _unitOfWork.CompleteAsync();

             var user = await _userRepository.GetByIdAsync(userId);

             var dto = new CommentDto
             {
                 Id = comment.Id,
                 PostId = comment.PostId,
                 UserId = comment.UserId,
                 UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                 UserAvatarUrl = user?.AvatarUrl,
                 Content = comment.Content,
                 CreatedAt = comment.CreatedAt,
                 ParentCommentId = comment.ParentCommentId,
                 RepliesCount = 0,
                 ReactionsCount = 0,
                 IsLikedByCurrentUser = false
             };

             return Response<CommentDto>.Success(dto);
        }

        public async Task<Response<string>> DeleteCommentAsync(int userId, int commentId)
        {
             var comment = await _commentRepository.GetByIdAsync(commentId);
             if (comment == null) return Response<string>.Failure("Comment not found");
             if (comment.UserId != userId) return Response<string>.Failure("Unauthorized");

             await _commentRepository.DeleteAsync(comment);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Comment deleted");
        }

        public async Task<Response<List<CommentDto>>> GetCommentRepliesAsync(int commentId)
        {
             var replies = await _commentRepository.GetTableNoTracking()
                 .Where(c => c.ParentCommentId == commentId)
                 .OrderBy(c => c.CreatedAt)
                 .Select(c => new CommentDto
                 {
                     Id = c.Id,
                     PostId = c.PostId,
                     UserId = c.UserId,
                     UserName = c.User.FirstName + " " + c.User.LastName,
                     UserAvatarUrl = c.User.AvatarUrl,
                     Content = c.Content,
                     CreatedAt = c.CreatedAt,
                     ParentCommentId = c.ParentCommentId,
                     RepliesCount = c.Replies.Count(), // Should be 0 for replies usually, unless nested infinite
                     ReactionsCount = c.Reactions.Count(),
                     IsLikedByCurrentUser = false // Need calling user ID context to implement true logic
                 })
                 .ToListAsync();
                 
             return Response<List<CommentDto>>.Success(replies);
        }

        public async Task<Response<List<CommentDto>>> GetPostCommentsAsync(int postId)
        {
             // Get top level comments only
             var comments = await _commentRepository.GetTableNoTracking()
                 .Where(c => c.PostId == postId && c.ParentCommentId == null)
                 .OrderByDescending(c => c.CreatedAt) // Usually newest first or chronological? Let's stick to simple sort.
                 .Select(c => new CommentDto
                 {
                     Id = c.Id,
                     PostId = c.PostId,
                     UserId = c.UserId,
                     UserName = c.User.FirstName + " " + c.User.LastName,
                     UserAvatarUrl = c.User.AvatarUrl,
                     Content = c.Content,
                     CreatedAt = c.CreatedAt,
                     ParentCommentId = c.ParentCommentId,
                     RepliesCount = c.Replies.Count(),
                     ReactionsCount = c.Reactions.Count(),
                     IsLikedByCurrentUser = false // Pending Context
                 })
                 .ToListAsync();

             return Response<List<CommentDto>>.Success(comments);
        }

        public async Task<Response<string>> LikeCommentAsync(int userId, int commentId)
        {
             var existing = await _reactionRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(r => r.CommentId == commentId && r.UserId == userId && r.ReactionType == ReactionType.Like);

             if (existing != null)
             {
                 await _reactionRepository.DeleteAsync(existing);
                 await _unitOfWork.CompleteAsync();
                 return Response<string>.Success("Unliked");
             }

             await _reactionRepository.AddAsync(new CommentReaction
             {
                 CommentId = commentId,
                 UserId = userId,
                 ReactionType = ReactionType.Like
             });
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Liked");
        }

        public async Task<Response<CommentDto>> ReplyToCommentAsync(int userId, int commentId, CreateCommentRequest request)
        {
             var parent = await _commentRepository.GetByIdAsync(commentId);
             if (parent == null) return Response<CommentDto>.Failure("Parent comment not found");

             var reply = new Comment
             {
                 UserId = userId,
                 PostId = parent.PostId,
                 ParentCommentId = commentId,
                 Content = request.Content,
                 CreatedAt = DateTime.UtcNow
             };

             await _commentRepository.AddAsync(reply);
             await _unitOfWork.CompleteAsync();
             
             var user = await _userRepository.GetByIdAsync(userId);
             var dto = new CommentDto
             {
                 Id = reply.Id,
                 PostId = reply.PostId,
                 UserId = reply.UserId,
                 UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                 UserAvatarUrl = user?.AvatarUrl,
                 Content = reply.Content,
                 CreatedAt = reply.CreatedAt,
                 ParentCommentId = reply.ParentCommentId,
                 RepliesCount = 0,
                 ReactionsCount = 0,
                 IsLikedByCurrentUser = false
             };

             return Response<CommentDto>.Success(dto);
        }

        public async Task<Response<CommentDto>> UpdateCommentAsync(int userId, int commentId, UpdateCommentRequest request)
        {
             // We need to fetch with User to return DTO
             // But GenericRepo GetByIdAsync usually doesn't include.
             // So we fetch, update, save, then maybe construct DTO manually or refetch.
             var comment = await _commentRepository.GetByIdAsync(commentId);
             
             if (comment == null) return Response<CommentDto>.Failure("Comment not found");
             if (comment.UserId != userId) return Response<CommentDto>.Failure("Unauthorized");

             comment.Content = request.Content;
             comment.UpdatedAt = DateTime.UtcNow;

             await _commentRepository.UpdateAsync(comment);
             await _unitOfWork.CompleteAsync();
             
             var user = await _userRepository.GetByIdAsync(userId);
             
             var dto = new CommentDto
             {
                 Id = comment.Id,
                 PostId = comment.PostId,
                 UserId = comment.UserId,
                 UserName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                 UserAvatarUrl = user?.AvatarUrl,
                 Content = comment.Content,
                 CreatedAt = comment.CreatedAt,
                 ParentCommentId = comment.ParentCommentId,
                 RepliesCount = await _commentRepository.GetTableNoTracking().CountAsync(c => c.ParentCommentId == comment.Id),
                 ReactionsCount = await _reactionRepository.GetTableNoTracking().CountAsync(r => r.CommentId == comment.Id),
                 IsLikedByCurrentUser = false // Pending
             };
             
             return Response<CommentDto>.Success(dto);
        }
    }
}
