using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Common;

namespace TargetSocialApp.Domain.Entities
{
    public class Comment : BaseEntity
    {
        public int PostId { get; set; }
        public virtual Post Post { get; set; } = null!;

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public string Content { get; set; } = null!;

        public int? ParentCommentId { get; set; }
        public virtual Comment? ParentComment { get; set; }
        public virtual ICollection<Comment> Replies { get; set; } = new HashSet<Comment>();
        
        public virtual ICollection<CommentReaction> Reactions { get; set; } = new HashSet<CommentReaction>();
    }
}
