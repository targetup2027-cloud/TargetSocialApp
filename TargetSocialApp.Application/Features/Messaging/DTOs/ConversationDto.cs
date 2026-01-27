using System;
using System.Collections.Generic;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Messaging.DTOs
{
    public class MessageDto
    {
        public int Id { get; set; }
        public int ConversationId { get; set; }
        public int SenderId { get; set; }
        public string SenderName { get; set; }
        public string SenderAvatarUrl { get; set; }
        public string Content { get; set; }
        public MessageType Type { get; set; }
        public bool IsRead { get; set; }
        public DateTime SentAt { get; set; }
    }

    public class ConversationDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public bool IsGroup { get; set; }
        public List<UserDto> Participants { get; set; } = new();
        public MessageDto LastMessage { get; set; }
        public int UnreadCount { get; set; }
    }
}
