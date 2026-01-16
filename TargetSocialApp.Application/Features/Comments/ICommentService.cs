using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Comments
{
    public interface ICommentService
    {
        Task<Response<Comment>> AddCommentAsync(int userId, int postId, CreateCommentRequest request);
        Task<Response<List<Comment>>> GetPostCommentsAsync(int postId);
        Task<Response<Comment>> UpdateCommentAsync(int userId, int commentId, UpdateCommentRequest request);
        Task<Response<string>> DeleteCommentAsync(int userId, int commentId);
        
        Task<Response<Comment>> ReplyToCommentAsync(int userId, int commentId, CreateCommentRequest request);
        Task<Response<List<Comment>>> GetCommentRepliesAsync(int commentId);
        
        Task<Response<string>> LikeCommentAsync(int userId, int commentId);
    }
}
