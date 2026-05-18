import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../services/messaging_service.dart';
import '../../../../services/api_service.dart';
import '../../domain/models/messaging_models.dart';

class MessagingState {
  final List<Conversation> conversations;
  final Map<String, List<Message>> messages; // conversationId -> messages
  final bool isLoading;

  MessagingState({
    this.conversations = const [],
    this.messages = const {},
    this.isLoading = false,
  });

  MessagingState copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
    bool? isLoading,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MessagingNotifier extends StateNotifier<MessagingState> {
  final MessagingService _service;
  final String? _userId;

  MessagingNotifier(this._service, this._userId) : super(MessagingState()) {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final conversations = await _service.getConversations(_userId!);
      // Also pre-load messages for active convs if needed, or lazy load
      // For now just load convs
      state = state.copyWith(isLoading: false, conversations: conversations);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messages = await _service.getMessages(conversationId);
      state = state.copyWith(
        messages: {
           ...state.messages,
           conversationId: messages
        }
      );
    } catch (e) {
      print("Failed to load messages: $e");
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    if (_userId == null) return;
    try {
      final newMessage = await _service.sendMessage(conversationId, _userId!, content);
      
      final currentMsgs = state.messages[conversationId] ?? [];
      
      state = state.copyWith(
        messages: {
          ...state.messages,
          conversationId: [...currentMsgs, newMessage],
        },
      );
      
      // Ideally refresh conv list to update last message
      _loadConversations();
    } catch (e) {
      print('Failed to send message: $e');
    }
  }
}

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(ref.watch(apiServiceProvider));
});

final messagingProvider = StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
  final user = ref.watch(currentUserProvider);
  return MessagingNotifier(ref.watch(messagingServiceProvider), user?.id);
});
