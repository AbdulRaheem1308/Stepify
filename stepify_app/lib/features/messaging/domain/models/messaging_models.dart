import 'package:stepify_app/features/auth/domain/models/user_model.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['createdAt']),
      isRead: false,
    );
  }
}

class Conversation {
  final String id;
  final User otherUser; // The person you are talking to
  final Message? lastMessage;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Backend returns list of participants. Find the one that is NOT the current user? 
    // Or backend formats it for us. 
    // Let's assume the simplified backend response for listed conversations.
    // Ideally backend should return "otherUser" object directly or we parse participants.
    // For now, assuming backend 'participants' list.
    
    // Quick hack: pick first participant that has a user object
    final participants = (json['participants'] as List?) ?? [];
    final otherUserJson = participants.isNotEmpty ? participants[0]['user'] : {};
    
    return Conversation(
      id: json['id'],
      otherUser: User.fromJson(otherUserJson),
      lastMessage: json['messages'] != null && (json['messages'] as List).isNotEmpty 
          ? Message.fromJson(json['messages'][0]) 
          : null,
      unreadCount: 0, // Need backend support for this
    );
  }
}

extension MessageJson on Message {
  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['createdAt']),
      isRead: false,
    );
  }
}
