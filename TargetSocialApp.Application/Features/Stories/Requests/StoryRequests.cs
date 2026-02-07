using System;
using Microsoft.AspNetCore.Http;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Stories.Requests
{
    public class CreateStoryRequest
    {
        public IFormFile File { get; set; } = null!;
        public MediaType MediaType { get; set; }
    }

    public class CreateHighlightRequest
    {
        public string Title { get; set; } = null!;
        public IFormFile CoverImage { get; set; } = null!;
        public List<int> StoryIds { get; set; } = new();
    }
}
