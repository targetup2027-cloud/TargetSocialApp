using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Privacy.DTOs
{
    public class PrivacySettingDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public PrivacyLevel ProfileVisibility { get; set; }
        public PrivacyLevel PostVisibility { get; set; }
        public PrivacyLevel FriendListVisibility { get; set; }
    }
}
