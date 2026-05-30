import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum LeaderboardType { global, friends, corporate }
enum TimeFrame { daily, weekly, monthly, allTime }

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final int xp;
  final int trend;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    required this.xp,
    this.trend = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank, {bool isCurrentUser = false}) {
    return LeaderboardEntry(
      userId: json['userId'] ?? json['id'] ?? '',
      username: json['name'] ?? 'User $rank',
      avatarUrl: json['avatarUrl'],
      rank: rank,
      xp: json['todaySteps'] ?? json['lifetimeSteps'] ?? 0,
      trend: 0, // Would need historical data
      isCurrentUser: isCurrentUser,
    );
  }
}

class LeaderboardState {
  final bool isLoading;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final LeaderboardType type;
  final TimeFrame timeFrame;
  final String? error;

  LeaderboardState({
    this.isLoading = false,
    this.entries = const [],
    this.currentUserEntry,
    this.type = LeaderboardType.global,
    this.timeFrame = TimeFrame.weekly,
    this.error,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    List<LeaderboardEntry>? entries,
    LeaderboardEntry? currentUserEntry,
    LeaderboardType? type,
    TimeFrame? timeFrame,
    String? error,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
      type: type ?? this.type,
      timeFrame: timeFrame ?? this.timeFrame,
      error: error,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final ApiService _apiService;

  LeaderboardNotifier(this._apiService) : super(LeaderboardState()) {
    fetchLeaderboard();
  }

  Future<void> setType(LeaderboardType type) async {
    state = state.copyWith(type: type);
    await fetchLeaderboard();
  }

  Future<void> setTimeFrame(TimeFrame frame) async {
    state = state.copyWith(timeFrame: frame);
    await fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    state = state.copyWith(isLoading: true);

    try {
      final typeStr = state.type.toString().split('.').last;
      final timeFrameStr = state.timeFrame.toString().split('.').last;
      final response = await _apiService.get('/friends/leaderboard?type=$typeStr&timeFrame=$timeFrameStr');
      final data = response.data;
      
      final List<LeaderboardEntry> entries = [];
      int rank = 1;
      
      // Parse list directly (global/friends returns array)
      if (data is List) {
        for (var item in data) {
           entries.add(LeaderboardEntry.fromJson(item, rank++, isCurrentUser: item['isCurrentUser'] == true));
        }
      }

      // Find current user entry from parsed entries
      LeaderboardEntry? myEntry;
      try {
        myEntry = entries.firstWhere((e) => e.isCurrentUser);
      } catch (_) {
        // No current user in list
      }

      // Sort by XP (steps)
      entries.sort((a, b) => b.xp.compareTo(a.xp));
      // Update ranks after sort
      for (int i = 0; i < entries.length; i++) {
        entries[i] = LeaderboardEntry(
          userId: entries[i].userId,
          username: entries[i].username,
          avatarUrl: entries[i].avatarUrl,
          rank: i + 1,
          xp: entries[i].xp,
          trend: entries[i].trend,
          isCurrentUser: entries[i].isCurrentUser,
        );
      }

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        currentUserEntry: myEntry,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  // Removed _loadDemoData

}

final leaderboardProvider = StateNotifierProvider.autoDispose<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(ref.watch(apiServiceProvider));
});
