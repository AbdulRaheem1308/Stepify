import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../../../services/api_service.dart';

/// Referral Stats Model
class ReferralStats {
  final String referralCode;
  final int invitesSent;
  final int invitesAccepted;
  final int coinsEarned;
  final int rank;
  final List<ReferralMilestone> milestones;

  const ReferralStats({
    required this.referralCode,
    this.invitesSent = 0,
    this.invitesAccepted = 0,
    this.coinsEarned = 0,
    this.rank = 0,
    this.milestones = const [],
  });

  ReferralStats copyWith({
    String? referralCode,
    int? invitesSent,
    int? invitesAccepted,
    int? coinsEarned,
    int? rank,
    List<ReferralMilestone>? milestones,
  }) {
    return ReferralStats(
      referralCode: referralCode ?? this.referralCode,
      invitesSent: invitesSent ?? this.invitesSent,
      invitesAccepted: invitesAccepted ?? this.invitesAccepted,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      rank: rank ?? this.rank,
      milestones: milestones ?? this.milestones,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferralStats &&
          runtimeType == other.runtimeType &&
          referralCode == other.referralCode &&
          invitesSent == other.invitesSent &&
          invitesAccepted == other.invitesAccepted &&
          coinsEarned == other.coinsEarned &&
          rank == other.rank &&
          _listEquals(milestones, other.milestones);

  @override
  int get hashCode =>
      referralCode.hashCode ^
      invitesSent.hashCode ^
      invitesAccepted.hashCode ^
      coinsEarned.hashCode ^
      rank.hashCode ^
      milestones.hashCode;

  int get nextMilestoneTarget {
    final targets = [1, 3, 5, 10, 25, 50, 100];
    for (final t in targets) {
      if (invitesAccepted < t) return t;
    }
    return invitesAccepted + 10;
  }

  double get progressToNextMilestone {
    final prev = milestones.lastWhere((m) => m.isUnlocked, orElse: () => ReferralMilestone(target: 0, reward: 0, isUnlocked: false));
    final prevTarget = prev.target;
    final next = nextMilestoneTarget;
    if (next == prevTarget) return 1.0;
    return (invitesAccepted - prevTarget) / (next - prevTarget);
  }
}

/// Milestone Model
class ReferralMilestone {
  final int target;
  final int reward;
  final bool isUnlocked;

  const ReferralMilestone({
    required this.target,
    required this.reward,
    required this.isUnlocked,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferralMilestone &&
          runtimeType == other.runtimeType &&
          target == other.target &&
          reward == other.reward &&
          isUnlocked == other.isUnlocked;

  @override
  int get hashCode => target.hashCode ^ reward.hashCode ^ isUnlocked.hashCode;
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Top Referrer Model
class TopReferrer {
  final String id;
  final String name;
  final String? avatarUrl;
  final int referrals;
  final int rank;

  const TopReferrer({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.referrals,
    required this.rank,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopReferrer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          avatarUrl == other.avatarUrl &&
          referrals == other.referrals &&
          rank == other.rank;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      avatarUrl.hashCode ^
      referrals.hashCode ^
      rank.hashCode;
}

/// Referral State
class ReferralState {
  final bool isLoading;
  final ReferralStats stats;
  final List<TopReferrer> leaderboard;
  final String? error;

  ReferralState({
    this.isLoading = false,
    ReferralStats? stats,
    this.leaderboard = const [],
    this.error,
  }) : stats = stats ?? const ReferralStats(referralCode: '');

  ReferralState copyWith({
    bool? isLoading,
    ReferralStats? stats,
    List<TopReferrer>? leaderboard,
    String? error,
  }) {
    return ReferralState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      leaderboard: leaderboard ?? this.leaderboard,
      error: error, // Can be null to clear
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferralState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          stats == other.stats &&
          _listEquals(leaderboard, other.leaderboard) &&
          error == other.error;

  @override
  int get hashCode =>
      isLoading.hashCode ^ stats.hashCode ^ leaderboard.hashCode ^ error.hashCode;
}

/// Referral Provider
final referralProvider = StateNotifierProvider.autoDispose<ReferralNotifier, ReferralState>((ref) {
  return ReferralNotifier(ref.watch(apiServiceProvider));
});

class ReferralNotifier extends StateNotifier<ReferralState> {
  final ApiService _apiService;

  ReferralNotifier(this._apiService) : super(ReferralState());

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Fetch referral data
  Future<void> fetchReferralData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _apiService.get('/friends/invitations'),
        _apiService.get('/users/me'),
        _apiService.get('/users/referral-leaderboard'),
      ]);

      final invitations = results[0].data as List? ?? [];
      final user = results[1].data;
      final leaderboardData = results[2].data as List? ?? [];

      // Generate referral code from user ID
      final userId = user['id'] ?? '';
      final code = _generateReferralCode(userId);

      final accepted = invitations.where((i) => i['status'] == 'ACCEPTED').length;
      
      // Parse leaderboard from API
      final leaderboard = leaderboardData.asMap().entries.map((entry) {
        final r = entry.value;
        return TopReferrer(
          id: r['id'] ?? '',
          name: r['name'] ?? 'User',
          referrals: r['referralCount'] ?? 0,
          rank: entry.key + 1,
        );
      }).toList();
      
      state = state.copyWith(
        isLoading: false,
        stats: ReferralStats(
          referralCode: code,
          invitesSent: invitations.length,
          invitesAccepted: accepted,
          coinsEarned: accepted * 50, // 50 coins per referral
          rank: 1,
          milestones: _buildMilestones(accepted),
        ),
        leaderboard: leaderboard,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiError.from(e).message,
      );
    }
  }

  String _generateReferralCode(String userId) {
    if (userId.isEmpty) return 'STEP${Random().nextInt(9999).toString().padLeft(4, '0')}';
    return 'STEP${userId.substring(0, min(6, userId.length)).toUpperCase()}';
  }

  List<ReferralMilestone> _buildMilestones(int accepted) {
    return [
      ReferralMilestone(target: 1, reward: 50, isUnlocked: accepted >= 1),
      ReferralMilestone(target: 3, reward: 100, isUnlocked: accepted >= 3),
      ReferralMilestone(target: 5, reward: 200, isUnlocked: accepted >= 5),
      ReferralMilestone(target: 10, reward: 500, isUnlocked: accepted >= 10),
      ReferralMilestone(target: 25, reward: 1000, isUnlocked: accepted >= 25),
      ReferralMilestone(target: 50, reward: 2500, isUnlocked: accepted >= 50),
    ];
  }
}
