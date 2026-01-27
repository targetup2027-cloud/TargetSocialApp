using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Comments;
using TargetSocialApp.Application.Features.Comments.Requests;
using TargetSocialApp.Application.Common.Bases;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _commentService;

        public CommentsController(ICommentService commentService)
        {
            _commentService = commentService;
        }

        [HttpPost("api/posts/{postId}/comments")]
        public async Task<IActionResult> AddComment(int postId, [FromBody] CreateCommentRequest request)
        {
            int userId = 1;
            var response = await _commentService.AddCommentAsync(userId, postId, request);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/posts/{postId}/comments")]
        public async Task<IActionResult> GetComments(int postId)
        {
            var response = await _commentService.GetPostCommentsAsync(postId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPut("api/comments/{commentId}")]
        public async Task<IActionResult> UpdateComment(int commentId, [FromBody] UpdateCommentRequest request)
        {
            int userId = 1;
            var response = await _commentService.UpdateCommentAsync(userId, commentId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpDelete("api/comments/{commentId}")]
        public async Task<IActionResult> DeleteComment(int commentId)
        {
            int userId = 1;
            var response = await _commentService.DeleteCommentAsync(userId, commentId);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("api/comments/{commentId}/replies")]
        public async Task<IActionResult> ReplyToComment(int commentId, [FromBody] CreateCommentRequest request)
        {
            int userId = 1;
            var response = await _commentService.ReplyToCommentAsync(userId, commentId, request);
            if (!response.Succeeded) return BadRequest(ApiResponseWrapper.Create(response, 400));
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpGet("api/comments/{commentId}/replies")]
        public async Task<IActionResult> GetReplies(int commentId)
        {
            var response = await _commentService.GetCommentRepliesAsync(commentId);
            return Ok(ApiResponseWrapper.Create(response));
        }

        [HttpPost("api/comments/{commentId}/like")]
        public async Task<IActionResult> LikeComment(int commentId)
        {
            int userId = 1;
            var response = await _commentService.LikeCommentAsync(userId, commentId);
            return Ok(ApiResponseWrapper.Create(response));
        }
    }
}
