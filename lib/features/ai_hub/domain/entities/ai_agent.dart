class AIAgent {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final AIAgentCategory category;
  final List<String> capabilities;
  final double rating;
  final int usersCount;
  final int responseTimeMs;
  final double accuracyPercent;
  final bool isPremium;
  final double? pricePerMonth;
  final List<SubscriptionPlan> plans;
  final bool isActive;
  final DateTime createdAt;

  const AIAgent({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.category,
    this.capabilities = const [],
    this.rating = 0.0,
    this.usersCount = 0,
    this.responseTimeMs = 0,
    this.accuracyPercent = 0.0,
    this.isPremium = false,
    this.pricePerMonth,
    this.plans = const [],
    this.isActive = true,
    required this.createdAt,
  });

  AIAgent copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    AIAgentCategory? category,
    List<String>? capabilities,
    double? rating,
    int? usersCount,
    int? responseTimeMs,
    double? accuracyPercent,
    bool? isPremium,
    double? pricePerMonth,
    List<SubscriptionPlan>? plans,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AIAgent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      capabilities: capabilities ?? this.capabilities,
      rating: rating ?? this.rating,
      usersCount: usersCount ?? this.usersCount,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      accuracyPercent: accuracyPercent ?? this.accuracyPercent,
      isPremium: isPremium ?? this.isPremium,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      plans: plans ?? this.plans,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum AIAgentCategory {
  assistant,
  creative,
  business,
  education,
  health,
  entertainment,
  productivity,
  custom,
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double pricePerMonth;
  final double? pricePerYear;
  final List<String> features;
  final int? messagesLimit;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerMonth,
    this.pricePerYear,
    this.features = const [],
    this.messagesLimit,
    this.isPopular = false,
  });
}

class AIChat {
  final String id;
  final String agentId;
  final String agentName;
  final String? agentIconUrl;
  final List<AIChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIChat({
    required this.id,
    required this.agentId,
    required this.agentName,
    this.agentIconUrl,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  AIChat copyWith({
    String? id,
    String? agentId,
    String? agentName,
    String? agentIconUrl,
    List<AIChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIChat(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentIconUrl: agentIconUrl ?? this.agentIconUrl,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AIChatMessage {
  final String id;
  final String chatId;
  final bool isUser;
  final String content;
  final List<String>? attachmentUrls;
  final MessageStatus status;
  final DateTime createdAt;

  const AIChatMessage({
    required this.id,
    required this.chatId,
    required this.isUser,
    required this.content,
    this.attachmentUrls,
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  AIChatMessage copyWith({
    String? id,
    String? chatId,
    bool? isUser,
    String? content,
    List<String>? attachmentUrls,
    MessageStatus? status,
    DateTime? createdAt,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      isUser: isUser ?? this.isUser,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  error,
}

class UserSubscription {
  final String id;
  final String agentId;
  final String planId;
  final String planName;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int messagesUsed;
  final int? messagesLimit;

  const UserSubscription({
    required this.id,
    required this.agentId,
    required this.planId,
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.messagesUsed = 0,
    this.messagesLimit,
  });
}
