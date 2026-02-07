using System;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class Notification : BaseEntity
    {
        public int UserId { get; set; } // Recipient
        public virtual User User { get; set; } = null!;

        public int? ActorId { get; set; } // Who triggered it
        public virtual User? Actor { get; set; }

        public NotificationType Type { get; set; }
        public string? ReferenceId { get; set; } // ID of related entity (PostId, etc.) converted to string
        public string Content { get; set; } = null!;
        public bool IsRead { get; set; }
    }
}
