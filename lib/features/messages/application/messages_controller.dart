import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/message.dart';
import '../domain/repositories/messages_repository.dart';
import '../data/repositories/messages_repository_impl.dart';
import '../data/datasources/messages_remote_data_source.dart';
import '../../../core/validation/validators.dart';
import '../../notifications/application/notification_service.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../social/application/current_user_provider.dart';
import '../../profile/application/profile_controller.dart';
import '../../auth/data/datasources/auth_remote_data_source.dart';

final messagesRemoteDataSourceProvider = Provider<MessagesRemoteDataSource>((ref) {
  final client = ref.watch(networkClientProvider);
  return MessagesRemoteDataSourceImpl(client: client);
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(
    useMockData: false,
    remoteDataSource: ref.watch(messagesRemoteDataSourceProvider),
  );
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getConversations();
});

final conversationByIdProvider = FutureProvider.family<Conversation, String>((ref, id) async {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getConversationById(id);
});

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.getMessages(conversationId);
});

class ConversationsController extends StateNotifier<AsyncValue<List<Conversation>>> {
  final MessagesRepository _repository;
  StreamSubscription<Conversation>? _conversationSubscription;

  ConversationsController(this._repository) : super(const AsyncValue.loading()) {
    loadConversations();
    _listenToUpdates();
  }

  void _listenToUpdates() {
    _conversationSubscription = _repository.onConversationUpdated().listen((updatedConv) {
      final currentList = state.valueOrNull ?? [];
      final index = currentList.indexWhere((c) => c.id == updatedConv.id);
      if (index >= 0) {
        final updatedList = [...currentList];
        updatedList[index] = updatedConv;
        state = AsyncValue.data(_sortConversations(updatedList));
      }
    });
  }

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getConversations();
      final sortedConversations = _sortConversations(conversations);
      state = AsyncValue.data(sortedConversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<Conversation> _sortConversations(List<Conversation> conversations) {
    final sorted = [...conversations];
    sorted.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final aTime = a.lastMessage?.createdAt ?? a.updatedAt;
      final bTime = b.lastMessage?.createdAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  Future<Conversation?> createConversation(List<String> participantIds, {String? groupName}) async {
    try {
      final conversation = await _repository.createConversation(
        participantIds: participantIds,
        groupName: groupName,
      );
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data([conversation, ...currentList]);
      return conversation;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _repository.deleteConversation(conversationId);
      final currentList = state.valueOrNull ?? [];
      state = AsyncValue.data(currentList.where((c) => c.id != conversationId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleMute(String conversationId) async {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index < 0) return;

    final conversation = currentList[index];
    try {
      final updatedConv = conversation.isMuted
          ? await _repository.unmuteConversation(conversationId)
          : await _repository.muteConversation(conversationId);

      final updatedList = [...currentList];
      updatedList[index] = updatedConv;
      state = AsyncValue.data(_sortConversations(updatedList));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> togglePin(String conversationId) async {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index < 0) return;

    final conversation = currentList[index];
    try {
      final updatedConv = conversation.isPinned
          ? await _repository.unpinConversation(conversationId)
          : await _repository.pinConversation(conversationId);

      final updatedList = [...currentList];
      updatedList[index] = updatedConv;
      state = AsyncValue.data(_sortConversations(updatedList));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateLastMessage(String conversationId, Message message) {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      final updatedList = [...currentList];
      updatedList[index] = currentList[index].copyWith(
        lastMessage: message,
        updatedAt: message.createdAt,
      );
      state = AsyncValue.data(_sortConversations(updatedList));
    }
  }

  void markAsRead(String conversationId) {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      final updatedList = [...currentList];
      updatedList[index] = currentList[index].copyWith(unreadCount: 0);
      state = AsyncValue.data(updatedList);
      _repository.markConversationAsRead(conversationId);
    }
  }

  void markAsUnread(String conversationId) {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      final updatedList = [...currentList];
      updatedList[index] = currentList[index].copyWith(unreadCount: 1);
      state = AsyncValue.data(updatedList);
    }
  }

  @override
  void dispose() {
    _conversationSubscription?.cancel();
    super.dispose();
  }
}

final conversationsControllerProvider = StateNotifierProvider<ConversationsController, AsyncValue<List<Conversation>>>((ref) {
  final repository = ref.watch(messagesRepositoryProvider);
  return ConversationsController(repository);
});

class ChatController extends StateNotifier<AsyncValue<List<Message>>> {
  final MessagesRepository _repository;
  final String conversationId;
  final Ref _ref;
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<Message>? _messageUpdateSubscription;
  bool _hasMore = true;

  ChatController(this._repository, this.conversationId, this._ref) : super(const AsyncValue.loading()) {
    loadMessages();
    _listenToMessages();
  }

  void _listenToMessages() {
    _newMessageSubscription = _repository.onNewMessage().listen((message) {
      if (message.conversationId == conversationId) {
        final currentMessages = state.valueOrNull ?? [];
        final existingIndex = currentMessages.indexWhere(
          (m) => m.id == message.id || 
                 (m.status == MessageStatus.sending && 
                  m.content == message.content &&
                  m.senderId == message.senderId)
        );
        if (existingIndex >= 0) {
          final updatedMessages = [...currentMessages];
          updatedMessages[existingIndex] = message;
          state = AsyncValue.data(updatedMessages);
        } else {
          state = AsyncValue.data([...currentMessages, message]);
        }
      }
    });

    _messageUpdateSubscription = _repository.onMessageUpdated().listen((message) {
      if (message.conversationId == conversationId) {
        final currentMessages = state.valueOrNull ?? [];
        final index = currentMessages.indexWhere((m) => m.id == message.id);
        if (index >= 0) {
          final updatedMessages = [...currentMessages];
          updatedMessages[index] = message;
          state = AsyncValue.data(updatedMessages);
        }
      }
    });
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _repository.getMessages(conversationId);
      _hasMore = messages.length >= 50;
      state = AsyncValue.data(messages);
      await _repository.markConversationAsRead(conversationId);
      _ref.read(conversationsControllerProvider.notifier).markAsRead(conversationId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.isEmpty) return;

    try {
      final olderMessages = await _repository.getMessages(
        conversationId,
        beforeMessageId: currentMessages.first.id,
      );
      _hasMore = olderMessages.length >= 50;
      state = AsyncValue.data([...olderMessages, ...currentMessages]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text, List<String>? mediaUrls, String? replyToMessageId, Message? replyToMessage}) async {
    final contentValidation = Validators.combine([
      Validators.required(content, fieldName: 'الرسالة'),
      Validators.maxLength(content, 5000, fieldName: 'الرسالة'),
    ]);

    if (!contentValidation.isValid) {
      state = AsyncValue.error(
        Exception(contentValidation.errorMessage),
        StackTrace.current,
      );
      return;
    }

    final tempId = const Uuid().v4();
    final optimisticMessage = Message(
      id: tempId,
      conversationId: conversationId,
      senderId: 'currentUser',
      senderName: 'أنت',
      content: content.trim(),
      type: type,
      mediaUrls: mediaUrls ?? [],
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      replyToMessageId: replyToMessageId,
      replyToMessage: replyToMessage,
    );

    final currentMessages = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentMessages, optimisticMessage]);

    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        content: content.trim(),
        type: type,
        mediaUrls: mediaUrls,
        replyToMessageId: replyToMessageId,
      );

      final sentMessage = Message(
        id: tempId,
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: content.trim(),
        type: type,
        mediaUrls: mediaUrls ?? [],
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
        replyToMessageId: replyToMessageId,
      );
      
      _ref.read(conversationsControllerProvider.notifier).updateLastMessage(conversationId, sentMessage);

      final conversation = await _repository.getConversationById(conversationId);
      final currentUserId = _ref.read(currentUserIdProvider);
      final currentUserProfile = _ref.read(profileControllerProvider).valueOrNull;
      final notificationsRepo = _ref.read(notificationsRepositoryProvider);
      final notificationService = NotificationService(notificationsRepo);

      for (final participant in conversation.participants) {
        if (participant.id != currentUserId) {
          await notificationService.createMessageNotification(
            actorUserId: currentUserId,
            actorDisplayName: currentUserProfile?.displayName ?? 'Someone',
            actorAvatarUrl: currentUserProfile?.avatarUrl,
            targetUserId: participant.id,
            conversationId: conversationId,
            messagePreview: content.trim().length > 50 ? '${content.trim().substring(0, 50)}...' : content.trim(),
          );
        }
      }
    } catch (_) {
      final revertMessages = state.valueOrNull ?? [];
      final failedMessage = optimisticMessage.copyWith(status: MessageStatus.failed);
      final index = revertMessages.indexWhere((m) => m.id == tempId);
      if (index >= 0) {
        final updatedMessages = [...revertMessages];
        updatedMessages[index] = failedMessage;
        state = AsyncValue.data(updatedMessages);
      }
    }
  }

  Future<void> sendForwardedMessage({
    required String content,
    required MessageType type,
    required String forwardedFromMessageId,
    List<String>? mediaUrls,
  }) async {
    final tempId = const Uuid().v4();
    final optimisticMessage = Message(
      id: tempId,
      conversationId: conversationId,
      senderId: 'currentUser',
      senderName: 'أنت',
      content: content,
      type: type,
      mediaUrls: mediaUrls ?? [],
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      isForwarded: true,
      forwardedFromMessageId: forwardedFromMessageId,
    );

    final currentMessages = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentMessages, optimisticMessage]);

    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        mediaUrls: mediaUrls,
      );

      final sentMessage = Message(
        id: tempId,
        conversationId: conversationId,
        senderId: 'currentUser',
        senderName: 'You',
        content: content,
        type: type,
        mediaUrls: mediaUrls ?? [],
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
        isForwarded: true,
        forwardedFromMessageId: forwardedFromMessageId,
      );

      _ref.read(conversationsControllerProvider.notifier).updateLastMessage(conversationId, sentMessage);
    } catch (_) {
      final revertMessages = state.valueOrNull ?? [];
      final failedMessage = optimisticMessage.copyWith(status: MessageStatus.failed);
      final index = revertMessages.indexWhere((m) => m.id == tempId);
      if (index >= 0) {
        final updatedMessages = [...revertMessages];
        updatedMessages[index] = failedMessage;
        state = AsyncValue.data(updatedMessages);
      }
    }
  }

  void editMessage(String messageId, String newContent) {
    final currentMessages = state.valueOrNull ?? [];
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index >= 0) {
      final updatedMessages = [...currentMessages];
      updatedMessages[index] = currentMessages[index].copyWith(
        content: newContent,
        isEdited: true,
      );
      state = AsyncValue.data(updatedMessages);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final currentMessages = state.valueOrNull ?? [];
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    
    final deletedMessage = currentMessages[index];
    
    state = AsyncValue.data(
      currentMessages.where((m) => m.id != messageId).toList(),
    );

    try {
      await _repository.deleteMessage(conversationId, messageId);
    } catch (_) {
      final revertMessages = state.valueOrNull ?? [];
      final insertIndex = index.clamp(0, revertMessages.length);
      final updatedMessages = [...revertMessages];
      updatedMessages.insert(insertIndex, deletedMessage);
      state = AsyncValue.data(updatedMessages);
    }
  }

  Future<void> deleteMultipleMessages(List<String> messageIds) async {
    if (messageIds.isEmpty) return;
    
    final currentMessages = state.valueOrNull ?? [];
    final deletedMessages = <int, Message>{};
    
    for (var i = 0; i < currentMessages.length; i++) {
      if (messageIds.contains(currentMessages[i].id)) {
        deletedMessages[i] = currentMessages[i];
      }
    }
    
    state = AsyncValue.data(
      currentMessages.where((m) => !messageIds.contains(m.id)).toList(),
    );

    try {
      await _repository.deleteMultipleMessages(conversationId, messageIds);
    } catch (_) {
      final revertMessages = List<Message>.from(state.valueOrNull ?? []);
      for (final entry in deletedMessages.entries) {
        final insertIndex = entry.key.clamp(0, revertMessages.length);
        revertMessages.insert(insertIndex, entry.value);
      }
      state = AsyncValue.data(revertMessages);
    }
  }

  Future<void> clearChat() async {
    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.isEmpty) return;
    
    state = const AsyncValue.data([]);

    try {
      await _repository.clearConversationForMe(conversationId);
    } catch (_) {
      state = AsyncValue.data(currentMessages);
    }
  }

  void startTyping() {
    _repository.startTyping(conversationId);
  }

  void stopTyping() {
    _repository.stopTyping(conversationId);
  }

  @override
  void dispose() {
    _newMessageSubscription?.cancel();
    _messageUpdateSubscription?.cancel();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, AsyncValue<List<Message>>, String>((ref, conversationId) {
  final repository = ref.watch(messagesRepositoryProvider);
  return ChatController(repository, conversationId, ref);
});

final searchConversationsProvider = FutureProvider.family<List<Conversation>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(conversationsProvider).valueOrNull ?? [];
  }
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.searchConversations(query);
});
