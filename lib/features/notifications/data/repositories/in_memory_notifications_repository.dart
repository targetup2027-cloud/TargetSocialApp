import 'dart:async';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class InMemoryNotificationsRepository implements NotificationsRepository {
  final Map<String, List<NotificationEntity>> _store = {};
  final Map<String, Set<String>> _dedupeKeys = {};

  final StreamController<MapEntry<String, List<NotificationEntity>>>
      _notificationsController =
      StreamController<MapEntry<String, List<NotificationEntity>>>.broadcast();

  final StreamController<MapEntry<String, int>> _unreadCountController =
      StreamController<MapEntry<String, int>>.broadcast();

  @override
  Stream<List<NotificationEntity>> watchNotificationsForUser(String userId) {
    return _notificationsController.stream
        .where((entry) => entry.key == userId)
        .map((entry) => entry.value)
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) => sink.add(data),
          ),
        );
  }

  @override
  Future<List<NotificationEntity>> listNotificationsForUser(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _store[userId] ?? [];
    return List.from(list)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    final userId = notification.targetUserId;
    final dedupeKey = notification.dedupeKey;

    _dedupeKeys.putIfAbsent(userId, () => {});
    if (_dedupeKeys[userId]!.contains(dedupeKey)) {
      return;
    }

    _dedupeKeys[userId]!.add(dedupeKey);
    _store.putIfAbsent(userId, () => []);
    _store[userId]!.add(notification);

    _emitUpdate(userId);
  }

  @override
  Future<void> markRead(String notificationId) async {
    for (final entry in _store.entries) {
      final idx = entry.value.indexWhere((n) => n.id == notificationId);
      if (idx >= 0) {
        final notification = entry.value[idx];
        if (!notification.isRead) {
          entry.value[idx] = notification.copyWith(isRead: true);
          _emitUpdate(entry.key);
        }
        break;
      }
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    final list = _store[userId];
    if (list == null) return;

    var changed = false;
    for (var i = 0; i < list.length; i++) {
      if (!list[i].isRead) {
        list[i] = list[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _emitUpdate(userId);
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final list = _store[userId] ?? [];
    return list.where((n) => !n.isRead).length;
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _unreadCountController.stream
        .where((entry) => entry.key == userId)
        .map((entry) => entry.value);
  }

  @override
  Future<void> clearAllForUser(String userId) async {
    _store.remove(userId);
    _dedupeKeys.remove(userId);
    _emitUpdate(userId);
  }

  void _emitUpdate(String userId) {
    final list = List<NotificationEntity>.from(_store[userId] ?? [])
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _notificationsController.add(MapEntry(userId, list));
    _unreadCountController
        .add(MapEntry(userId, list.where((n) => !n.isRead).length));
  }

  void dispose() {
    _notificationsController.close();
    _unreadCountController.close();
  }
}
