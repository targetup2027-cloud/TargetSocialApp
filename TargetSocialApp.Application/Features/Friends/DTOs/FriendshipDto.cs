using System;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Friends.DTOs
{
    public class FriendshipDto
    {
        public int Id { get; set; }
        public int RequesterId { get; set; }
        public string RequesterName { get; set; }
        public string RequesterAvatarUrl { get; set; }
        public int ReceiverId { get; set; }
        public string ReceiverName { get; set; }
        public string ReceiverAvatarUrl { get; set; }
        public FriendshipStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
