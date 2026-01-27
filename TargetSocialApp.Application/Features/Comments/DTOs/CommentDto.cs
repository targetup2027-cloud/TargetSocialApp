using System;
using System.Collections.Generic;

namespace TargetSocialApp.Application.Features.Comments.DTOs
{
    public class CommentDto
    {
        public int Id { get; set; }
        public int PostId { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserAvatarUrl { get; set; }
        public string Content { get; set; }
        public DateTime CreatedAt { get; set; }
        public int? ParentCommentId { get; set; }
        public int RepliesCount { get; set; }
        public int ReactionsCount { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
    }
}
