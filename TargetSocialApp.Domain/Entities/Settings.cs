using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class PrivacySetting : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public PrivacyLevel ProfileVisibility { get; set; } = PrivacyLevel.Public;
        // Additional fine-grained controls
        public PrivacyLevel PostVisibility { get; set; } = PrivacyLevel.Public;
        public PrivacyLevel FriendListVisibility { get; set; } = PrivacyLevel.Public;
    }

    public class NotificationSetting : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public bool Likes { get; set; } = true;
        public bool Comments { get; set; } = true;
        public bool Mentions { get; set; } = true;
        public bool NewFollowers { get; set; } = true;
        public bool DirectMessages { get; set; } = true;
        
        // Channel settings
        public bool EmailNotifications { get; set; } = true;
        public bool PushNotifications { get; set; } = true;
    }

    public class UserSession : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public string RefreshToken { get; set; } = null!;
        public string? DeviceInfo { get; set; }
        public string? IpAddress { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class SavedPost : BaseEntity
    {
        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public int PostId { get; set; }
        public virtual Post Post { get; set; } = null!;

        public DateTime SavedAt { get; set; }
    }
    
    public class BlockedUser : BaseEntity
    {
        public int UserId { get; set; } // The blocker
        public virtual User User { get; set; } = null!;

        public int BlockedUserId { get; set; } // The one being blocked
        public virtual User Blocked { get; set; } = null!; 

        public DateTime BlockedAt { get; set; }
    }
}
