using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Mapster;
using Microsoft.EntityFrameworkCore;
using TargetSocialApp.Application.Common.Bases;
using TargetSocialApp.Application.Common.Interfaces;
using TargetSocialApp.Application.Features.Notifications.Requests;
using TargetSocialApp.Domain.Entities;

namespace TargetSocialApp.Application.Features.Notifications
{
    public class NotificationService : AppService, INotificationService
    {
        private readonly IGenericRepository<Notification> _notificationRepository;
        private readonly IGenericRepository<NotificationSetting> _settingsRepository;
        private readonly IUnitOfWork _unitOfWork;

        public NotificationService(
            IGenericRepository<Notification> notificationRepository,
            IGenericRepository<NotificationSetting> settingsRepository,
            IUnitOfWork unitOfWork)
        {
            _notificationRepository = notificationRepository;
            _settingsRepository = settingsRepository;
            _unitOfWork = unitOfWork;
        }

        public async Task<Response<string>> DeleteNotificationAsync(int userId, int notificationId)
        {
             var notification = await _notificationRepository.GetByIdAsync(notificationId);
             if (notification == null) return Response<string>.Failure("Not found");
             if (notification.UserId != userId) return Response<string>.Failure("Unauthorized");

             await _notificationRepository.DeleteAsync(notification);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Deleted");
        }

        public async Task<Response<List<Notification>>> GetNotificationsAsync(int userId)
        {
             var notifications = await _notificationRepository.GetTableNoTracking()
                 .Where(n => n.UserId == userId)
                 .OrderByDescending(n => n.CreatedAt)
                 .Take(50)
                 .ToListAsync();
             return Response<List<Notification>>.Success(notifications);
        }

        public async Task<Response<NotificationSetting>> GetSettingsAsync(int userId)
        {
             var settings = await _settingsRepository.GetTableNoTracking()
                 .FirstOrDefaultAsync(s => s.UserId == userId);
             
             if (settings == null)
             {
                 // Create default
                 settings = new NotificationSetting { UserId = userId, Likes = true, Comments = true, Mentions = true, NewFollowers = true, DirectMessages = true };
                 await _settingsRepository.AddAsync(settings);
                 await _unitOfWork.CompleteAsync();
             }
             return Response<NotificationSetting>.Success(settings);
        }

        public async Task<Response<int>> GetUnreadCountAsync(int userId)
        {
             var count = await _notificationRepository.GetTableNoTracking()
                 .CountAsync(n => n.UserId == userId && !n.IsRead);
             return Response<int>.Success(count);
        }

        public async Task<Response<string>> MarkAllAsReadAsync(int userId)
        {
             var unread = await _notificationRepository.GetTableNoTracking()
                 .Where(n => n.UserId == userId && !n.IsRead)
                 .ToListAsync(); // Need tracking for update - wait, GetTableNoTracking implies no tracking.
             
             // Better use UpdateRange with tracking
             var unreadTracking = await _notificationRepository.GetTableAsTracking()
                 .Where(n => n.UserId == userId && !n.IsRead)
                 .ToListAsync();

             foreach(var n in unreadTracking)
             {
                 n.IsRead = true;
             }
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("All marked as read");
        }

        public async Task<Response<string>> MarkAsReadAsync(int userId, int notificationId)
        {
             var notification = await _notificationRepository.GetByIdAsync(notificationId);
             if (notification == null) return Response<string>.Failure("Not found");
             
             notification.IsRead = true;
             await _notificationRepository.UpdateAsync(notification);
             await _unitOfWork.CompleteAsync();
             return Response<string>.Success("Marked as read");
        }

        public async Task<Response<NotificationSetting>> UpdateSettingsAsync(int userId, UpdateNotificationSettingsRequest request)
        {
             var settings = await _settingsRepository.GetTableAsTracking()
                 .FirstOrDefaultAsync(s => s.UserId == userId);
             
             if (settings == null)
             {
                 settings = new NotificationSetting { UserId = userId };
                 await _settingsRepository.AddAsync(settings);
             }

             request.Adapt(settings);
             await _settingsRepository.UpdateAsync(settings); // Redundant if tracking, but safe
             await _unitOfWork.CompleteAsync();
             
             return Response<NotificationSetting>.Success(settings);
        }
    }
}
