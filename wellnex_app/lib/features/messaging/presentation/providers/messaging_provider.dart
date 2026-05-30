import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../services/messaging_service.dart';
import '../../../../services/api_service.dart';
import '../../domain/models/messaging_models.dart';

class MessagingState {
  final List<Conversation> conversations;
  final Map<String, List<Message>> messages; // conversationId -> messages
  final bool isLoading;
  final String? error;

  MessagingState({
    this.conversations = const [],
    this.messages = const {},
    this.isLoading = false,
    this.error,
  });

  MessagingState copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MessagingNotifier extends StateNotifier<MessagingState> {
  final MessagingService _service;
  final String? _userId;

  MessagingNotifier(this._service, this._userId) : super(MessagingState()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    if (_userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final conversations = await _service.getConversations();
      // Also pre-load messages for active convs if needed, or lazy load
      // For now just load convs
      state = state.copyWith(isLoading: false, conversations: conversations, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messages = await _service.getMessages(conversationId);
      state = state.copyWith(
        messages: {
           ...state.messages,
           conversationId: messages
        },
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: ApiError.from(e).message);
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    if (_userId == null) return;
    try {
      final newMessage = await _service.sendMessage(conversationId, content);
      
      final currentMsgs = state.messages[conversationId] ?? [];
      
      state = state.copyWith(
        messages: {
          ...state.messages,
          conversationId: [...currentMsgs, newMessage],
        },
      );
      
      // Ideally refresh conv list to update last message
      loadConversations();
    } catch (e) {
      state = state.copyWith(error: ApiError.from(e).message);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final messagingProvider = StateNotifierProvider.autoDispose<MessagingNotifier, MessagingState>((ref) {
  final user = ref.watch(currentUserProvider);
  return MessagingNotifier(ref.watch(messagingServiceProvider), user?.id);
});
