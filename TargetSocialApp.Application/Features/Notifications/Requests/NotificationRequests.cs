namespace TargetSocialApp.Application.Features.Notifications.Requests
{
    public class UpdateNotificationSettingsRequest
    {
        public bool Likes { get; set; }
        public bool Comments { get; set; }
        public bool NewFollowers { get; set; }
        public bool Mentions { get; set; }
        public bool DirectMessages { get; set; }
        // Add other settings mapping to Domain entity
    }
}
