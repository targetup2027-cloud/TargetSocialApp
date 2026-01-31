import '../entities/ai_agent.dart';

abstract class AIRepository {
  Future<List<AIAgent>> getAgents({
    int page = 1,
    int limit = 20,
    AIAgentCategory? category,
    String? query,
  });
  
  Future<AIAgent> getAgentById(String agentId);
  
  Future<List<AIAgent>> getFeaturedAgents();
  
  Future<List<AIAgent>> getPopularAgents();
  
  Future<List<AIAgent>> getRecentlyUsedAgents();
  
  Future<List<UserSubscription>> getMySubscriptions();
  
  Future<UserSubscription> subscribe(String agentId, String planId);
  
  Future<void> cancelSubscription(String subscriptionId);
  
  Future<List<AIChat>> getChats({int page = 1, int limit = 20});
  
  Future<AIChat> getChatById(String chatId);
  
  Future<AIChat> createChat(String agentId);
  
  Future<void> deleteChat(String chatId);
  
  Future<AIChatMessage> sendMessage(String chatId, String content, {List<String>? attachmentUrls});
  
  Stream<String> streamResponse(String chatId, String messageId);
  
  Future<void> stopGeneration(String chatId);
  
  Future<void> regenerateResponse(String chatId, String messageId);
  
  Future<void> rateResponse(String messageId, bool isPositive);
  
  Future<List<String>> getSuggestedPrompts(String agentId);
}
