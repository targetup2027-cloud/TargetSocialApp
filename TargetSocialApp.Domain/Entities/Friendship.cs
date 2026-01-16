using System;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class Friendship : BaseEntity
    {
        public int RequesterId { get; set; }
        public virtual User Requester { get; set; } = null!;

        public int ReceiverId { get; set; }
        public virtual User Receiver { get; set; } = null!;

        public FriendshipStatus Status { get; set; }
    }

    public class Following : BaseEntity
    {
        public int FollowerId { get; set; }
        public virtual User Follower { get; set; } = null!;

        public int FollowingId { get; set; }
        public virtual User FollowingUser { get; set; } = null!;
    }
}
