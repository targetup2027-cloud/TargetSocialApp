using System.Threading.Tasks;

namespace TargetSocialApp.Application.Common.Interfaces
{
    public interface IChatNotifier
    {
        Task SendMessageAsync(string conversationId, int userId, string message);
        Task NotifyUserTypingAsync(string conversationId, string userName);
    }
}
