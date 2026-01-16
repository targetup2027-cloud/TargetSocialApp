namespace TargetSocialApp.Domain.Enums
{
    public enum Gender
    {
        Male,
        Female,
        Other
    }

    public enum PrivacyLevel
    {
        Public,
        Friends,
        OnlyMe,
        Custom
    }

    public enum ReactionType
    {
        Like,
        Love,
        Haha,
        Sad,
        Angry,
        Wow
    }

    public enum FriendshipStatus
    {
        Pending,
        Accepted,
        Rejected,
        Blocked
    }

    public enum MediaType
    {
        Image,
        Video,
        Voice,
        File
    }

    public enum MessageType
    {
        Text,
        Image,
        Video,
        Voice,
        File,
        CallLog
    }

    public enum MessageStatus
    {
        Sent,
        Delivered,
        Read
    }

    public enum NotificationType
    {
        Like,
        Comment,
        Share,
        FriendRequest,
        FriendRequestAccepted,
        Message,
        Mention,
        Story
    }
}
