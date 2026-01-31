import 'dart:async';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/message_model.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final bool useMockData;

  final _newMessageController = StreamController<Message>.broadcast();
  final _messageUpdatedController = StreamController<Message>.broadcast();
  final _conversationUpdatedController = StreamController<Conversation>.broadcast();
  final Map<String, StreamController<TypingIndicator>> _typingControllers = {};

  MessagesRepositoryImpl({this.useMockData = true});

  @override
  Future<List<Conversation>> getConversations({int page = 1, int limit = 20}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockConversations();
    }
    throw UnimplementedError();
  }

  @override
  Future<Conversation> getConversationById(String conversationId) async {
    if (useMockData) {
      final conversations = _getMockConversations();
      return conversations.firstWhere((c) => c.id == conversationId);
    }
    throw UnimplementedError();
  }

  @override
  Future<Conversation> createConversation({
    required List<String> participantIds,
    String? groupName,
    String? groupImageUrl,
  }) async {
    if (useMockData) {
      return ConversationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        participants: [
          const ConversationParticipantModel(
            id: 'currentUser',
            username: 'you',
            displayName: 'You',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isGroup: participantIds.length > 1,
        groupName: groupName,
        groupImageUrl: groupImageUrl,
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _getMockMessages(conversationId);
    }
    throw UnimplementedError();
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    String? content,
    MessageType type = MessageType.text,
    List<String>? mediaUrls,
    String? replyToMessageId,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 100));
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: content,
        type: type,
        mediaUrls: mediaUrls ?? [],
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        replyToMessageId: replyToMessageId,
      );
      _newMessageController.add(message);
      return message;
    }
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> markAsRead(String conversationId, String messageId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<Message> addReaction(String messageId, String emoji) async {
    throw UnimplementedError();
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<Conversation> muteConversation(String conversationId, {Duration? duration}) async {
    final conv = await getConversationById(conversationId);
    return conv.copyWith(isMuted: true);
  }

  @override
  Future<Conversation> unmuteConversation(String conversationId) async {
    final conv = await getConversationById(conversationId);
    return conv.copyWith(isMuted: false);
  }

  @override
  Future<Conversation> pinConversation(String conversationId) async {
    final conv = await getConversationById(conversationId);
    return conv.copyWith(isPinned: true);
  }

  @override
  Future<Conversation> unpinConversation(String conversationId) async {
    final conv = await getConversationById(conversationId);
    return conv.copyWith(isPinned: false);
  }

  @override
  Future<List<Conversation>> searchConversations(String query) async {
    if (useMockData) {
      final conversations = _getMockConversations();
      return conversations.where((c) {
        final participantMatch = c.participants.any((p) =>
          p.displayName.toLowerCase().contains(query.toLowerCase()) ||
          p.username.toLowerCase().contains(query.toLowerCase())
        );
        final groupMatch = c.groupName?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return participantMatch || groupMatch;
      }).toList();
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Message>> searchMessages(String conversationId, String query) async {
    if (useMockData) {
      final messages = _getMockMessages(conversationId);
      return messages.where((m) =>
        m.content?.toLowerCase().contains(query.toLowerCase()) ?? false
      ).toList();
    }
    throw UnimplementedError();
  }

  @override
  Stream<Message> onNewMessage() => _newMessageController.stream;

  @override
  Stream<Message> onMessageUpdated() => _messageUpdatedController.stream;

  @override
  Stream<Conversation> onConversationUpdated() => _conversationUpdatedController.stream;

  @override
  Future<void> startTyping(String conversationId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> stopTyping(String conversationId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Stream<TypingIndicator> onTypingIndicator(String conversationId) {
    _typingControllers[conversationId] ??= StreamController<TypingIndicator>.broadcast();
    return _typingControllers[conversationId]!.stream;
  }

  List<Conversation> _getMockConversations() {
    return [
      ConversationModel(
        id: 'conv1',
        participants: const [
          ConversationParticipantModel(
            id: 'user1',
            username: 'sarahj',
            displayName: 'Sarah Johnson',
            avatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
            isVerified: true,
            isOnline: true,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm1',
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Sarah Johnson',
          content: 'Hey! How are you doing?',
          type: MessageType.text,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ConversationModel(
        id: 'conv2',
        participants: const [
          ConversationParticipantModel(
            id: 'user2',
            username: 'alexr',
            displayName: 'Alex Rivera',
            avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            isOnline: false,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm2',
          conversationId: 'conv2',
          senderId: 'currentUser',
          senderName: 'You',
          content: 'Sure, let me check and get back to you',
          type: MessageType.text,
          status: MessageStatus.read,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ConversationModel(
        id: 'conv3',
        participants: const [
          ConversationParticipantModel(
            id: 'user3',
            username: 'mikec',
            displayName: 'Mike Chen',
            avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            isOnline: true,
          ),
          ConversationParticipantModel(
            id: 'user4',
            username: 'emilyd',
            displayName: 'Emily Davis',
            avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
            isVerified: true,
          ),
        ],
        groupName: 'Project Team',
        isGroup: true,
        lastMessage: MessageModel(
          id: 'm3',
          conversationId: 'conv3',
          senderId: 'user3',
          senderName: 'Mike Chen',
          content: 'The meeting is scheduled for tomorrow at 2 PM',
          type: MessageType.text,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        unreadCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        isPinned: true,
      ),
    ];
  }

  List<Message> _getMockMessages(String conversationId) {
    return [
      MessageModel(
        id: 'msg1',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Sarah Johnson',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        content: 'Hey! How are you doing?',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: 'msg2',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'I\'m good! Just finished working on the new project.',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      MessageModel(
        id: 'msg3',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Sarah Johnson',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        content: 'That sounds great! Can you tell me more about it?',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      MessageModel(
        id: 'msg4',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'Sure! It\'s a social media app with some really cool features.',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      MessageModel(
        id: 'msg5',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Sarah Johnson',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        content: '🎉 Wow, that\'s amazing!',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  void dispose() {
    _newMessageController.close();
    _messageUpdatedController.close();
    _conversationUpdatedController.close();
    for (final controller in _typingControllers.values) {
      controller.close();
    }
  }
}
