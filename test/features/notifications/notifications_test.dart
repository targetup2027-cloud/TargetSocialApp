import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:social_app/features/notifications/data/repositories/in_memory_notifications_repository.dart';
import 'package:social_app/features/notifications/application/notification_service.dart';

void main() {
  late InMemoryNotificationsRepository repository;
  late NotificationService notificationService;

  setUp(() {
    repository = InMemoryNotificationsRepository();
    notificationService = NotificationService(repository);
  });

  tearDown(() {
    repository.dispose();
  });

  group('NotificationEntity', () {
    test('computeDedupeKey generates consistent keys', () {
      final key1 = NotificationEntity.computeDedupeKey(
        type: NotificationType.followed,
        actorUserId: 'actor1',
        targetUserId: 'target1',
      );

      final key2 = NotificationEntity.computeDedupeKey(
        type: NotificationType.followed,
        actorUserId: 'actor1',
        targetUserId: 'target1',
      );

      expect(key1, equals(key2));
    });

    test('computeDedupeKey includes entityId when provided', () {
      final keyWithEntity = NotificationEntity.computeDedupeKey(
        type: NotificationType.postLiked,
        actorUserId: 'actor1',
        targetUserId: 'target1',
        entityId: 'post123',
      );

      final keyWithoutEntity = NotificationEntity.computeDedupeKey(
        type: NotificationType.postLiked,
        actorUserId: 'actor1',
        targetUserId: 'target1',
      );

      expect(keyWithEntity, isNot(equals(keyWithoutEntity)));
      expect(keyWithEntity, contains('post123'));
    });

    test('categoryGroup returns correct category for each type', () {
      final followNotification = NotificationEntity(
        id: '1',
        type: NotificationType.followed,
        actorUserId: 'actor',
        actorDisplayName: 'Actor',
        targetUserId: 'target',
        title: 'Follow',
        body: 'Body',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'key1',
      );

      final messageNotification = NotificationEntity(
        id: '2',
        type: NotificationType.messageReceived,
        actorUserId: 'actor',
        actorDisplayName: 'Actor',
        targetUserId: 'target',
        title: 'Message',
        body: 'Body',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'messages'),
        dedupeKey: 'key2',
      );

      final likeNotification = NotificationEntity(
        id: '3',
        type: NotificationType.postLiked,
        actorUserId: 'actor',
        actorDisplayName: 'Actor',
        targetUserId: 'target',
        title: 'Like',
        body: 'Body',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'social'),
        dedupeKey: 'key3',
      );

      expect(followNotification.categoryGroup, equals('Social'));
      expect(messageNotification.categoryGroup, equals('Messages'));
      expect(likeNotification.categoryGroup, equals('Engagement'));
    });
  });

  group('InMemoryNotificationsRepository', () {
    test('addNotification stores notification correctly', () async {
      final notification = NotificationEntity(
        id: 'notif1',
        type: NotificationType.followed,
        actorUserId: 'actor1',
        actorDisplayName: 'John',
        targetUserId: 'target1',
        title: 'New Follower',
        body: 'John started following you',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'dedupe1',
      );

      await repository.addNotification(notification);
      final list = await repository.listNotificationsForUser('target1');

      expect(list.length, equals(1));
      expect(list.first.id, equals('notif1'));
    });

    test('idempotency: duplicate dedupeKey is ignored', () async {
      final notification1 = NotificationEntity(
        id: 'notif1',
        type: NotificationType.followed,
        actorUserId: 'actor1',
        actorDisplayName: 'John',
        targetUserId: 'target1',
        title: 'New Follower',
        body: 'John started following you',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'same-key',
      );

      final notification2 = NotificationEntity(
        id: 'notif2',
        type: NotificationType.followed,
        actorUserId: 'actor1',
        actorDisplayName: 'John',
        targetUserId: 'target1',
        title: 'New Follower Again',
        body: 'John started following you again',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'same-key',
      );

      await repository.addNotification(notification1);
      await repository.addNotification(notification2);
      final list = await repository.listNotificationsForUser('target1');

      expect(list.length, equals(1));
      expect(list.first.id, equals('notif1'));
    });

    test('markRead updates notification correctly', () async {
      final notification = NotificationEntity(
        id: 'notif1',
        type: NotificationType.followed,
        actorUserId: 'actor1',
        actorDisplayName: 'John',
        targetUserId: 'target1',
        title: 'New Follower',
        body: 'John started following you',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'dedupe1',
      );

      await repository.addNotification(notification);
      expect((await repository.listNotificationsForUser('target1')).first.isRead, isFalse);

      await repository.markRead('notif1');
      expect((await repository.listNotificationsForUser('target1')).first.isRead, isTrue);
    });

    test('markAllRead updates all notifications for user', () async {
      for (var i = 0; i < 3; i++) {
        await repository.addNotification(NotificationEntity(
          id: 'notif$i',
          type: NotificationType.followed,
          actorUserId: 'actor$i',
          actorDisplayName: 'Actor $i',
          targetUserId: 'target1',
          title: 'Title',
          body: 'Body',
          createdAt: DateTime.now(),
          deepLink: const NotificationDeepLink(routeName: 'profile'),
          dedupeKey: 'key$i',
        ));
      }

      var unreadCount = await repository.getUnreadCount('target1');
      expect(unreadCount, equals(3));

      await repository.markAllRead('target1');

      unreadCount = await repository.getUnreadCount('target1');
      expect(unreadCount, equals(0));
    });

    test('getUnreadCount returns correct count', () async {
      await repository.addNotification(NotificationEntity(
        id: 'notif1',
        type: NotificationType.followed,
        actorUserId: 'actor1',
        actorDisplayName: 'Actor',
        targetUserId: 'target1',
        title: 'Title',
        body: 'Body',
        createdAt: DateTime.now(),
        deepLink: const NotificationDeepLink(routeName: 'profile'),
        dedupeKey: 'key1',
      ));

      await repository.addNotification(NotificationEntity(
        id: 'notif2',
        type: NotificationType.messageReceived,
        actorUserId: 'actor2',
        actorDisplayName: 'Actor',
        targetUserId: 'target1',
        title: 'Title',
        body: 'Body',
        createdAt: DateTime.now(),
        isRead: true,
        deepLink: const NotificationDeepLink(routeName: 'messages'),
        dedupeKey: 'key2',
      ));

      final unreadCount = await repository.getUnreadCount('target1');
      expect(unreadCount, equals(1));
    });
  });

  group('NotificationService', () {
    test('createFollowNotification creates notification for target', () async {
      await notificationService.createFollowNotification(
        actorUserId: 'user1',
        actorDisplayName: 'Alice',
        targetUserId: 'user2',
      );

      final list = await repository.listNotificationsForUser('user2');
      expect(list.length, equals(1));
      expect(list.first.type, equals(NotificationType.followed));
      expect(list.first.actorDisplayName, equals('Alice'));
    });

    test('createFollowNotification ignores self-follow', () async {
      await notificationService.createFollowNotification(
        actorUserId: 'user1',
        actorDisplayName: 'Alice',
        targetUserId: 'user1',
      );

      final list = await repository.listNotificationsForUser('user1');
      expect(list.length, equals(0));
    });

    test('createMessageNotification includes conversation deep link', () async {
      await notificationService.createMessageNotification(
        actorUserId: 'sender1',
        actorDisplayName: 'Bob',
        targetUserId: 'receiver1',
        conversationId: 'conv123',
        messagePreview: 'Hello!',
      );

      final list = await repository.listNotificationsForUser('receiver1');
      expect(list.length, equals(1));
      expect(list.first.deepLink.routeName, equals('messages'));
      expect(list.first.deepLink.extra?['conversationId'], equals('conv123'));
    });

    test('createPostLikedNotification creates engagement notification', () async {
      await notificationService.createPostLikedNotification(
        actorUserId: 'liker1',
        actorDisplayName: 'Charlie',
        targetUserId: 'author1',
        postId: 'post123',
      );

      final list = await repository.listNotificationsForUser('author1');
      expect(list.length, equals(1));
      expect(list.first.type, equals(NotificationType.postLiked));
      expect(list.first.categoryGroup, equals('Engagement'));
    });

    test('createCommentNotification includes post and comment info', () async {
      await notificationService.createCommentNotification(
        actorUserId: 'commenter1',
        actorDisplayName: 'Diana',
        targetUserId: 'author1',
        postId: 'post123',
        commentId: 'comment456',
        commentPreview: 'Great post!',
      );

      final list = await repository.listNotificationsForUser('author1');
      expect(list.length, equals(1));
      expect(list.first.type, equals(NotificationType.commentAdded));
      expect(list.first.metadata['postId'], equals('post123'));
      expect(list.first.metadata['commentId'], equals('comment456'));
    });
  });

  group('NotificationDeepLink', () {
    test('supports path parameters', () {
      const deepLink = NotificationDeepLink(
        routeName: 'visitor-profile',
        pathParameters: {'userId': 'user123'},
      );

      expect(deepLink.pathParameters['userId'], equals('user123'));
    });

    test('supports extra data', () {
      const deepLink = NotificationDeepLink(
        routeName: 'messages',
        extra: {'conversationId': 'conv123', 'highlight': true},
      );

      expect(deepLink.extra?['conversationId'], equals('conv123'));
      expect(deepLink.extra?['highlight'], isTrue);
    });
  });
}
