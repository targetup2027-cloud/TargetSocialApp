import 'dart:async';
import '../../domain/entities/ai_agent.dart';
import '../../domain/repositories/ai_repository.dart';

class AIRepositoryImpl implements AIRepository {
  final bool useMockData;

  AIRepositoryImpl({this.useMockData = true});

  @override
  Future<List<AIAgent>> getAgents({
    int page = 1,
    int limit = 20,
    AIAgentCategory? category,
    String? query,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var agents = _getMockAgents();
      
      if (category != null) {
        agents = agents.where((a) => a.category == category).toList();
      }
      
      if (query != null && query.isNotEmpty) {
        agents = agents.where((a) =>
          a.name.toLowerCase().contains(query.toLowerCase()) ||
          a.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      
      return agents;
    }
    throw UnimplementedError();
  }

  @override
  Future<AIAgent> getAgentById(String agentId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _getMockAgents().firstWhere((a) => a.id == agentId);
    }
    throw UnimplementedError();
  }

  @override
  Future<List<AIAgent>> getFeaturedAgents() async {
    if (useMockData) {
      return _getMockAgents().take(3).toList();
    }
    throw UnimplementedError();
  }

  @override
  Future<List<AIAgent>> getPopularAgents() async {
    if (useMockData) {
      final agents = _getMockAgents();
      agents.sort((a, b) => b.usersCount.compareTo(a.usersCount));
      return agents.take(5).toList();
    }
    throw UnimplementedError();
  }

  @override
  Future<List<AIAgent>> getRecentlyUsedAgents() async {
    if (useMockData) {
      return _getMockAgents().take(3).toList();
    }
    throw UnimplementedError();
  }

  @override
  Future<List<UserSubscription>> getMySubscriptions() async {
    if (useMockData) {
      return [
        UserSubscription(
          id: 'sub1',
          agentId: 'agent1',
          planId: 'plan_pro',
          planName: 'Pro',
          price: 9.99,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          messagesUsed: 150,
          messagesLimit: 500,
        ),
      ];
    }
    throw UnimplementedError();
  }

  @override
  Future<UserSubscription> subscribe(String agentId, String planId) async {
    if (useMockData) {
      return UserSubscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        agentId: agentId,
        planId: planId,
        planName: 'Pro',
        price: 9.99,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<List<AIChat>> getChats({int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockChats();
    }
    throw UnimplementedError();
  }

  @override
  Future<AIChat> getChatById(String chatId) async {
    if (useMockData) {
      return _getMockChats().firstWhere((c) => c.id == chatId);
    }
    throw UnimplementedError();
  }

  @override
  Future<AIChat> createChat(String agentId) async {
    if (useMockData) {
      final agent = await getAgentById(agentId);
      return AIChat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        agentId: agentId,
        agentName: agent.name,
        agentIconUrl: agent.iconUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChat(String chatId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<AIChatMessage> sendMessage(String chatId, String content, {List<String>? attachmentUrls}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        isUser: false,
        content: _generateMockResponse(content),
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
      );
    }
    throw UnimplementedError();
  }

  @override
  Stream<String> streamResponse(String chatId, String messageId) async* {
    if (useMockData) {
      const response = 'This is a simulated streaming response from the AI. Each word appears one at a time to simulate real-time generation.';
      final words = response.split(' ');
      
      for (final word in words) {
        await Future.delayed(const Duration(milliseconds: 100));
        yield '$word ';
      }
    }
  }

  @override
  Future<void> stopGeneration(String chatId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> regenerateResponse(String chatId, String messageId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> rateResponse(String messageId, bool isPositive) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getSuggestedPrompts(String agentId) async {
    if (useMockData) {
      return [
        'Help me write a professional email',
        'Explain quantum computing in simple terms',
        'Create a workout plan for beginners',
        'Suggest ideas for a birthday party',
        'Help me debug my code',
      ];
    }
    throw UnimplementedError();
  }

  String _generateMockResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    
    if (lowercaseMessage.contains('hello') || lowercaseMessage.contains('hi')) {
      return 'Hello! How can I assist you today? I\'m here to help with any questions or tasks you might have.';
    }
    
    if (lowercaseMessage.contains('help')) {
      return 'I\'d be happy to help! I can assist you with:\n\n'
          '• Writing and editing text\n'
          '• Answering questions\n'
          '• Brainstorming ideas\n'
          '• Explaining complex topics\n'
          '• And much more!\n\n'
          'What would you like to work on?';
    }
    
    if (lowercaseMessage.contains('code') || lowercaseMessage.contains('programming')) {
      return 'I can help with programming and coding tasks! Whether you need help with:\n\n'
          '• Debugging code\n'
          '• Writing new functions\n'
          '• Explaining programming concepts\n'
          '• Code review and optimization\n\n'
          'Just share your code or describe what you\'re trying to accomplish.';
    }
    
    return 'That\'s an interesting question! Based on what you\'ve shared, here are my thoughts:\n\n'
        'Your message touches on an important topic. I\'d be happy to explore this further with you. '
        'Could you provide more context or let me know what specific aspect you\'d like me to focus on?\n\n'
        'Feel free to ask follow-up questions!';
  }

  List<AIAgent> _getMockAgents() {
    return [
      AIAgent(
        id: 'agent1',
        name: 'Nova Assistant',
        description: 'Your all-purpose AI assistant for everyday tasks. Get help with writing, research, planning, and more.',
        iconUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=200',
        category: AIAgentCategory.assistant,
        capabilities: ['Writing', 'Research', 'Planning', 'Q&A', 'Summarization'],
        rating: 4.8,
        usersCount: 125000,
        responseTimeMs: 800,
        accuracyPercent: 95.5,
        isPremium: false,
        plans: [
          const SubscriptionPlan(
            id: 'plan_free',
            name: 'Free',
            description: 'Basic access with limited messages',
            pricePerMonth: 0,
            features: ['50 messages/day', 'Basic features'],
            messagesLimit: 50,
          ),
          const SubscriptionPlan(
            id: 'plan_pro',
            name: 'Pro',
            description: 'Unlimited access with premium features',
            pricePerMonth: 9.99,
            pricePerYear: 99.99,
            features: ['500 messages/day', 'Priority response', 'Advanced features', 'API access'],
            messagesLimit: 500,
            isPopular: true,
          ),
        ],
        createdAt: DateTime(2024, 1, 1),
      ),
      AIAgent(
        id: 'agent2',
        name: 'Creative Studio',
        description: 'Unleash your creativity with AI-powered content generation. Create stories, poems, scripts, and more.',
        iconUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200',
        category: AIAgentCategory.creative,
        capabilities: ['Story Writing', 'Poetry', 'Scripts', 'Song Lyrics', 'Creative Ideas'],
        rating: 4.6,
        usersCount: 85000,
        responseTimeMs: 1200,
        accuracyPercent: 92.0,
        isPremium: true,
        pricePerMonth: 14.99,
        plans: [
          const SubscriptionPlan(
            id: 'plan_starter',
            name: 'Starter',
            description: 'Perfect for hobbyists',
            pricePerMonth: 4.99,
            features: ['100 creations/month', 'Basic templates'],
            messagesLimit: 100,
          ),
          const SubscriptionPlan(
            id: 'plan_creator',
            name: 'Creator',
            description: 'For serious creators',
            pricePerMonth: 14.99,
            pricePerYear: 149.99,
            features: ['Unlimited creations', 'Premium templates', 'Style customization'],
            isPopular: true,
          ),
        ],
        createdAt: DateTime(2024, 2, 15),
      ),
      AIAgent(
        id: 'agent3',
        name: 'Business Advisor',
        description: 'Get strategic business insights and advice. From marketing to operations, we\'ve got you covered.',
        iconUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=200',
        category: AIAgentCategory.business,
        capabilities: ['Strategy', 'Marketing', 'Finance', 'Operations', 'HR'],
        rating: 4.7,
        usersCount: 62000,
        responseTimeMs: 1000,
        accuracyPercent: 93.5,
        isPremium: true,
        pricePerMonth: 29.99,
        createdAt: DateTime(2024, 1, 20),
      ),
      AIAgent(
        id: 'agent4',
        name: 'Code Companion',
        description: 'Your AI pair programmer. Debug, review, and improve your code across multiple languages.',
        iconUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=200',
        category: AIAgentCategory.productivity,
        capabilities: ['Code Review', 'Debugging', 'Optimization', 'Documentation', 'Testing'],
        rating: 4.9,
        usersCount: 98000,
        responseTimeMs: 600,
        accuracyPercent: 96.8,
        isPremium: true,
        pricePerMonth: 19.99,
        createdAt: DateTime(2024, 3, 1),
      ),
      AIAgent(
        id: 'agent5',
        name: 'Study Buddy',
        description: 'Learn anything with personalized tutoring. From math to history, get explanations tailored to you.',
        iconUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=200',
        category: AIAgentCategory.education,
        capabilities: ['Tutoring', 'Explanations', 'Practice Problems', 'Study Plans', 'Quiz Generation'],
        rating: 4.7,
        usersCount: 110000,
        responseTimeMs: 900,
        accuracyPercent: 94.0,
        isPremium: false,
        createdAt: DateTime(2024, 2, 1),
      ),
    ];
  }

  List<AIChat> _getMockChats() {
    return [
      AIChat(
        id: 'chat1',
        agentId: 'agent1',
        agentName: 'Nova Assistant',
        agentIconUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=200',
        messages: [
          AIChatMessage(
            id: 'msg1',
            chatId: 'chat1',
            isUser: true,
            content: 'Hello! Can you help me write an email?',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          AIChatMessage(
            id: 'msg2',
            chatId: 'chat1',
            isUser: false,
            content: 'Of course! I\'d be happy to help you write an email. Could you tell me:\n\n1. Who is the recipient?\n2. What is the purpose of the email?\n3. What tone would you like (formal, casual, etc.)?',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AIChat(
        id: 'chat2',
        agentId: 'agent4',
        agentName: 'Code Companion',
        agentIconUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=200',
        messages: [
          AIChatMessage(
            id: 'msg3',
            chatId: 'chat2',
            isUser: true,
            content: 'I need help debugging a Flutter widget',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
