using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Comments
{
    public class CommentService : AppService, ICommentService
    {
        private readonly IGenericRepository<Comment> _commentRepository;
        private readonly IGenericRepository<CommentReaction> _reactionRepository;
        private readonly IUnitOfWork _unitOfWork;

        public CommentService(
            IGenericRepository<Comment> commentRepository,
            IGenericRepository<CommentReaction> reactionRepository,
            IUnitOfWork unitOfWork)
        {
            _commentRepository = commentRepository;
            _reactionRepository = reactionRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<Comment>> AddCommentAsync(int userId, int postId, CreateCommentRequest request)
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
             return Response<Comment>.Success(comment);
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

        public async Task<Response<List<Comment>>> GetCommentRepliesAsync(int commentId)
        {
             var replies = await _commentRepository.GetTableNoTracking()
                 .Where(c => c.ParentCommentId == commentId)
                 .OrderBy(c => c.CreatedAt)
                 .ToListAsync();
             return Response<List<Comment>>.Success(replies);
        }

        public async Task<Response<List<Comment>>> GetPostCommentsAsync(int postId)
        {
             // Get top level comments only
             var comments = await _commentRepository.GetTableNoTracking()
                 .Where(c => c.PostId == postId && c.ParentCommentId == null)
                 .OrderBy(c => c.CreatedAt)
                 .ToListAsync();
             return Response<List<Comment>>.Success(comments);
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

        public async Task<Response<Comment>> ReplyToCommentAsync(int userId, int commentId, CreateCommentRequest request)
        {
             var parent = await _commentRepository.GetByIdAsync(commentId);
             if (parent == null) return Response<Comment>.Failure("Parent comment not found");

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
             return Response<Comment>.Success(reply);
        }

        public async Task<Response<Comment>> UpdateCommentAsync(int userId, int commentId, UpdateCommentRequest request)
        {
             var comment = await _commentRepository.GetByIdAsync(commentId);
             if (comment == null) return Response<Comment>.Failure("Comment not found");
             if (comment.UserId != userId) return Response<Comment>.Failure("Unauthorized");

             comment.Content = request.Content;
             comment.UpdatedAt = DateTime.UtcNow;

             await _commentRepository.UpdateAsync(comment);
             await _unitOfWork.CompleteAsync();
             return Response<Comment>.Success(comment);
        }
    }
}
