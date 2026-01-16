using Microsoft.AspNetCore.Mvc;
using TargetSocialApp.Application.Features.Notifications;
using TargetSocialApp.Application.Features.Notifications.Requests;

namespace TargetSocialApp.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationsController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications()
        {
            int userId = 1;
            var response = await _notificationService.GetNotificationsAsync(userId);
            return Ok(response);
        }

        [HttpPut("{notificationId}/read")]
        public async Task<IActionResult> MarkRead(int notificationId)
        {
            int userId = 1;
            var response = await _notificationService.MarkAsReadAsync(userId, notificationId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpPut("mark-all-read")]
        public async Task<IActionResult> MarkAllRead()
        {
            int userId = 1;
            var response = await _notificationService.MarkAllAsReadAsync(userId);
            return Ok(response);
        }

        [HttpDelete("{notificationId}")]
        public async Task<IActionResult> DeleteNotification(int notificationId)
        {
            int userId = 1;
            var response = await _notificationService.DeleteNotificationAsync(userId, notificationId);
            if (!response.Succeeded) return BadRequest(response);
            return Ok(response);
        }

        [HttpGet("unread-count")]
        public async Task<IActionResult> GetUnreadCount()
        {
            int userId = 1;
            var response = await _notificationService.GetUnreadCountAsync(userId);
            return Ok(response);
        }

        [HttpGet("settings")]
        public async Task<IActionResult> GetSettings()
        {
            int userId = 1;
            var response = await _notificationService.GetSettingsAsync(userId);
            return Ok(response);
        }

        [HttpPut("settings")]
        public async Task<IActionResult> UpdateSettings([FromBody] UpdateNotificationSettingsRequest request)
        {
            int userId = 1;
            var response = await _notificationService.UpdateSettingsAsync(userId, request);
            return Ok(response);
        }
    }
}
