import 'dart:async';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/message_model.dart';
import '../datasources/messages_remote_data_source.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final bool useMockData;
  final MessagesRemoteDataSource? remoteDataSource;

  final _newMessageController = StreamController<Message>.broadcast();
  final _messageUpdatedController = StreamController<Message>.broadcast();
  final _conversationUpdatedController = StreamController<Conversation>.broadcast();
  final Map<String, StreamController<TypingIndicator>> _typingControllers = {};
  
  List<Conversation>? _cachedConversations;
  final Map<String, List<Message>> _cachedMessages = {};

  MessagesRepositoryImpl({this.useMockData = true, this.remoteDataSource});

  @override
  Future<List<Conversation>> getConversations({int page = 1, int limit = 20}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      _cachedConversations ??= _getMockConversations();
      return _cachedConversations!;
    }
    return remoteDataSource!.getConversations();
  }

  @override
  Future<Conversation> getConversationById(String conversationId) async {
    if (useMockData) {
      final conversations = _getMockConversations();
      return conversations.firstWhere((c) => c.id == conversationId);
    }
    return remoteDataSource!.getConversationById(conversationId);
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
            username: 'yazan_codes',
            displayName: 'Yazan Al-Rashid',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isGroup: participantIds.length > 1,
        groupName: groupName,
        groupImageUrl: groupImageUrl,
      );
    }
    return remoteDataSource!.createConversation(
      participantIds: participantIds,
      title: groupName,
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    if (useMockData) return;
    await remoteDataSource!.deleteConversation(conversationId);
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
      _cachedMessages[conversationId] ??= _getMockMessages(conversationId);
      return _cachedMessages[conversationId]!;
    }
    return remoteDataSource!.getMessages(conversationId);
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
        senderName: 'Yazan Al-Rashid',
        content: content,
        type: type,
        mediaUrls: mediaUrls ?? [],
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        replyToMessageId: replyToMessageId,
      );
      
      _cachedMessages[conversationId] ??= [];
      _cachedMessages[conversationId]!.add(message);
      
      if (_cachedConversations != null) {
        final index = _cachedConversations!.indexWhere((c) => c.id == conversationId);
        if (index >= 0) {
          _cachedConversations![index] = _cachedConversations![index].copyWith(
            lastMessage: message,
            updatedAt: message.createdAt,
          );
        }
      }
      
      _newMessageController.add(message);
      return message;
    }
    return remoteDataSource!.sendMessage(
      conversationId: conversationId,
      content: content ?? '',
      type: type,
    );
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    if (useMockData) return;
    await remoteDataSource!.deleteMessage(messageId);
  }

  @override
  Future<void> deleteMultipleMessages(String conversationId, List<String> messageIds) async {
    if (useMockData) return;
    for (final id in messageIds) {
      await remoteDataSource!.deleteMessage(id);
    }
  }

  @override
  Future<void> clearConversationForMe(String conversationId) async {
    if (useMockData) return;
    // No direct API for clear conversation
  }

  @override
  Future<void> markAsRead(String conversationId, String messageId) async {
    if (useMockData) return;
    await remoteDataSource!.markMessageAsRead(messageId);
  }

  @override
  Future<void> markConversationAsRead(String conversationId) async {
    if (useMockData) return;
    // Mark all messages in conversation as read
  }

  @override
  Future<Message> addReaction(String messageId, String emoji) async {
    throw UnimplementedError();
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    if (useMockData) return;
    // No direct API for remove reaction
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
        final messageMatch = c.lastMessage?.content?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return participantMatch || groupMatch || messageMatch;
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
    // Typing indicator handled client-side
  }

  @override
  Future<void> stopTyping(String conversationId) async {
    if (useMockData) return;
    // Typing indicator handled client-side
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
            username: 'layla_design',
            displayName: 'Layla Ahmed',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            isVerified: true,
            isOnline: true,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm1',
          conversationId: 'conv1',
          senderId: 'user1',
          senderName: 'Layla Ahmed',
          content: 'The new design looks amazing! 🔥',
          type: MessageType.text,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        unreadCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ConversationModel(
        id: 'conv2',
        participants: const [
          ConversationParticipantModel(
            id: 'user2',
            username: 'omar_tech',
            displayName: 'Omar Hassan',
            avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
            isOnline: true,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm2',
          conversationId: 'conv2',
          senderId: 'currentUser',
          senderName: 'You',
          content: 'I\'ll send you the files tonight',
          type: MessageType.text,
          status: MessageStatus.read,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ConversationModel(
        id: 'conv3',
        participants: const [
          ConversationParticipantModel(
            id: 'user3',
            username: 'sara_flutter',
            displayName: 'Sara Mahmoud',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
            isVerified: true,
            isOnline: false,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm3',
          conversationId: 'conv3',
          senderId: 'user3',
          senderName: 'Sara Mahmoud',
          content: 'Can we schedule a call tomorrow?',
          type: MessageType.text,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 21)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        isPinned: true,
      ),
      ConversationModel(
        id: 'conv4',
        participants: const [
          ConversationParticipantModel(
            id: 'user4',
            username: 'ahmed_dev',
            displayName: 'Ahmed Khaled',
            avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            isOnline: true,
          ),
          ConversationParticipantModel(
            id: 'user5',
            username: 'nour_pm',
            displayName: 'Nour Ali',
            avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
            isVerified: true,
          ),
        ],
        groupName: 'U-AXIS Team',
        groupImageUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=150',
        isGroup: true,
        lastMessage: MessageModel(
          id: 'm4',
          conversationId: 'conv4',
          senderId: 'user4',
          senderName: 'Ahmed Khaled',
          content: 'Sprint review meeting in 30 min!',
          type: MessageType.text,
          status: MessageStatus.delivered,
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        unreadCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isPinned: true,
      ),
      ConversationModel(
        id: 'conv5',
        participants: const [
          ConversationParticipantModel(
            id: 'user6',
            username: 'maya_ui',
            displayName: 'Maya Ibrahim',
            avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
            isOnline: false,
          ),
        ],
        lastMessage: MessageModel(
          id: 'm5',
          conversationId: 'conv5',
          senderId: 'user6',
          senderName: 'Maya Ibrahim',
          content: 'Thanks for the feedback! 💜',
          type: MessageType.text,
          status: MessageStatus.read,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        isMuted: true,
      ),
    ];
  }

  List<Message> _getMockMessages(String conversationId) {
    return [
      MessageModel(
        id: 'msg1',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Layla Ahmed',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'Hey! I saw your latest work on the app 👀',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      MessageModel(
        id: 'msg2',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'Thanks! Been working on it all week. What do you think?',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      MessageModel(
        id: 'msg3',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Layla Ahmed',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'The chat bubbles look so clean now! Love the emerald color scheme 💚',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      MessageModel(
        id: 'msg4',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'Right?! The gradient makes it pop. Also added smooth transitions between screens.',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: 'msg5',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Layla Ahmed',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'The navigation is so much smoother now. Great work on the MotionPageRoute implementation!',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      MessageModel(
        id: 'msg6',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'Thanks! Used easeOutCubic for that snappy feel 🚀',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      MessageModel(
        id: 'msg7',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Layla Ahmed',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'The profile screen loading is much better too. That skeleton animation is chef\'s kiss 👨‍🍳✨',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      MessageModel(
        id: 'msg8',
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: 'Shimmer loading FTW! Way better than a boring spinner',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      MessageModel(
        id: 'msg9',
        conversationId: conversationId,
        senderId: 'user1',
        senderName: 'Layla Ahmed',
        senderAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'The new design looks amazing! 🔥',
        type: MessageType.text,
        status: MessageStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
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
