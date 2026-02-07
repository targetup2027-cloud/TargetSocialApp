import '../entities/message.dart';

abstract class MessagesRepository {
  Future<List<Conversation>> getConversations({int page = 1, int limit = 20});
  
  Future<Conversation> getConversationById(String conversationId);
  
  Future<Conversation> createConversation({
    required List<String> participantIds,
    String? groupName,
    String? groupImageUrl,
  });
  
  Future<void> deleteConversation(String conversationId);
  
  Future<List<Message>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
  });
  
  Future<Message> sendMessage({
    required String conversationId,
    String? content,
    MessageType type = MessageType.text,
    List<String>? mediaUrls,
    String? replyToMessageId,
  });
  
  Future<void> deleteMessage(String conversationId, String messageId);
  
  Future<void> deleteMultipleMessages(String conversationId, List<String> messageIds);
  
  Future<void> clearConversationForMe(String conversationId);
  
  Future<void> markAsRead(String conversationId, String messageId);
  
  Future<void> markConversationAsRead(String conversationId);
  
  Future<Message> addReaction(String messageId, String emoji);
  
  Future<void> removeReaction(String messageId, String emoji);
  
  Future<Conversation> muteConversation(String conversationId, {Duration? duration});
  
  Future<Conversation> unmuteConversation(String conversationId);
  
  Future<Conversation> pinConversation(String conversationId);
  
  Future<Conversation> unpinConversation(String conversationId);
  
  Future<List<Conversation>> searchConversations(String query);
  
  Future<List<Message>> searchMessages(String conversationId, String query);
  
  Stream<Message> onNewMessage();
  
  Stream<Message> onMessageUpdated();
  
  Stream<Conversation> onConversationUpdated();
  
  Future<void> startTyping(String conversationId);
  
  Future<void> stopTyping(String conversationId);
  
  Stream<TypingIndicator> onTypingIndicator(String conversationId);
}

class TypingIndicator {
  final String conversationId;
  final String userId;
  final String userName;
  final bool isTyping;
  final DateTime timestamp;

  const TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isTyping,
    required this.timestamp,
  });
}
