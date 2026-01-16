using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class Story : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public string MediaUrl { get; set; } = null!;
        public MediaType MediaType { get; set; }
        public DateTime ExpiresAt { get; set; } // CreatedAt + 24h

        public virtual ICollection<StoryView> Views { get; set; } = new HashSet<StoryView>();
    }

    public class StoryView : BaseEntity
    {
        public int StoryId { get; set; }
        public virtual Story Story { get; set; } = null!;

        public int ViewerId { get; set; }
        public virtual User Viewer { get; set; } = null!;

        public DateTime ViewedAt { get; set; }
    }

    public class StoryHighlight : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public string Title { get; set; } = null!;
        public string CoverImageUrl { get; set; } = null!;

        public virtual ICollection<StoryHighlightItem> Items { get; set; } = new HashSet<StoryHighlightItem>();
    }

    public class StoryHighlightItem : BaseEntity
    {
        public int HighlightId { get; set; }
        public virtual StoryHighlight Highlight { get; set; } = null!;

        public int StoryId { get; set; }
        public virtual Story Story { get; set; } = null!;

        public int Order { get; set; }
    }
}
