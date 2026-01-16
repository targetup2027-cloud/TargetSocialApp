using System;
using System.Collections.Generic;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class User : BaseEntity
    {
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? PhoneNumber { get; set; }
        public string PasswordHash { get; set; } = null!;
        public DateTime DateOfBirth { get; set; }
        public Gender Gender { get; set; }
        public string? Bio { get; set; }
        public string? AvatarUrl { get; set; }
        public string? CoverPhotoUrl { get; set; }
        public bool IsEmailVerified { get; set; }
        public bool IsPhoneVerified { get; set; }

        public virtual PrivacySetting? PrivacySetting { get; set; }
        public virtual NotificationSetting? NotificationSetting { get; set; }

        public virtual ICollection<Post> Posts { get; set; } 
        public virtual ICollection<Comment> Comments { get; set; } 
        public virtual ICollection<Story> Stories { get; set; } 
        public virtual ICollection<Friendship> SentFriendRequests { get; set; } 
        public virtual ICollection<Friendship> ReceivedFriendRequests { get; set; } 
        public virtual ICollection<UserSession> UserSessions { get; set; } 
    }
}
