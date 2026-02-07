using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Posts.DTOs
{
    public class PostDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserAvatarUrl { get; set; }
        public string? Content { get; set; }
        public PrivacyLevel Privacy { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<PostMediaDto> Media { get; set; } = new();
        public int ReactionsCount { get; set; }
        public int CommentsCount { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
        public bool IsSavedByCurrentUser { get; set; }
    }

    public class PostMediaDto
    {
        public int Id { get; set; }
        public string Url { get; set; }
        public MediaType MediaType { get; set; }
    }

    public class PostReactionDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserAvatarUrl { get; set; }
        public ReactionType ReactionType { get; set; }
    }
}
