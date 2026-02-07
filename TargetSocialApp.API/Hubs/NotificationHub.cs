using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace TargetSocialApp.API.Hubs
{
    public class NotificationHub : Hub
    {
        // Users connect and identify themselves (usually via JWT Token in Query String)
        // Groups.AddToGroupAsync(Context.ConnectionId, userId) done typically in OnConnectedAsync

        public override async Task OnConnectedAsync()
        {
            // Simple mapping: typically you get User ID from claims
            var userId = Context.User?.FindFirst("uid")?.Value;
            if (userId != null)
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
            }
            await base.OnConnectedAsync();
        }

        public async Task SendNotification(string userId, string message)
        {
            await Clients.Group($"user_{userId}").SendAsync("ReceiveNotification", message);
        }
    }
}
