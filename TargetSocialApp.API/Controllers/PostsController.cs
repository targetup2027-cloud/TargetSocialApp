using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using TargetSocialApp.Application.Features.Posts;
using TargetSocialApp.Application.Features.Posts.Requests;

namespace TargetSocialApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PostsController : ControllerBase
    {
        private readonly IPostService _postService;

        public PostsController(IPostService postService)
        {
            _postService = postService;
        }

        [HttpPost]
        public async Task<IActionResult> CreatePost([FromBody] CreatePostRequest request)
        {
            int userId = 1; // Claims
            var response = await _postService.CreatePostAsync(userId, request);
            return Ok(response);
        }

        [HttpGet("{postId}")]
        public async Task<IActionResult> GetPost(int postId)
        {
            var response = await _postService.GetPostByIdAsync(postId);
            if(!response.Succeeded) return NotFound(response);
            return Ok(response);
        }

        [HttpPut("{postId}")]
        public async Task<IActionResult> UpdatePost(int postId, [FromBody] UpdatePostRequest request)
        {
            int userId = 1;
            var response = await _postService.UpdatePostAsync(userId, postId, request);
            if(!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpDelete("{postId}")]
        public async Task<IActionResult> DeletePost(int postId)
        {
            int userId = 1;
            var response = await _postService.DeletePostAsync(userId, postId);
            if(!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpGet("feed")]
        public async Task<IActionResult> GetFeed()
        {
            int userId = 1; 
            var response = await _postService.GetFeedAsync(userId);
            return Ok(response);
        }

        [HttpGet("feed/friends")]
        public async Task<IActionResult> GetFriendsFeed()
        {
            int userId = 1;
            var response = await _postService.GetFriendsFeedAsync(userId);
            return Ok(response);
        }

        [HttpGet("feed/following")]
        public async Task<IActionResult> GetFollowingFeed()
        {
            int userId = 1;
            var response = await _postService.GetFollowingFeedAsync(userId);
            return Ok(response);
        }

        [HttpPost("{postId}/like")]
        public async Task<IActionResult> LikePost(int postId)
        {
            int userId = 1;
            var response = await _postService.LikePostAsync(userId, postId);
            return Ok(response);
        }

        [HttpPost("{postId}/react")]
        public async Task<IActionResult> ReactPost(int postId, [FromBody] PostReactionRequest request)
        {
            int userId = 1;
            var response = await _postService.ReactToPostAsync(userId, postId, request);
            return Ok(response);
        }

        [HttpGet("{postId}/reactions")]
        public async Task<IActionResult> GetReactions(int postId)
        {
            var response = await _postService.GetPostReactionsAsync(postId);
            return Ok(response);
        }

        [HttpPost("{postId}/share")]
        public async Task<IActionResult> SharePost(int postId)
        {
            int userId = 1;
            var response = await _postService.SharePostAsync(userId, postId);
            return Ok(response);
        }

        [HttpPost("{postId}/save")]
        public async Task<IActionResult> SavePost(int postId)
        {
            int userId = 1;
            var response = await _postService.SavePostAsync(userId, postId);
            return Ok(response);
        }

        [HttpDelete("{postId}/save")]
        public async Task<IActionResult> UnsavePost(int postId)
        {
            int userId = 1;
            var response = await _postService.UnsavePostAsync(userId, postId);
            return Ok(response);
        }

        [HttpGet("saved")]
        public async Task<IActionResult> GetSavedPosts()
        {
            int userId = 1;
            var response = await _postService.GetSavedPostsAsync(userId);
            return Ok(response);
        }

        [HttpPost("upload-media")]
        public async Task<IActionResult> UploadMedia([FromForm] UploadPostMediaRequest request)
        {
            var response = await _postService.UploadMediaAsync(request);
            if(!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }
    }
}
