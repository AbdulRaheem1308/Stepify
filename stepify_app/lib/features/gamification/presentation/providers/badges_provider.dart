import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum BadgeStatus { locked, unlocked, inProgress }

class Badge {
  final String id;
  final String title;
  final String description;
  final BadgeStatus status;
  final String unlockCriteria;
  final DateTime? earnedDate;
  final String category;
  final double progress;
  final String icon;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.unlockCriteria,
    this.earnedDate,
    required this.category,
    this.progress = 0.0,
    this.icon = 'emoji_events',
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    final unlocked = json['unlocked'] == true;
    final progressValue = (json['progress'] ?? 0) / 100.0;

    BadgeStatus status;
    if (unlocked) {
      status = BadgeStatus.unlocked;
    } else if (progressValue > 0) {
      status = BadgeStatus.inProgress;
    } else {
      status = BadgeStatus.locked;
    }

    String criteria = '';
    if (json['stepsRequired'] != null) {
      criteria = 'Walk ${json['stepsRequired']} steps total';
    } else if (json['streakRequired'] != null) {
      criteria = 'Maintain a ${json['streakRequired']}-day streak';
    }

    return Badge(
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      status: status,
      unlockCriteria: criteria,
      earnedDate: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      category: json['category'] ?? 'SPECIAL',
      progress: progressValue.clamp(0.0, 1.0),
      icon: json['icon'] ?? 'emoji_events',
    );
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
