using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Messaging.Requests
{
    public class CreateConversationRequest
    {
        public List<int> ParticipantIds { get; set; } = new();
        public string? Title { get; set; } // For group chats
    }

    public class SendMessageRequest
    {
        public string? Content { get; set; }
        public MessageType Type { get; set; }
        // For media/voice, we might use separate endpoint or handle multiform here. 
        // Keeping it simple: separate upload or URL passing.
        public string? MediaUrl { get; set; } 
    }

    public class UpdateMessageRequest
    {
        public string Content { get; set; } = null!;
    }
    
    public class MessageReactionRequest
    {
        public ReactionType ReactionType { get; set; }
    }
}
