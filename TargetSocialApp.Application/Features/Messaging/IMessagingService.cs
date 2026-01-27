using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Messaging.Requests;
using TargetSocialApp.Domain.Entities;

using TargetSocialApp.Application.Features.Messaging.DTOs;

namespace TargetSocialApp.Application.Features.Messaging
{
    public interface IMessagingService
    {
        // Conversations
        Task<Response<List<ConversationDto>>> GetUserConversationsAsync(int userId);
        Task<Response<ConversationDto>> GetConversationByIdAsync(int userId, int conversationId);
        Task<Response<ConversationDto>> CreateConversationAsync(int userId, CreateConversationRequest request);
        Task<Response<string>> DeleteConversationAsync(int userId, int conversationId);

        // Messages
        Task<Response<MessageDto>> SendMessageAsync(int userId, int conversationId, SendMessageRequest request);
        Task<Response<List<MessageDto>>> GetMessagesAsync(int userId, int conversationId);
        Task<Response<MessageDto>> UpdateMessageAsync(int userId, int messageId, UpdateMessageRequest request);
        Task<Response<string>> DeleteMessageAsync(int userId, int messageId);
        
        // Actions
        Task<Response<string>> MarkMessageAsReadAsync(int userId, int messageId);
        Task<Response<string>> ReactToMessageAsync(int userId, int messageId, MessageReactionRequest request);
    }
}
