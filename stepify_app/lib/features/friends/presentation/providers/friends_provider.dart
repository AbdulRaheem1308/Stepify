import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../services/api_service.dart';

/// Friend Model
class Friend {
  final String id;
  final String name;
  final String? avatarUrl;
  final int dailyStepCount;
  final bool boostSentToday;
  final int? rank;
  final bool isTopFriend;

  Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.dailyStepCount = 0,
    this.boostSentToday = false,
    this.rank,
    this.isTopFriend = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      dailyStepCount: json['dailyStepCount'] ?? 0,
      boostSentToday: json['boostSentToday'] ?? false,
      rank: json['rank'],
      isTopFriend: json['isTopFriend'] ?? false,
    );
  }
}

/// Search Result Model
class UserSearchResult {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? friendshipStatus;

  UserSearchResult({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.friendshipStatus,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      friendshipStatus: json['friendshipStatus'],
    );
  }
}

/// Friends State
class FriendsState {
  final bool isLoading;
  final List<Friend> friends;
  final List<Friend> leaderboard;
  final List<UserSearchResult> searchResults;
  final List<Friend> pendingRequests;
  final String? error;

  FriendsState({
    this.isLoading = false,
    this.friends = const [],
    this.leaderboard = const [],
    this.searchResults = const [],
    this.pendingRequests = const [],
    this.error,
  });

  FriendsState copyWith({
    bool? isLoading,
    List<Friend>? friends,
    List<Friend>? leaderboard,
    List<UserSearchResult>? searchResults,
    List<Friend>? pendingRequests,
    String? error,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      leaderboard: leaderboard ?? this.leaderboard,
      searchResults: searchResults ?? this.searchResults,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      error: error,
    );
  }
}

/// Friends Provider
final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  return FriendsNotifier(ref.watch(apiServiceProvider));
});

class FriendsNotifier extends StateNotifier<FriendsState> {
  final ApiService _apiService;

  FriendsNotifier(this._apiService) : super(FriendsState());

  /// Fetch friends and leaderboard
  Future<void> fetchFriendsData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _apiService.get('/friends'),
        _apiService.get('/friends/leaderboard'),
      ]);

      state = state.copyWith(
        isLoading: false,
        friends: (results[0].data as List).map((e) => Friend.fromJson(e)).toList(),
        leaderboard: (results[1].data as List).map((e) => Friend.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      // Error handling
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      state = state.copyWith(searchResults: []);
      return;
    }

    try {
      final response = await _apiService.get('/friends/search?q=$query');
      state = state.copyWith(
        searchResults: (response.data as List).map((e) => UserSearchResult.fromJson(e)).toList(),
      );
    } catch (e) {
      // Keep existing
    }
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String friendId) async {
    try {
      await _apiService.post('/friends/request', data: {'friendId': friendId});
      await searchUsers(''); // Clear search
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Send boost to friend
  Future<bool> sendBoost(String friendId) async {
    try {
      await _apiService.post('/friends/boost', data: {'friendId': friendId});
      await fetchFriendsData(); // Refresh
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }

  // Removed _demoFriends and _demoLeaderboard

}
