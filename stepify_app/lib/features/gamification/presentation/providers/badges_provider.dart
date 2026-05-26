import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum BadgeStatus { locked, unlocked, inProgress }

class Badge {
  final String id;
  final String title;
  final String description;
  final BadgeStatus status;
  final String unlockCriteria;
  final String howToEarn;       // Step-by-step guide
  final DateTime? earnedDate;
  final String category;
  final double progress;
  final String icon;
  final int pointsReward;       // Coins awarded on unlock
  final int currentValue;       // User's current progress value
  final int? targetValue;       // The goal needed to unlock

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.unlockCriteria,
    required this.howToEarn,
    this.earnedDate,
    required this.category,
    this.progress = 0.0,
    this.icon = 'emoji_events',
    this.pointsReward = 0,
    this.currentValue = 0,
    this.targetValue,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    final unlocked = json['unlocked'] == true;
    final progressValue = (json['progress'] ?? 0) / 100.0;
    final category = (json['category'] ?? 'SPECIAL') as String;
    final stepsRequired = json['stepsRequired'] as int?;
    final streakRequired = json['streakRequired'] as int?;
    final targetValue = json['targetValue'] as int?;
    final currentValue = json['currentValue'] as int? ?? 0;
    final pointsReward = json['pointsReward'] as int? ?? 0;

    BadgeStatus status;
    if (unlocked) {
      status = BadgeStatus.unlocked;
    } else if (progressValue > 0) {
      status = BadgeStatus.inProgress;
    } else {
      status = BadgeStatus.locked;
    }

    // Build a one-line criteria summary
    String criteria;
    // Build a rich multi-step how-to-earn guide
    String howToEarn;

    switch (category.toUpperCase()) {
      case 'STEPS':
        final goal = stepsRequired ?? targetValue ?? 0;
        criteria = 'Walk ${_formatNumber(goal)} total lifetime steps';
        howToEarn =
            '1. Open Stepify every day and let the pedometer run.\n'
            '2. Walk, jog, or run to accumulate steps.\n'
            '3. Your steps are tracked automatically throughout the day.\n'
            '4. Reach ${ _formatNumber(goal)} cumulative lifetime steps to earn this badge.';
        break;
      case 'STREAK':
        final days = streakRequired ?? targetValue ?? 0;
        criteria = 'Maintain a $days-day walking streak';
        howToEarn =
            '1. Walk at least your daily step goal every single day.\n'
            '2. Open Stepify before midnight to sync your steps.\n'
            '3. Do not miss a single day — one missed day resets your streak.\n'
            '4. Keep your streak alive for $days consecutive days to earn this badge.';
        break;
      case 'CHALLENGE':
        final count = targetValue ?? 1;
        criteria = 'Complete $count challenge${count > 1 ? 's' : ''}';
        howToEarn =
            '1. Go to the Challenges tab in the app.\n'
            '2. Browse available challenges and tap "Join Challenge".\n'
            '3. Complete the required steps within the challenge duration.\n'
            '4. Complete $count challenge${count > 1 ? 's' : ''} successfully to earn this badge.';
        break;
      case 'SOCIAL':
        final friends = targetValue ?? 1;
        criteria = 'Add $friends friend${friends > 1 ? 's' : ''} on Stepify';
        howToEarn =
            '1. Go to the Friends section in your profile.\n'
            '2. Search for friends by name or share your referral link.\n'
            '3. Send friend requests and wait for them to accept.\n'
            '4. Have $friends accepted friend connection${friends > 1 ? 's' : ''} to earn this badge.';
        break;
      case 'COINS':
        final coins = targetValue ?? stepsRequired ?? 0;
        criteria = 'Earn ${_formatNumber(coins)} lifetime coins';
        howToEarn =
            '1. Walk daily to earn 0.1 coins per step (awarded every 4 hours).\n'
            '2. Complete challenges for bonus coin rewards.\n'
            '3. Maintain streaks for streak bonus coins.\n'
            '4. Watch ads and complete offers for extra coins.\n'
            '5. Accumulate ${_formatNumber(coins)} total coins earned over your lifetime.';
        break;
      case 'COMMUNITY':
        criteria = 'Participate in the Stepify community';
        howToEarn =
            '1. Join and post in the Community Feed.\n'
            '2. Like and comment on other users\' milestones.\n'
            '3. Actively participate to unlock this community badge.';
        break;
      default:
        criteria = json['description'] ?? 'Complete the special requirement';
        howToEarn = json['description'] ?? 'Follow special in-app events to earn this badge.';
    }

    return Badge(
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      status: status,
      unlockCriteria: criteria,
      howToEarn: howToEarn,
      earnedDate: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      category: category,
      progress: progressValue.clamp(0.0, 1.0),
      icon: json['icon'] ?? 'emoji_events',
      pointsReward: pointsReward,
      currentValue: currentValue,
      targetValue: stepsRequired ?? streakRequired ?? targetValue,
    );
  }

  static String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(num % 1000 == 0 ? 0 : 1)}k';
    return num.toString();
  }
}

class BadgesState {
  final List<Badge> badges;
  final String activeFilter;
  final bool isLoading;
  final String? error;

  BadgesState({
    this.badges = const [],
    this.activeFilter = 'All',
    this.isLoading = false,
    this.error,
  });

  BadgesState copyWith({
    List<Badge>? badges,
    String? activeFilter,
    bool? isLoading,
    String? error,
  }) {
    return BadgesState(
      badges: badges ?? this.badges,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BadgesNotifier extends StateNotifier<BadgesState> {
  final ApiService _apiService;

  BadgesNotifier(this._apiService) : super(BadgesState()) {
    loadBadges();
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> loadBadges() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get('/rewards/achievements');
      final badges = (response.data as List)
          .map((json) => Badge.fromJson(json))
          .toList();
      state = state.copyWith(badges: badges, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  // Removed _loadDemoData
}

final badgesProvider = StateNotifierProvider.autoDispose<BadgesNotifier, BadgesState>((ref) {
  return BadgesNotifier(ref.watch(apiServiceProvider));
});
