import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../services/api_service.dart';

/// Transaction Model
class WalletTransaction {
  final String id;
  final String type;
  final int points;
  final String? description;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.points,
    this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? 'STEPS',
      points: json['points'] ?? 0,
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isEarning => points > 0;
  bool get isRedemption => points < 0 || type == 'REDEMPTION';
}

/// Wallet State
class WalletState {
  final bool isLoading;
  final int balance;
  final int lifetimePoints;
  final List<WalletTransaction> transactions;
  final String selectedFilter;
  final String? error;

  WalletState({
    this.isLoading = false,
    this.balance = 0,
    this.lifetimePoints = 0,
    this.transactions = const [],
    this.selectedFilter = 'ALL',
    this.error,
  });

  WalletState copyWith({
    bool? isLoading,
    int? balance,
    int? lifetimePoints,
    List<WalletTransaction>? transactions,
    String? selectedFilter,
    String? error,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      balance: balance ?? this.balance,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      transactions: transactions ?? this.transactions,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      error: error,
    );
  }

  List<WalletTransaction> get filteredTransactions {
    switch (selectedFilter) {
      case 'EARNED':
        return transactions.where((t) => t.isEarning).toList();
      case 'REDEEMED':
        return transactions.where((t) => t.isRedemption).toList();
      default:
        return transactions;
    }
  }
}

/// Wallet Provider
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.watch(apiServiceProvider));
});

class WalletNotifier extends StateNotifier<WalletState> {
  final ApiService _apiService;

  WalletNotifier(this._apiService) : super(WalletState());

  /// Fetch wallet data
  Future<void> fetchWalletData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _apiService.get('/rewards/wallet'),
        _apiService.get('/rewards/transactions'),
      ]);

      final walletData = results[0].data;
      final transactionsData = results[1].data;

      state = state.copyWith(
        isLoading: false,
        balance: walletData['balance'] ?? 0,
        lifetimePoints: walletData['lifetimePoints'] ?? 0,
        transactions: (transactionsData['data'] as List?)
            ?.map((e) => WalletTransaction.fromJson(e))
            .toList() ?? [],
      );
    } catch (e) {
      // Error handling
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  /// Set filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Demo transactions
  // Removed _demoTransactions

}
