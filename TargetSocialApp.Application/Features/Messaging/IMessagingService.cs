using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Messaging.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Messaging
{
    public interface IMessagingService
    {
        // Conversations
        Task<Response<List<Conversation>>> GetUserConversationsAsync(int userId);
        Task<Response<Conversation>> GetConversationByIdAsync(int userId, int conversationId);
        Task<Response<Conversation>> CreateConversationAsync(int userId, CreateConversationRequest request);
        Task<Response<string>> DeleteConversationAsync(int userId, int conversationId);

        // Messages
        Task<Response<Message>> SendMessageAsync(int userId, int conversationId, SendMessageRequest request);
        Task<Response<List<Message>>> GetMessagesAsync(int userId, int conversationId);
        Task<Response<Message>> UpdateMessageAsync(int userId, int messageId, UpdateMessageRequest request);
        Task<Response<string>> DeleteMessageAsync(int userId, int messageId);
        
        // Actions
        Task<Response<string>> MarkMessageAsReadAsync(int userId, int messageId);
        Task<Response<string>> ReactToMessageAsync(int userId, int messageId, MessageReactionRequest request);
    }
}
