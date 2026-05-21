import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/company_service.dart';
import '../../../../services/api_service.dart';
import '../../domain/models/company_model.dart';

// State
class CompanyState {
  final bool isLoading;
  final CompanyMember? member;
  final List<CompanyMember> leaderboard;
  final String? error;

  CompanyState({
    this.isLoading = false,
    this.member,
    this.leaderboard = const [],
    this.error,
  });

  CompanyState copyWith({
    bool? isLoading,
    CompanyMember? member,
    List<CompanyMember>? leaderboard,
    String? error,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      member: member ?? this.member,
      leaderboard: leaderboard ?? this.leaderboard,
      error: error,
    );
  }
}

// Service Provider
final companyServiceProvider = Provider<CompanyService>((ref) {
  return CompanyService(ref.watch(apiServiceProvider));
});

// Notifier
class CompanyNotifier extends StateNotifier<CompanyState> {
  final CompanyService _service;
  final Ref _ref;

  CompanyNotifier(this._service, this._ref) : super(CompanyState()) {
    _loadMyCompany();
  }

  Future<void> _loadMyCompany() async {
    state = state.copyWith(isLoading: true);
    try {
      final member = await _service.getMyCompany();
      if (member != null) {
        // Load leaderboard too if member exists
        final leaderboard = await _service.getLeaderboard(member.companyId);
        state = state.copyWith(isLoading: false, member: member, leaderboard: leaderboard);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> joinCompany(String inviteCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final member = await _service.joinCompany(inviteCode);
      final leaderboard = await _service.getLeaderboard(member.companyId);
      state = state.copyWith(isLoading: false, member: member, leaderboard: leaderboard);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Invalid code or already joined");
      return false;
    }
  }
}

// Global Provider
final companyProvider = StateNotifierProvider<CompanyNotifier, CompanyState>((ref) {
  return CompanyNotifier(ref.watch(companyServiceProvider), ref);
});
