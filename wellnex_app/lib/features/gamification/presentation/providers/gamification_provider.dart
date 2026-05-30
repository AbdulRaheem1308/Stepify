import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

class GamificationState {
  final bool isLoading;
  final int level;
  final String levelTitle;
  final int currentXp;
  final int nextLevelXp;
  final int globalRank;
  final int currentStreak;
  final List<ActivityEvent> recentActivity;
  final String? error;

  GamificationState({
    this.isLoading = true,
    this.level = 1,
    this.levelTitle = 'Rookie Walker',
    this.currentXp = 0,
    this.nextLevelXp = 1000,
    this.globalRank = 0,
    this.currentStreak = 0,
    this.recentActivity = const [],
    this.error,
  });

  double get progress => currentXp / nextLevelXp;
}

class ActivityEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final int xpEarned;
  final String type;

  ActivityEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.xpEarned,
    required this.type,
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      title: _getTitleForType(json['type']),
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      xpEarned: json['points'] ?? 0,
      type: (json['type'] ?? 'STEPS').toString().toLowerCase(),
    );
  }

  static String _getTitleForType(String? type) {
    switch (type) {
      case 'STEPS': return 'Steps Reward';
      case 'STREAK_BONUS': return 'Streak Bonus';
      case 'MILESTONE': return 'Badge Unlocked';
      case 'REFERRAL': return 'Referral Bonus';
      case 'REDEMPTION': return 'Reward Redeemed';
      default: return 'Activity';
    }
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  final ApiService _apiService;
  List<Map<String, dynamic>> _cachedLevels = [];

  GamificationNotifier(this._apiService) : super(GamificationState()) {
    _fetchLevelsAndData();
  }

  Future<void> _fetchLevelsAndData() async {
    // Fetch levels first, then gamification data
    await _fetchLevels();
    await fetchGamificationData();
  }

  Future<void> _fetchLevels() async {
    try {
      final response = await _apiService.get('/rewards/levels');
      _cachedLevels = List<Map<String, dynamic>>.from(response.data ?? []);
    } catch (e) {
      _cachedLevels = []; // Will use fallback
    }
  }

  String _getLevelTitle(int level) {
    // Try to get from cached API data
    if (_cachedLevels.isNotEmpty) {
      final levelData = _cachedLevels.firstWhere(
        (l) => l['levelNumber'] == level,
        orElse: () => {},
      );
      if (levelData.isNotEmpty) {
        return levelData['name'] ?? 'Level $level';
      }
    }
    // Fallback to generic level name if API data unavailable
    return 'Level $level';
  }

  int _calculateLevel(int monthlyXp) {
    const xpPerLevel = 1000;
    int level = 1;
    int xpForNextLevel = xpPerLevel;
    int remainingPoints = monthlyXp;

    while (remainingPoints >= xpForNextLevel) {
      remainingPoints -= xpForNextLevel;
      level++;
      xpForNextLevel = (xpPerLevel * (1 + (level - 1) * 0.5)).toInt();
    }
    return level;
  }

  Future<void> fetchGamificationData() async {
    state = GamificationState(isLoading: true);

    try {
      final results = await Future.wait([
        _apiService.get('/users/me/stats'),
        _apiService.get('/rewards/transactions?limit=5'), // Show only 5 recent activities
        _apiService.get('/rewards/streak'),
      ]);

      final stats = results[0].data;
      final transactions = results[1].data;
      final streak = results[2].data;
      // Also fetch wallet to get 'monthlyXp' specifically
      final walletRes = await _apiService.get('/rewards/wallet');
      final monthlyXp = walletRes.data['monthlyXp'] ?? 0;

      // Use monthly XP for seasonal level
      final level = _calculateLevel(monthlyXp);
      final xpPerLevel = 1000;
      int currentXp = monthlyXp;
      int nextLevelXp = xpPerLevel;
      
      // Calculate current XP within level
      int tempPoints = monthlyXp;
      int tempXpForNext = xpPerLevel;
      for (int l = 1; l < level; l++) {
        tempPoints -= tempXpForNext;
        tempXpForNext = (xpPerLevel * (1 + l * 0.5)).toInt();
      }
      currentXp = tempPoints;
      nextLevelXp = tempXpForNext;

      // Parse transactions as activity (limit to 5 most recent)
      final List<ActivityEvent> activity = [];
      if (transactions['data'] != null) {
        final txList = (transactions['data'] as List).take(5);
        for (var tx in txList) {
          activity.add(ActivityEvent.fromJson(tx));
        }
      }

      state = GamificationState(
        isLoading: false,
        level: level,
        levelTitle: _getLevelTitle(level),
        currentXp: currentXp,
        nextLevelXp: nextLevelXp,
        globalRank: 0, // Would need a separate endpoint
        currentStreak: streak['currentStreak'] ?? 0,
        recentActivity: activity,
      );
    } catch (e) {
      state = GamificationState(isLoading: false, error: ApiError.from(e).message);
    }
  }

  // Removed _loadDemoData

}

final gamificationProvider = StateNotifierProvider.autoDispose<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref.watch(apiServiceProvider));
});
