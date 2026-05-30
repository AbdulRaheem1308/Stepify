import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum FeedItemType { milestone, streak, challenge, manual }

class FeedPost {
  final String id;
  final String userName;
  final String? avatarUrl;
  final FeedItemType type;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final Map<String, dynamic>? metadata;

  FeedPost({
    required this.id,
    required this.userName,
    this.avatarUrl,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.metadata,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] ?? '',
      userName: json['user']?['name'] ?? 'Anonymous',
      avatarUrl: json['user']?['avatarUrl'],
      type: _parseType(json['type']),
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: json['likesCount'] ?? 0,
      comments: json['commentsCount'] ?? 0,
      metadata: json['metadata'],
    );
  }

  static FeedItemType _parseType(String? type) {
    switch (type) {
      case 'MILESTONE': return FeedItemType.milestone;
      case 'STREAK': return FeedItemType.streak;
      case 'CHALLENGE': return FeedItemType.challenge;
      case 'MANUAL': return FeedItemType.manual;
      default: return FeedItemType.milestone;
    }
  }

  String get displayAvatar => avatarUrl ?? userName[0].toUpperCase();
}

class CommunityState {
  final List<FeedPost> posts;
  final bool isLoading;
  final String? error;

  CommunityState({this.posts = const [], this.isLoading = false, this.error});

  CommunityState copyWith({List<FeedPost>? posts, bool? isLoading, String? error}) {
    return CommunityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final ApiService _apiService;

  CommunityNotifier(this._apiService) : super(CommunityState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get('/community/feed');
      final posts = (response.data as List)
          .map((json) => FeedPost.fromJson(json))
          .toList();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  Future<void> reactToPost(String postId) async {
    try {
      await _apiService.post('/community/posts/$postId/react', data: {'type': 'like'});
      await loadFeed();
    } catch (e) {
      // Optimistic update
      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id == postId) {
            return FeedPost(
              id: p.id, userName: p.userName, avatarUrl: p.avatarUrl,
              type: p.type, content: p.content, timestamp: p.timestamp,
              likes: p.likes + 1, comments: p.comments, metadata: p.metadata,
            );
          }
          return p;
        }).toList(),
      );
    }
  }

  Future<void> createPost(String content) async {
    try {
      await _apiService.post('/community/posts', data: {'content': content, 'type': 'MANUAL'});
      await loadFeed();
    } catch (e) {
      // Handle error
    }
  }

  // Removed _loadDemoData

}

final communityProvider = StateNotifierProvider.autoDispose<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref.watch(apiServiceProvider));
});
