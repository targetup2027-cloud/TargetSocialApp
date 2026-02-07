import '../../../../core/network/network_client.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

abstract class MessagesRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> getConversationById(String conversationId);
  Future<ConversationModel> createConversation({
    required List<String> participantIds,
    String? title,
  });
  Future<void> deleteConversation(String conversationId);
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type,
    String? mediaUrl,
  });
  Future<void> updateMessage(String messageId, String content);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessageAsRead(String messageId);
}

class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  final NetworkClient _client;

  MessagesRemoteDataSourceImpl({required NetworkClient client}) : _client = client;

  @override
  Future<List<ConversationModel>> getConversations() async {
    final response = await _client.get('/api/Conversations');
    final List<dynamic> data = response['data'] ?? response;
    return data
        .map((json) => _parseConversation(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ConversationModel> getConversationById(String conversationId) async {
    final response = await _client.get('/api/Conversations/$conversationId');
    final data = response['data'] ?? response;
    return _parseConversation(data as Map<String, dynamic>);
  }

  @override
  Future<ConversationModel> createConversation({
    required List<String> participantIds,
    String? title,
  }) async {
    final response = await _client.post('/api/Conversations', data: {
      'participantIds': participantIds.map((id) => int.tryParse(id) ?? 0).toList(),
      if (title != null) 'title': title,
    });
    final data = response['data'] ?? response;
    return _parseConversation(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _client.delete('/api/Conversations/$conversationId');
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await _client.get('/api/Conversations/$conversationId/messages');
    final List<dynamic> data = response['data'] ?? response;
    return data
        .map((json) => _parseMessage(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final response = await _client.post('/api/Conversations/$conversationId/messages', data: {
      'content': content,
      'type': type.index,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
    final data = response['data'] ?? response;
    return _parseMessage(data as Map<String, dynamic>);
  }

  @override
  Future<void> updateMessage(String messageId, String content) async {
    await _client.put('/api/Messages/$messageId', data: {
      'content': content,
    });
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _client.delete('/api/Messages/$messageId');
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _client.put('/api/Messages/$messageId/read');
  }

  ConversationModel _parseConversation(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>? ?? [])
        .map((p) {
      final pJson = p as Map<String, dynamic>;
      final firstName = pJson['firstName'] as String? ?? '';
      final lastName = pJson['lastName'] as String? ?? '';
      final displayName = pJson['displayName'] as String? ??
          '$firstName $lastName'.trim();
      final username = pJson['username'] as String? ??
          pJson['email'] as String? ??
          displayName.toLowerCase().replaceAll(' ', '_');

      return ConversationParticipantModel(
        id: pJson['id'].toString(),
        username: username,
        displayName: displayName,
        avatarUrl: pJson['avatarUrl'] as String?,
        isVerified: pJson['isVerified'] as bool? ?? false,
      );
    }).toList();

    MessageModel? lastMessage;
    if (json['lastMessage'] != null) {
      lastMessage = _parseMessage(json['lastMessage'] as Map<String, dynamic>);
    }

    return ConversationModel(
      id: json['id'].toString(),
      participants: participants,
      lastMessage: lastMessage,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isGroup: json['isGroup'] as bool? ?? false,
      groupName: json['title'] as String? ?? json['groupName'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  MessageModel _parseMessage(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      senderName: json['senderName'] as String? ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      content: json['content'] as String?,
      type: _parseMessageType(json['type']),
      status: (json['isRead'] as bool? ?? false)
          ? MessageStatus.read
          : MessageStatus.delivered,
      createdAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'] as String) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  MessageType _parseMessageType(dynamic type) {
    if (type is int) {
      return MessageType.values.elementAtOrNull(type) ?? MessageType.text;
    }
    return MessageType.text;
  }
}
