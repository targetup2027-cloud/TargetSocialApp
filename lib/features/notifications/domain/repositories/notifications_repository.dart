import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationEntity>> watchNotificationsForUser(String userId);

  Future<List<NotificationEntity>> listNotificationsForUser(String userId);

  Future<void> addNotification(NotificationEntity notification);

  Future<void> markRead(String notificationId);

  Future<void> markAllRead(String userId);

  Future<int> getUnreadCount(String userId);

  Stream<int> watchUnreadCount(String userId);

  Future<void> clearAllForUser(String userId);
}
