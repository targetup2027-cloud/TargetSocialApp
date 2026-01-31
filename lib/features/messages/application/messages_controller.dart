import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/message.dart';
import '../domain/repositories/messages_repository.dart';
import '../data/repositories/messages_repository_impl.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(useMockData: true);
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
        state = AsyncValue.data(updatedList);
      }
    });
  }

  Future<void> loadConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
    } catch (e) {
      
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
      state = AsyncValue.data(updatedList);
    } catch (e) {
      
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
      state = AsyncValue.data(updatedList);
    } catch (e) {
      
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
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<Message>? _messageUpdateSubscription;
  bool _hasMore = true;

  ChatController(this._repository, this.conversationId) : super(const AsyncValue.loading()) {
    loadMessages();
    _listenToMessages();
  }

  void _listenToMessages() {
    _newMessageSubscription = _repository.onNewMessage().listen((message) {
      if (message.conversationId == conversationId) {
        final currentMessages = state.valueOrNull ?? [];
        state = AsyncValue.data([...currentMessages, message]);
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
    } catch (e) {
      
    }
  }

  Future<void> sendMessage(String content, {MessageType type = MessageType.text, List<String>? mediaUrls, String? replyToMessageId}) async {
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        mediaUrls: mediaUrls,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _repository.deleteMessage(conversationId, messageId);
      final currentMessages = state.valueOrNull ?? [];
      state = AsyncValue.data(currentMessages.where((m) => m.id != messageId).toList());
    } catch (e) {
      
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
  return ChatController(repository, conversationId);
});

final searchConversationsProvider = FutureProvider.family<List<Conversation>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(conversationsProvider).valueOrNull ?? [];
  }
  final repository = ref.watch(messagesRepositoryProvider);
  return repository.searchConversations(query);
});
