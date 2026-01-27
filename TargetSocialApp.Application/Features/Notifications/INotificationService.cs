using System.Collections.Generic;
using System.Threading.Tasks;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Features.Notifications.Requests;
using TargetSocialApp.Domain.Entities;

using TargetSocialApp.Application.Features.Notifications.DTOs;

namespace TargetSocialApp.Application.Features.Notifications
{
    public interface INotificationService
    {
        Task<Response<List<NotificationDto>>> GetNotificationsAsync(int userId);
        Task<Response<string>> MarkAsReadAsync(int userId, int notificationId);
        Task<Response<string>> MarkAllAsReadAsync(int userId);
        Task<Response<string>> DeleteNotificationAsync(int userId, int notificationId);
        Task<Response<int>> GetUnreadCountAsync(int userId);
        
        // Settings
        Task<Response<NotificationSettingDto>> GetSettingsAsync(int userId);
        Task<Response<NotificationSettingDto>> UpdateSettingsAsync(int userId, UpdateNotificationSettingsRequest request);
    }
}
