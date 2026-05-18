import 'package:dio/dio.dart';
import '../features/messaging/domain/models/messaging_models.dart';
import 'api_service.dart';

class MessagingService {
  final ApiService _api;

  MessagingService(this._api);

  Future<List<Conversation>> getConversations(String userId) async {
    try {
      final response = await _api.get('/messaging/conversations/$userId');
      // Ensure we cast the list properly or the map returns Iterable<dynamic>
      final List data = response.data;
      return data.map((json) => Conversation.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final response = await _api.get('/messaging/conversations/$conversationId/messages');
    final List data = response.data;
    return data.map((json) => Message.fromJson(json)).toList();
  }

  Future<Message> sendMessage(String conversationId, String senderId, String content) async {
    final response = await _api.post('/messaging/messages', data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
    });
    return Message.fromJson(response.data);
  }
}
