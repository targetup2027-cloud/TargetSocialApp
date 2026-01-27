using System;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Notifications.DTOs
{
    public class NotificationDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? ActorId { get; set; }
        public string ActorName { get; set; }
        public string ActorAvatarUrl { get; set; }
        public NotificationType Type { get; set; }
        public string? ReferenceId { get; set; }
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class NotificationSettingDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public bool Likes { get; set; }
        public bool Comments { get; set; }
        public bool Mentions { get; set; }
        public bool NewFollowers { get; set; }
        public bool DirectMessages { get; set; }
        public bool EmailNotifications { get; set; }
        public bool PushNotifications { get; set; }
    }
}
