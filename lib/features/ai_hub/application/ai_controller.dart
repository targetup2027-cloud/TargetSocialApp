import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ai_agent.dart';
import '../domain/repositories/ai_repository.dart';
import '../data/repositories/ai_repository_impl.dart';

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepositoryImpl(useMockData: true);
});

final aiAgentsProvider = FutureProvider.family<List<AIAgent>, AIAgentSearchParams>((ref, params) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getAgents(
    page: params.page,
    category: params.category,
    query: params.query,
  );
});

final aiAgentByIdProvider = FutureProvider.family<AIAgent, String>((ref, id) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getAgentById(id);
});

final featuredAgentsProvider = FutureProvider<List<AIAgent>>((ref) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getFeaturedAgents();
});

final popularAgentsProvider = FutureProvider<List<AIAgent>>((ref) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getPopularAgents();
});

final recentlyUsedAgentsProvider = FutureProvider<List<AIAgent>>((ref) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getRecentlyUsedAgents();
});

final mySubscriptionsProvider = FutureProvider<List<UserSubscription>>((ref) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getMySubscriptions();
});

final aiChatsProvider = FutureProvider<List<AIChat>>((ref) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getChats();
});

final aiChatByIdProvider = FutureProvider.family<AIChat, String>((ref, id) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getChatById(id);
});

final suggestedPromptsProvider = FutureProvider.family<List<String>, String>((ref, agentId) async {
  final repository = ref.watch(aiRepositoryProvider);
  return repository.getSuggestedPrompts(agentId);
});

class AIAgentSearchParams {
  final int page;
  final AIAgentCategory? category;
  final String? query;

  const AIAgentSearchParams({
    this.page = 1,
    this.category,
    this.query,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIAgentSearchParams &&
          page == other.page &&
          category == other.category &&
          query == other.query;

  @override
  int get hashCode => Object.hash(page, category, query);
}

class AIChatController extends StateNotifier<AsyncValue<AIChat>> {
  final AIRepository _repository;
  final String chatId;
  StreamSubscription<String>? _responseSubscription;
  bool _isGenerating = false;

  AIChatController(this._repository, this.chatId) : super(const AsyncValue.loading()) {
    loadChat();
  }

  bool get isGenerating => _isGenerating;

  Future<void> loadChat() async {
    state = const AsyncValue.loading();
    try {
      final chat = await _repository.getChatById(chatId);
      state = AsyncValue.data(chat);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String content, {List<String>? attachmentUrls}) async {
    final currentChat = state.valueOrNull;
    if (currentChat == null) return;

    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      isUser: true,
      content: content,
      attachmentUrls: attachmentUrls,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data(currentChat.copyWith(
      messages: [...currentChat.messages, userMessage],
      updatedAt: DateTime.now(),
    ));

    _isGenerating = true;

    try {
      final aiResponse = await _repository.sendMessage(chatId, content, attachmentUrls: attachmentUrls);
      
      final updatedChat = state.valueOrNull;
      if (updatedChat != null) {
        state = AsyncValue.data(updatedChat.copyWith(
          messages: [...updatedChat.messages, aiResponse],
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isGenerating = false;
    }
  }

  Future<void> streamMessage(String content) async {
    final currentChat = state.valueOrNull;
    if (currentChat == null) return;

    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      isUser: true,
      content: content,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );

    final aiMessageId = (DateTime.now().millisecondsSinceEpoch + 1).toString();
    final pendingAiMessage = AIChatMessage(
      id: aiMessageId,
      chatId: chatId,
      isUser: false,
      content: '',
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );

    state = AsyncValue.data(currentChat.copyWith(
      messages: [...currentChat.messages, userMessage, pendingAiMessage],
      updatedAt: DateTime.now(),
    ));

    _isGenerating = true;
    var streamedContent = '';

    _responseSubscription = _repository.streamResponse(chatId, aiMessageId).listen(
      (chunk) {
        streamedContent += chunk;
        _updateAiMessage(aiMessageId, streamedContent, MessageStatus.sending);
      },
      onDone: () {
        _updateAiMessage(aiMessageId, streamedContent, MessageStatus.sent);
        _isGenerating = false;
      },
      onError: (error) {
        _updateAiMessage(aiMessageId, streamedContent, MessageStatus.error);
        _isGenerating = false;
      },
    );
  }

  void _updateAiMessage(String messageId, String content, MessageStatus status) {
    final currentChat = state.valueOrNull;
    if (currentChat == null) return;

    final updatedMessages = currentChat.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(content: content, status: status);
      }
      return m;
    }).toList();

    state = AsyncValue.data(currentChat.copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> stopGeneration() async {
    _responseSubscription?.cancel();
    _isGenerating = false;
    await _repository.stopGeneration(chatId);
  }

  Future<void> regenerateResponse(String messageId) async {
    _isGenerating = true;
    try {
      await _repository.regenerateResponse(chatId, messageId);
    } finally {
      _isGenerating = false;
    }
  }

  Future<void> rateResponse(String messageId, bool isPositive) async {
    await _repository.rateResponse(messageId, isPositive);
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    super.dispose();
  }
}

final aiChatControllerProvider = StateNotifierProvider.family<AIChatController, AsyncValue<AIChat>, String>((ref, chatId) {
  final repository = ref.watch(aiRepositoryProvider);
  return AIChatController(repository, chatId);
});

class AIChatListController extends StateNotifier<AsyncValue<List<AIChat>>> {
  final AIRepository _repository;

  AIChatListController(this._repository) : super(const AsyncValue.loading()) {
    loadChats();
  }

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    try {
      final chats = await _repository.getChats();
      state = AsyncValue.data(chats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AIChat?> createChat(String agentId) async {
    try {
      final newChat = await _repository.createChat(agentId);
      final currentChats = state.valueOrNull ?? [];
      state = AsyncValue.data([newChat, ...currentChats]);
      return newChat;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _repository.deleteChat(chatId);
      final currentChats = state.valueOrNull ?? [];
      state = AsyncValue.data(currentChats.where((c) => c.id != chatId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final aiChatListControllerProvider = StateNotifierProvider<AIChatListController, AsyncValue<List<AIChat>>>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AIChatListController(repository);
});

class SubscriptionController extends StateNotifier<AsyncValue<List<UserSubscription>>> {
  final AIRepository _repository;

  SubscriptionController(this._repository) : super(const AsyncValue.loading()) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    state = const AsyncValue.loading();
    try {
      final subscriptions = await _repository.getMySubscriptions();
      state = AsyncValue.data(subscriptions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserSubscription?> subscribe(String agentId, String planId) async {
    try {
      final subscription = await _repository.subscribe(agentId, planId);
      final currentSubs = state.valueOrNull ?? [];
      state = AsyncValue.data([...currentSubs, subscription]);
      return subscription;
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _repository.cancelSubscription(subscriptionId);
      final currentSubs = state.valueOrNull ?? [];
      state = AsyncValue.data(currentSubs.where((s) => s.id != subscriptionId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final subscriptionControllerProvider = StateNotifierProvider<SubscriptionController, AsyncValue<List<UserSubscription>>>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return SubscriptionController(repository);
});
