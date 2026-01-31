import '../../domain/entities/message.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.participants,
    super.lastMessage,
    super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
    super.isGroup,
    super.groupName,
    super.groupImageUrl,
    super.isMuted,
    super.isPinned,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => ConversationParticipantModel.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null 
          ? MessageModel.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isGroup: json['isGroup'] as bool? ?? false,
      groupName: json['groupName'] as String?,
      groupImageUrl: json['groupImageUrl'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => (p as ConversationParticipantModel).toJson()).toList(),
      'lastMessage': lastMessage != null ? (lastMessage as MessageModel).toJson() : null,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImageUrl': groupImageUrl,
      'isMuted': isMuted,
      'isPinned': isPinned,
    };
  }
}

class ConversationParticipantModel extends ConversationParticipant {
  const ConversationParticipantModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    super.isVerified,
    super.isOnline,
    super.lastSeenAt,
  });

  factory ConversationParticipantModel.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null 
          ? DateTime.parse(json['lastSeenAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
    };
  }
}

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatarUrl,
    super.content,
    super.type,
    super.mediaUrls,
    super.status,
    required super.createdAt,
    super.readAt,
    super.replyToMessageId,
    super.replyToMessage,
    super.reactions,
    super.isDeleted,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String?,
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
      status: MessageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String) 
          : null,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToMessage: json['replyToMessage'] != null 
          ? MessageModel.fromJson(json['replyToMessage']) 
          : null,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => MessageReactionModel.fromJson(r))
          .toList() ?? [],
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'type': type.name,
      'mediaUrls': mediaUrls,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'replyToMessageId': replyToMessageId,
      'replyToMessage': replyToMessage != null ? (replyToMessage as MessageModel).toJson() : null,
      'reactions': reactions.map((r) => (r as MessageReactionModel).toJson()).toList(),
      'isDeleted': isDeleted,
    };
  }
}

class MessageReactionModel extends MessageReaction {
  const MessageReactionModel({
    required super.emoji,
    required super.userId,
    required super.createdAt,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      emoji: json['emoji'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
