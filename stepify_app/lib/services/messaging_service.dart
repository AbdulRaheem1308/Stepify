import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/messaging/domain/models/messaging_models.dart';
import 'api_service.dart';

/// Service for real-time messaging endpoints.
class MessagingService {
  final ApiService _api;

  const MessagingService(this._api);

  /// Returns all conversations visible to the current user.
  ///
  /// The user identity is inferred from the JWT on the backend; no
  /// `userId` parameter is required here.
  ///
  /// Returns an empty list on failure rather than throwing, so the UI
  /// degrades gracefully.
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _api.get('/messaging/conversations');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              Conversation.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      debugPrint('MessagingService: Error fetching conversations: $e');
      return [];
    }
  }

  /// Returns the messages for [conversationId].
  ///
  /// Throws [ApiError] on failure.
  Future<List<Message>> getMessages(String conversationId) async {
    assert(conversationId.isNotEmpty, 'conversationId must not be empty');
    try {
      final response = await _api
          .get('/messaging/conversations/$conversationId/messages');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              Message.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      throw ApiError.from(e);
    }
  }

  /// Sends a message to [conversationId] with the given [content].
  ///
  /// The sender identity is derived from the JWT on the backend — do not
  /// pass a senderId from the client to avoid spoofing.
  ///
  /// Throws [ApiError] on failure.
  Future<Message> sendMessage(String conversationId, String content) async {
    assert(conversationId.isNotEmpty, 'conversationId must not be empty');
    assert(content.isNotEmpty, 'content must not be empty');
    try {
      final response = await _api.post('/messaging/messages', data: {
        'conversationId': conversationId,
        'content': content,
      });
      return Message.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (e) {
      throw ApiError.from(e);
    }
  }
}

/// Riverpod provider for [MessagingService].
final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(ref.read(apiServiceProvider));
});
