using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class Post : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public string? Content { get; set; }
        public PrivacyLevel Privacy { get; set; } = PrivacyLevel.Public;
        
        // Storing media URLs as simplified List for now, or could be a separate table if complex.
        // Spec mentioned MediaUrls (JSON or separate table). Let's use separate table for better normalization if needed, 
        // but for MVP JSON string or list is often easier. Let's make it a navigation property to be safe.
        // Actually, requirements mention "Post Media: ... up to 10 images". 
        // Let's create a PostMedia entity or just store JSON. The user request has "MediaUrls (JSON or separate table)".
        // I will use a separate entity 'PostMedia' in code-first to easier manage types (Video vs Image).
        
        public virtual ICollection<PostMedia> Media { get; set; } = new HashSet<PostMedia>();
        
        public virtual ICollection<Comment> Comments { get; set; } = new HashSet<Comment>();
        public virtual ICollection<PostReaction> Reactions { get; set; } = new HashSet<PostReaction>();
        public virtual ICollection<SavedPost> SavedByUsers { get; set; } = new HashSet<SavedPost>();
    }

    public class PostMedia : BaseEntity 
    {
        public int PostId { get; set; }
        public virtual Post Post { get; set; } = null!;
        public string Url { get; set; } = null!;
        public MediaType MediaType { get; set; }
    }
}
