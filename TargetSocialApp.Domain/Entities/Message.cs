using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using TargetSocialApp.Domain.Common;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Domain.Entities
{
    public class Conversation : BaseEntity
    {
        public string? Title { get; set; }
        public bool IsGroup { get; set; }
        
        public int? LastMessageId { get; set; }
        [ForeignKey("LastMessageId")]
        public virtual Message? LastMessage { get; set; }

        public virtual ICollection<ConversationParticipant> Participants { get; set; } = new HashSet<ConversationParticipant>();
        public virtual ICollection<Message> Messages { get; set; } = new HashSet<Message>();
    }

    public class ConversationParticipant : BaseEntity
    {
        public int ConversationId { get; set; }
        public virtual Conversation Conversation { get; set; } = null!;

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public DateTime JoinedAt { get; set; }
        public DateTime? LeftAt { get; set; }
    }

    public class Message : BaseEntity
    {
        public int ConversationId { get; set; }
        public virtual Conversation Conversation { get; set; } = null!;

        public int SenderId { get; set; }
        public virtual User Sender { get; set; } = null!;

        public string? Content { get; set; }
        public MessageType Type { get; set; } 
        public string? MediaUrl { get; set; }
        
        public bool IsEdited { get; set; }
        public bool IsRead { get; set; } 
        public DateTime? ReadAt { get; set; }
        public DateTime SentAt { get; set; }

        public virtual ICollection<MessageDeliveryStatus> MessageStatuses { get; set; } = new HashSet<MessageDeliveryStatus>();
    }

    public class MessageDeliveryStatus : BaseEntity
    {
        public int MessageId { get; set; }
        public virtual Message Message { get; set; } = null!;

        public int UserId { get; set; }
        public virtual User User { get; set; } = null!;

        public TargetSocialApp.Domain.Enums.MessageStatus Status { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
