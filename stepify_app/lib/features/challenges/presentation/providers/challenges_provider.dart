import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../services/api_service.dart';

/// Challenge Model
class Challenge {
  final String id;
  final String title;
  final String description;
  final int stepTarget;
  final int rewardCoins;
  final int rewardXp;
  final int durationDays;
  final String challengeType;
  final String difficulty;
  final String? imageUrl;
  final bool isInviteOnly;
  final int? participantsCount;
  final DateTime? endsAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.stepTarget,
    required this.rewardCoins,
    required this.rewardXp,
    required this.durationDays,
    required this.challengeType,
    required this.difficulty,
    this.imageUrl,
    this.isInviteOnly = false,
    this.participantsCount,
    this.endsAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Challenge',
      description: json['description'] ?? '',
      stepTarget: json['stepTarget'] ?? 0,
      rewardCoins: json['rewardCoins'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
      durationDays: json['durationDays'] ?? 7,
      challengeType: json['challengeType'] ?? 'SOLO',
      difficulty: json['difficulty'] ?? 'MEDIUM',
      imageUrl: json['imageUrl'],
      isInviteOnly: json['isInviteOnly'] ?? false,
      participantsCount: json['participantsCount'] ?? json['_count']?['userChallenges'],
      endsAt: json['endsAt'] != null ? DateTime.tryParse(json['endsAt'] ?? '') : null,
    );
  }
}

/// User Challenge Model (joined challenge with progress)
class UserChallenge {
  final String id;
  final String status;
  final int currentSteps;
  final int progress;
  final DateTime joinedAt;
  final DateTime? completedAt;
  final Challenge challenge;

  UserChallenge({
    required this.id,
    required this.status,
    required this.currentSteps,
    required this.progress,
    required this.joinedAt,
    this.completedAt,
    required this.challenge,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'],
      status: json['status'] ?? 'ONGOING',
      currentSteps: json['currentSteps'] ?? 0,
      progress: json['progress'] ?? 0,
      joinedAt: DateTime.parse(json['joinedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      challenge: Challenge.fromJson(json['challenge']),
    );
  }
}

/// Challenges State
class ChallengesState {
  final bool isLoading;
  final List<Challenge> newChallenges;
  final List<UserChallenge> ongoingChallenges;
  final List<UserChallenge> completedChallenges;
  final String? error;

  ChallengesState({
    this.isLoading = false,
    this.newChallenges = const [],
    this.ongoingChallenges = const [],
    this.completedChallenges = const [],
    this.error,
  });

  ChallengesState copyWith({
    bool? isLoading,
    List<Challenge>? newChallenges,
    List<UserChallenge>? ongoingChallenges,
    List<UserChallenge>? completedChallenges,
    String? error,
  }) {
    return ChallengesState(
      isLoading: isLoading ?? this.isLoading,
      newChallenges: newChallenges ?? this.newChallenges,
      ongoingChallenges: ongoingChallenges ?? this.ongoingChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      error: error,
    );
  }
}

/// Challenges Provider
final challengesProvider = StateNotifierProvider<ChallengesNotifier, ChallengesState>((ref) {
  return ChallengesNotifier(ref.watch(apiServiceProvider));
});

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  final ApiService _apiService;

  ChallengesNotifier(this._apiService) : super(ChallengesState());

  /// Fetch all challenges (new, ongoing, completed)
  Future<void> fetchAllChallenges() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _apiService.get('/challenges/new'),
        _apiService.get('/challenges/ongoing'),
        _apiService.get('/challenges/completed'),
      ]);

      state = state.copyWith(
        isLoading: false,
        newChallenges: (results[0].data as List).map((e) => Challenge.fromJson(e)).toList(),
        ongoingChallenges: (results[1].data as List).map((e) => UserChallenge.fromJson(e)).toList(),
        completedChallenges: (results[2].data as List).map((e) => UserChallenge.fromJson(e)).toList(),
      );
    } catch (e) {
      // Error handling
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  /// Join a challenge
  Future<bool> joinChallenge(String challengeId) async {
    try {
      await _apiService.post('/challenges/join', data: {'challengeId': challengeId});
      await fetchAllChallenges();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Removed _demoChallenges and _demoOngoing

}
