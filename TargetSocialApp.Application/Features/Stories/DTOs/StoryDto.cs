using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Stories.DTOs
{
    public class StoryDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserAvatarUrl { get; set; }
        public string MediaUrl { get; set; }
        public MediaType MediaType { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
        public int ViewsCount { get; set; }
        public bool IsViewedByCurrentUser { get; set; }
    }

    public class StoryHighlightDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string CoverImageUrl { get; set; }
        public List<StoryDto> Stories { get; set; } = new();
    }
}
