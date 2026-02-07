using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using TargetSocialApp.API.Hubs;
using TargetSocialApp.Application.Common.Interfaces;

namespace TargetSocialApp.API.Services
{
    public class ChatNotifier : IChatNotifier
    {
        private readonly IHubContext<ChatHub> _hubContext;

        public ChatNotifier(IHubContext<ChatHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public async Task NotifyUserTypingAsync(string conversationId, string userName)
        {
             await _hubContext.Clients.Group(conversationId).SendAsync("UserTyping", userName);
        }

        public async Task SendMessageAsync(string conversationId, int userId, string message)
        {
             await _hubContext.Clients.Group(conversationId).SendAsync("ReceiveMessage", userId, message);
        }
    }
}
