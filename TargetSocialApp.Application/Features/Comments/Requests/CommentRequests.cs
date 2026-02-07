using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Comments.Requests
{
    public class CreateCommentRequest
    {
        public string Content { get; set; } = null!;
    }
    
    public class UpdateCommentRequest
    {
        public string Content { get; set; } = null!;
    }

    public class CommentReactionRequest
    {
        public ReactionType ReactionType { get; set; }
    }
}
