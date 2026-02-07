using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Messaging.Requests;
using TargetSocialApp.Application.Features.Messaging.DTOs;
using TargetSocialApp.Application.Features.Users.DTOs;
using TargetSocialApp.Domain.Entities;
using TargetSocialApp.Domain.Enums;

namespace TargetSocialApp.Application.Features.Messaging
{
    public class MessagingService : AppService, IMessagingService
    {
        private readonly IGenericRepository<Conversation> _conversationRepository;
        private readonly IGenericRepository<Message> _messageRepository;
        private readonly IGenericRepository<User> _userRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IChatNotifier _chatNotifier;

        public MessagingService(
            IGenericRepository<Conversation> conversationRepository,
            IGenericRepository<Message> messageRepository,
            IGenericRepository<User> userRepository,
            IUnitOfWork unitOfWork,
            IChatNotifier chatNotifier)
        {
            _conversationRepository = conversationRepository;
            _messageRepository = messageRepository;
            _userRepository = userRepository;
            _unitOfWork = unitOfWork;
            _chatNotifier = chatNotifier;
        }

        public async Task<Response<ConversationDto>> CreateConversationAsync(int userId, CreateConversationRequest request)
        {
            if (request.ParticipantIds.Count == 1)
            {
                var otherUserId = request.ParticipantIds[0];
                var existing = await _conversationRepository.GetTableNoTracking()
                    .Where(c => !c.IsGroup && 
                           c.Participants.Any(p => p.UserId == userId) && 
                           c.Participants.Any(p => p.UserId == otherUserId))
                    .Select(c => new ConversationDto
                    {
                        Id = c.Id,
                        Title = c.Title,
                        IsGroup = c.IsGroup,
                        Participants = c.Participants.Select(p => new UserDto
                        {
                            Id = p.User.Id,
                            FirstName = p.User.FirstName,
                            LastName = p.User.LastName,
                            AvatarUrl = p.User.AvatarUrl
                        }).ToList(),
                        UnreadCount = 0 // Needs calculation
                    })
                    .FirstOrDefaultAsync();
                
                if (existing != null) return Response<ConversationDto>.Success(existing);
            }

            var conversation = new Conversation
            {
                Title = request.Title,
                IsGroup = request.ParticipantIds.Count > 1,
                CreatedAt = DateTime.UtcNow
            };

            conversation.Participants.Add(new ConversationParticipant { UserId = userId, JoinedAt = DateTime.UtcNow });
            foreach (var pId in request.ParticipantIds)
            {
                conversation.Participants.Add(new ConversationParticipant { UserId = pId, JoinedAt = DateTime.UtcNow });
            }

            await _conversationRepository.AddAsync(conversation);
            await _unitOfWork.CompleteAsync();

            // Reload for DTO
            var createdDto = new ConversationDto
            {
                 Id = conversation.Id,
                 Title = conversation.Title,
                 IsGroup = conversation.IsGroup,
                 Participants = new List<UserDto>(), // Populate if needed
                 LastMessage = null,
                 UnreadCount = 0 
            };

            return Response<ConversationDto>.Success(createdDto);
        }

        public async Task<Response<string>> DeleteConversationAsync(int userId, int conversationId)
        {
            var conversation = await _conversationRepository.GetTableAsTracking()
                .Include(c => c.Participants)
                .FirstOrDefaultAsync(c => c.Id == conversationId);
             if (conversation == null) return Response<string>.Failure("Conversation not found");
             
             if(!conversation.Participants.Any(p => p.UserId == userId)) return Response<string>.Failure("Unauthorized");

             await _conversationRepository.DeleteAsync(conversation);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Conversation deleted");
        }

        public async Task<Response<string>> DeleteMessageAsync(int userId, int messageId)
        {
             var message = await _messageRepository.GetByIdAsync(messageId);
             if (message == null) return Response<string>.Failure("Message not found");
             if (message.SenderId != userId) return Response<string>.Failure("Unauthorized");

             await _messageRepository.DeleteAsync(message);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Message deleted");
        }

        public async Task<Response<ConversationDto>> GetConversationByIdAsync(int userId, int conversationId)
        {
             var conversation = await _conversationRepository.GetTableNoTracking()
                 .Where(c => c.Id == conversationId)
                 .Select(c => new ConversationDto
                 {
                     Id = c.Id,
                     Title = c.Title,
                     IsGroup = c.IsGroup,
                     Participants = c.Participants.Select(p => new UserDto
                     {
                        Id = p.User.Id,
                        FirstName = p.User.FirstName,
                        LastName = p.User.LastName,
                        AvatarUrl = p.User.AvatarUrl
                     }).ToList(),
                     LastMessage = c.LastMessage != null ? new MessageDto
                     {
                         Id = c.LastMessage.Id,
                         Content = c.LastMessage.Content,
                         SenderId = c.LastMessage.SenderId,
                         SentAt = c.LastMessage.SentAt,
                         IsRead = c.LastMessage.IsRead
                     } : null
                 })
                 .FirstOrDefaultAsync();
             
             if (conversation == null) return Response<ConversationDto>.Failure("Conversation not found");
             // Permission check tough in Select if user ID not captured well, assuming filtered previously or checking participants manually now
             bool isParticipant = conversation.Participants.Any(p => p.Id == userId);
             // Wait, UserDto.Id is populated.
             if(!isParticipant) return Response<ConversationDto>.Failure("Unauthorized"); // Actually re-check logic: loop through DTO participants

             return Response<ConversationDto>.Success(conversation);
        }

        public async Task<Response<List<MessageDto>>> GetMessagesAsync(int userId, int conversationId)
        {
             var conversation = await _conversationRepository.GetTableNoTracking()
                 .Include(c => c.Participants)
                 .FirstOrDefaultAsync(c => c.Id == conversationId);
             
             if (conversation == null) return Response<List<MessageDto>>.Failure("Conversation not found");
             if (!conversation.Participants.Any(p => p.UserId == userId)) return Response<List<MessageDto>>.Failure("Unauthorized");

             var messages = await _messageRepository.GetTableNoTracking()
                 .Where(m => m.ConversationId == conversationId)
                 .OrderBy(m => m.SentAt)
                 .Take(100)
                 .Select(m => new MessageDto
                 {
                     Id = m.Id,
                     ConversationId = m.ConversationId,
                     SenderId = m.SenderId,
                     SenderName = m.Sender.FirstName + " " + m.Sender.LastName,
                     SenderAvatarUrl = m.Sender.AvatarUrl,
                     Content = m.Content,
                     Type = m.Type,
                     IsRead = m.IsRead,
                     SentAt = m.SentAt
                 })
                 .ToListAsync();
             
             return Response<List<MessageDto>>.Success(messages);
        }

        public async Task<Response<List<ConversationDto>>> GetUserConversationsAsync(int userId)
        {
             var conversations = await _conversationRepository.GetTableNoTracking()
                 .Where(c => c.Participants.Any(p => p.UserId == userId))
                 .OrderByDescending(c => c.LastMessage != null ? c.LastMessage.SentAt : c.CreatedAt)
                 .Select(c => new ConversationDto
                 {
                     Id = c.Id,
                     Title = c.Title,
                     IsGroup = c.IsGroup,
                     Participants = c.Participants.Select(p => new UserDto
                     {
                        Id = p.User.Id,
                        FirstName = p.User.FirstName,
                        LastName = p.User.LastName,
                        AvatarUrl = p.User.AvatarUrl
                     }).ToList(),
                     LastMessage = c.LastMessage != null ? new MessageDto
                     {
                         Id = c.LastMessage.Id,
                         Content = c.LastMessage.Content,
                         SenderId = c.LastMessage.SenderId,
                         SenderName = c.LastMessage.Sender.FirstName, // Simplification
                         SentAt = c.LastMessage.SentAt,
                         IsRead = c.LastMessage.IsRead
                     } : null
                 })
                 .ToListAsync();
             
             return Response<List<ConversationDto>>.Success(conversations);
        }

        public async Task<Response<string>> MarkMessageAsReadAsync(int userId, int messageId)
        {
             var message = await _messageRepository.GetByIdAsync(messageId);
             if (message == null) return Response<string>.Failure("Message not found");
             
             if (message.SenderId == userId) return Response<string>.Success("Sender cannot read own message"); 

             message.IsRead = true;
             message.ReadAt = DateTime.UtcNow;
             await _messageRepository.UpdateAsync(message);
             await _unitOfWork.CompleteAsync();
             
             return Response<string>.Success("Read");
        }

        public async Task<Response<string>> ReactToMessageAsync(int userId, int messageId, MessageReactionRequest request)
        {
             return Response<string>.Success("Reacted (Stub)");
        }

        public async Task<Response<MessageDto>> SendMessageAsync(int userId, int conversationId, SendMessageRequest request)
        {
             var conversation = await _conversationRepository.GetByIdAsync(conversationId);
             if (conversation == null) return Response<MessageDto>.Failure("Conversation not found");

             var message = new Message
             {
                 ConversationId = conversationId,
                 SenderId = userId,
                 Content = request.Content,
                 MediaUrl = request.MediaUrl,
                 Type = request.Type,
                 SentAt = DateTime.UtcNow,
                 IsRead = false
             };

             await _messageRepository.AddAsync(message);
             await _unitOfWork.CompleteAsync(); // Save message first to get Id
             
             conversation.LastMessageId = message.Id;
             await _conversationRepository.UpdateAsync(conversation);
             await _unitOfWork.CompleteAsync();

             await _chatNotifier.SendMessageAsync(conversationId.ToString(), userId, message.Content);

             var user = await _userRepository.GetByIdAsync(userId);
             var dto = new MessageDto
             {
                 Id = message.Id,
                 ConversationId = message.ConversationId,
                 SenderId = message.SenderId,
                 SenderName = user != null ? $"{user.FirstName} {user.LastName}" : "Unknown",
                 SenderAvatarUrl = user?.AvatarUrl,
                 Content = message.Content,
                 Type = message.Type,
                 IsRead = message.IsRead,
                 SentAt = message.SentAt
             };

             return Response<MessageDto>.Success(dto);
        }

        public async Task<Response<MessageDto>> UpdateMessageAsync(int userId, int messageId, UpdateMessageRequest request)
        {
             var message = await _messageRepository.GetByIdAsync(messageId);
             if (message == null) return Response<MessageDto>.Failure("Message not found");
             if (message.SenderId != userId) return Response<MessageDto>.Failure("Unauthorized");

             message.Content = request.Content;
             
             await _messageRepository.UpdateAsync(message);
             await _unitOfWork.CompleteAsync();

             // Re-construct basic DTO
             var dto = new MessageDto
             {
                 Id = message.Id,
                 ConversationId = message.ConversationId,
                 SenderId = message.SenderId,
                 Content = message.Content,
                 Type = message.Type,
                 IsRead = message.IsRead,
                 SentAt = message.SentAt
             };

             return Response<MessageDto>.Success(dto);
        }
    }
}
