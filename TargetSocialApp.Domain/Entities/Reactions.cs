using System;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class PostReaction : BaseEntity
    {
        public int PostId { get; set; }
        public virtual Post Post { get; set; } = null!;

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public ReactionType ReactionType { get; set; }
    }

    public class CommentReaction : BaseEntity
    {
        public int CommentId { get; set; }
        public virtual Comment Comment { get; set; } = null!;

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public ReactionType ReactionType { get; set; }
    }
}
