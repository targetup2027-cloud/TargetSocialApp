import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/repositories/notifications_repository.dart';
import '../data/repositories/in_memory_notifications_repository.dart';
import '../../social/application/current_user_provider.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  final repo = InMemoryNotificationsRepository();
  ref.onDispose(() {
    repo.dispose();
  });
  return repo;
});

final notificationsProvider =
    StreamProvider.family<List<NotificationEntity>, String>(
        (ref, userId) async* {
  final repository = ref.watch(notificationsRepositoryProvider);
  final initial = await repository.listNotificationsForUser(userId);
  yield initial;
  yield* repository.watchNotificationsForUser(userId);
});

final currentUserNotificationsProvider =
    Provider<AsyncValue<List<NotificationEntity>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(notificationsProvider(userId));
});

final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) async* {
  final repository = ref.watch(notificationsRepositoryProvider);
  final initial = await repository.getUnreadCount(userId);
  yield initial;
  yield* repository.watchUnreadCount(userId);
});

final currentUserUnreadCountProvider = Provider<AsyncValue<int>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(unreadCountProvider(userId));
});

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final NotificationsRepository _repository;
  final String userId;
  StreamSubscription<List<NotificationEntity>>? _subscription;

  NotificationsController(this._repository, this.userId)
      : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final initial = await _repository.listNotificationsForUser(userId);
      state = AsyncValue.data(initial);
      _subscription = _repository.watchNotificationsForUser(userId).listen(
        (notifications) {
          state = AsyncValue.data(notifications);
        },
        onError: (e, st) {
          state = AsyncValue.error(e, st);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final notifications = await _repository.listNotificationsForUser(userId);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _repository.markRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllRead(userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final notificationsControllerProvider = StateNotifierProvider.family<
    NotificationsController,
    AsyncValue<List<NotificationEntity>>,
    String>((ref, userId) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsController(repository, userId);
});
