using System.Collections.Generic;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Friends.Requests
{
    // No request body needed for simple friend request / accept actions, often handled by route param
    // But we might need DTO if future expansion. 
    // For "Follow", "Unfollow", "Request", "Accept", "Reject", "Cancel", "Unfriend", "Block" -> often just ID is needed.
}

namespace TargetSocialApp.Application.Features.Friends.Responses
{
    public class FriendshipResponse
    {
        public int FriendshipId { get; set; }
        public int RequesterId { get; set; }
        public int ReceiverId { get; set; }
        public FriendshipStatus Status { get; set; }
        public string RequestDate { get; set; } = string.Empty;
        // User details would drive from mapping
    }
}
