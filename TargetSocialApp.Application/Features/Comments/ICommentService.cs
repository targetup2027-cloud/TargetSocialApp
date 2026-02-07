using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Application.Features.Comments.DTOs;

namespace TargetSocialApp.Application.Features.Comments
{
    public interface ICommentService
    {
        Task<Response<CommentDto>> AddCommentAsync(int userId, int postId, CreateCommentRequest request);
        Task<Response<List<CommentDto>>> GetPostCommentsAsync(int postId);
        Task<Response<CommentDto>> UpdateCommentAsync(int userId, int commentId, UpdateCommentRequest request);
        Task<Response<string>> DeleteCommentAsync(int userId, int commentId);
        
        Task<Response<CommentDto>> ReplyToCommentAsync(int userId, int commentId, CreateCommentRequest request);
        Task<Response<List<CommentDto>>> GetCommentRepliesAsync(int commentId);
        
        Task<Response<string>> LikeCommentAsync(int userId, int commentId);
    }
}
