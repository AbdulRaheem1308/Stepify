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
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.senderId == senderId &&
        other.content == content &&
        other.timestamp.isAtSameMomentAs(timestamp) &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        conversationId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        timestamp.hashCode ^
        isRead.hashCode;
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
    final participants = (json['participants'] as List?) ?? [];
    final otherUserJson = participants.isNotEmpty && participants[0] is Map
        ? (participants[0]['user'] as Map?) ?? {}
        : {};

    return Conversation(
      id: json['id'] ?? '',
      otherUser: User.fromJson(Map<String, dynamic>.from(otherUserJson)),
      lastMessage: json['messages'] != null && (json['messages'] as List).isNotEmpty
          ? Message.fromJson(Map<String, dynamic>.from(json['messages'][0]))
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.id == id &&
        other.otherUser == otherUser &&
        other.lastMessage == lastMessage &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        otherUser.hashCode ^
        lastMessage.hashCode ^
        unreadCount.hashCode;
  }
}

extension MessageJson on Message {
  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}
