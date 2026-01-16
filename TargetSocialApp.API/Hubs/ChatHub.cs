using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace TargetSocialApp.API.Hubs
{
    public class ChatHub : Hub
    {
        public async Task SendMessage(string conversationId, string user, string message)
        {
            await Clients.Group(conversationId).SendAsync("ReceiveMessage", user, message);
        }

        public async Task JoinConversation(string conversationId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, conversationId);
        }

        public async Task LeaveConversation(string conversationId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, conversationId);
        }
        
        public async Task Typing(string conversationId, string user)
        {
             await Clients.Group(conversationId).SendAsync("UserTyping", user);
        }
    }
}
