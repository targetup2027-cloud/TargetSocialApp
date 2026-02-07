import 'package:uuid/uuid.dart';
import '../domain/entities/notification_entity.dart';
import '../domain/repositories/notifications_repository.dart';

class NotificationService {
  final NotificationsRepository _repository;
  static const _uuid = Uuid();

  NotificationService(this._repository);

  Future<void> createFollowNotification({
    required String actorUserId,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String targetUserId,
  }) async {
    if (actorUserId == targetUserId) return;

    final dedupeKey = NotificationEntity.computeDedupeKey(
      type: NotificationType.followed,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
    );

    final notification = NotificationEntity(
      id: _uuid.v4(),
      type: NotificationType.followed,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      targetUserId: targetUserId,
      title: 'New Follower',
      body: '$actorDisplayName started following you',
      createdAt: DateTime.now(),
      deepLink: NotificationDeepLink(
        routeName: 'visitor-profile',
        pathParameters: {'userId': actorUserId},
      ),
      dedupeKey: dedupeKey,
    );

    await _repository.addNotification(notification);
  }

  Future<void> createUnfollowNotification({
    required String actorUserId,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String targetUserId,
  }) async {
    if (actorUserId == targetUserId) return;

    final dedupeKey = NotificationEntity.computeDedupeKey(
      type: NotificationType.unfollowed,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
    );

    final notification = NotificationEntity(
      id: _uuid.v4(),
      type: NotificationType.unfollowed,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      targetUserId: targetUserId,
      title: 'Unfollowed',
      body: '$actorDisplayName unfollowed you',
      createdAt: DateTime.now(),
      deepLink: NotificationDeepLink(
        routeName: 'visitor-profile',
        pathParameters: {'userId': actorUserId},
      ),
      dedupeKey: dedupeKey,
    );

    await _repository.addNotification(notification);
  }

  Future<void> createMessageNotification({
    required String actorUserId,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String targetUserId,
    required String conversationId,
    String? messagePreview,
  }) async {
    if (actorUserId == targetUserId) return;

    final dedupeKey = NotificationEntity.computeDedupeKey(
      type: NotificationType.messageReceived,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
      entityId: conversationId,
    );

    final notification = NotificationEntity(
      id: _uuid.v4(),
      type: NotificationType.messageReceived,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      targetUserId: targetUserId,
      entityId: conversationId,
      title: 'New Message',
      body: messagePreview ?? '$actorDisplayName sent you a message',
      createdAt: DateTime.now(),
      deepLink: NotificationDeepLink(
        routeName: 'messages',
        extra: {'conversationId': conversationId},
      ),
      metadata: {'conversationId': conversationId},
      dedupeKey: dedupeKey,
    );

    await _repository.addNotification(notification);
  }

  Future<void> createPostLikedNotification({
    required String actorUserId,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String targetUserId,
    required String postId,
  }) async {
    if (actorUserId == targetUserId) return;

    final dedupeKey = NotificationEntity.computeDedupeKey(
      type: NotificationType.postLiked,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
      entityId: postId,
    );

    final notification = NotificationEntity(
      id: _uuid.v4(),
      type: NotificationType.postLiked,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      targetUserId: targetUserId,
      entityId: postId,
      title: 'Post Liked',
      body: '$actorDisplayName liked your post',
      createdAt: DateTime.now(),
      deepLink: NotificationDeepLink(
        routeName: 'social',
        extra: {'postId': postId},
      ),
      metadata: {'postId': postId},
      dedupeKey: dedupeKey,
    );

    await _repository.addNotification(notification);
  }

  Future<void> createCommentNotification({
    required String actorUserId,
    required String actorDisplayName,
    String? actorAvatarUrl,
    required String targetUserId,
    required String postId,
    required String commentId,
    String? commentPreview,
  }) async {
    if (actorUserId == targetUserId) return;

    final dedupeKey = NotificationEntity.computeDedupeKey(
      type: NotificationType.commentAdded,
      actorUserId: actorUserId,
      targetUserId: targetUserId,
      entityId: commentId,
    );

    final notification = NotificationEntity(
      id: _uuid.v4(),
      type: NotificationType.commentAdded,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      actorAvatarUrl: actorAvatarUrl,
      targetUserId: targetUserId,
      entityId: commentId,
      title: 'New Comment',
      body: commentPreview ?? '$actorDisplayName commented on your post',
      createdAt: DateTime.now(),
      deepLink: NotificationDeepLink(
        routeName: 'social',
        extra: {'postId': postId, 'commentId': commentId},
      ),
      metadata: {'postId': postId, 'commentId': commentId},
      dedupeKey: dedupeKey,
    );

    await _repository.addNotification(notification);
  }
}
