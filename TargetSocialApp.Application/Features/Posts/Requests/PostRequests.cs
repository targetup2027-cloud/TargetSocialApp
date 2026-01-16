using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Posts.Requests
{
    public class CreatePostRequest
    {
        public string? Content { get; set; }
        public PrivacyLevel Privacy { get; set; }
        public List<string>? MediaUrls { get; set; } // URLs returned from upload
    }

    public class UpdatePostRequest
    {
        public string? Content { get; set; }
        public PrivacyLevel Privacy { get; set; }
        // Typically media update is more complex (add/remove), keeping simple for MVP
    }

    public class PostReactionRequest
    {
        public ReactionType ReactionType { get; set; }
    }

    public class UploadPostMediaRequest
    {
        public IFormFile File { get; set; } = null!;
        public MediaType MediaType { get; set; }
    }
}
