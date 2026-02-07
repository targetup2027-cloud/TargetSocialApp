import 'package:equatable/equatable.dart';

enum NotificationType {
  followed,
  unfollowed,
  messageReceived,
  postLiked,
  commentAdded,
  mentionedInPost,
  mentionedInComment,
}

class NotificationDeepLink extends Equatable {
  final String routeName;
  final Map<String, String> pathParameters;
  final Map<String, dynamic>? extra;

  const NotificationDeepLink({
    required this.routeName,
    this.pathParameters = const {},
    this.extra,
  });

  @override
  List<Object?> get props => [routeName, pathParameters, extra];
}

class NotificationEntity extends Equatable {
  final String id;
  final NotificationType type;
  final String actorUserId;
  final String actorDisplayName;
  final String? actorAvatarUrl;
  final String targetUserId;
  final String? entityId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationDeepLink deepLink;
  final Map<String, dynamic> metadata;
  final String dedupeKey;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.actorUserId,
    required this.actorDisplayName,
    this.actorAvatarUrl,
    required this.targetUserId,
    this.entityId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    required this.deepLink,
    this.metadata = const {},
    required this.dedupeKey,
  });

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? actorUserId,
    String? actorDisplayName,
    String? actorAvatarUrl,
    String? targetUserId,
    String? entityId,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    NotificationDeepLink? deepLink,
    Map<String, dynamic>? metadata,
    String? dedupeKey,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      actorUserId: actorUserId ?? this.actorUserId,
      actorDisplayName: actorDisplayName ?? this.actorDisplayName,
      actorAvatarUrl: actorAvatarUrl ?? this.actorAvatarUrl,
      targetUserId: targetUserId ?? this.targetUserId,
      entityId: entityId ?? this.entityId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
      metadata: metadata ?? this.metadata,
      dedupeKey: dedupeKey ?? this.dedupeKey,
    );
  }

  static String computeDedupeKey({
    required NotificationType type,
    required String actorUserId,
    required String targetUserId,
    String? entityId,
  }) {
    return '${type.name}:$actorUserId:$targetUserId:${entityId ?? ''}';
  }

  String get categoryGroup {
    switch (type) {
      case NotificationType.followed:
      case NotificationType.unfollowed:
        return 'Social';
      case NotificationType.messageReceived:
        return 'Messages';
      case NotificationType.postLiked:
      case NotificationType.commentAdded:
      case NotificationType.mentionedInPost:
      case NotificationType.mentionedInComment:
        return 'Engagement';
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        actorUserId,
        actorDisplayName,
        actorAvatarUrl,
        targetUserId,
        entityId,
        title,
        body,
        createdAt,
        isRead,
        deepLink,
        metadata,
        dedupeKey,
      ];
}
