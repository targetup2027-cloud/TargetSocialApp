class Conversation {
  final String id;
  final List<ConversationParticipant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isGroup;
  final String? groupName;
  final String? groupImageUrl;
  final bool isMuted;
  final bool isPinned;

  const Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isGroup = false,
    this.groupName,
    this.groupImageUrl,
    this.isMuted = false,
    this.isPinned = false,
  });

  Conversation copyWith({
    String? id,
    List<ConversationParticipant>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isGroup,
    String? groupName,
    String? groupImageUrl,
    bool? isMuted,
    bool? isPinned,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupImageUrl: groupImageUrl ?? this.groupImageUrl,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class ConversationParticipant {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeenAt;

  const ConversationParticipant({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeenAt,
  });
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? content;
  final MessageType type;
  final List<String> mediaUrls;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? replyToMessageId;
  final Message? replyToMessage;
  final List<MessageReaction> reactions;
  final bool isDeleted;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    this.content,
    this.type = MessageType.text,
    this.mediaUrls = const [],
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.readAt,
    this.replyToMessageId,
    this.replyToMessage,
    this.reactions = const [],
    this.isDeleted = false,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageType? type,
    List<String>? mediaUrls,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    String? replyToMessageId,
    Message? replyToMessage,
    List<MessageReaction>? reactions,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      reactions: reactions ?? this.reactions,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  sticker,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageReaction {
  final String emoji;
  final String userId;
  final DateTime createdAt;

  const MessageReaction({
    required this.emoji,
    required this.userId,
    required this.createdAt,
  });
}
