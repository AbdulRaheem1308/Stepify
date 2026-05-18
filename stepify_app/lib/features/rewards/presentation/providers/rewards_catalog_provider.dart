import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../services/api_service.dart';

/// Reward Model
class Reward {
  final String id;
  final String title;
  final String description;
  final int coinCost;
  final String category;
  final String? imageUrl;
  final String? partnerName;
  final String? partnerLogoUrl;
  final int availableStock;
  final bool isLimitedEdition;
  final bool canAfford;
  final bool inStock;
  final DateTime? expiryDate;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.coinCost,
    required this.category,
    this.imageUrl,
    this.partnerName,
    this.partnerLogoUrl,
    this.availableStock = -1,
    this.isLimitedEdition = false,
    this.canAfford = false,
    this.inStock = true,
    this.expiryDate,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coinCost: json['coinCost'] ?? 0,
      category: json['category'] ?? 'OTHER',
      imageUrl: json['imageUrl'],
      partnerName: json['partnerName'],
      partnerLogoUrl: json['partnerLogoUrl'],
      availableStock: json['availableStock'] ?? -1,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      canAfford: json['canAfford'] ?? false,
      inStock: json['inStock'] ?? true,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }
}

/// User Redemption Model
class UserRedemption {
  final String id;
  final int coinCost;
  final String status;
  final String? voucherCode;
  final DateTime redeemedAt;
  final DateTime? expiresAt;
  final Reward reward;

  UserRedemption({
    required this.id,
    required this.coinCost,
    required this.status,
    this.voucherCode,
    required this.redeemedAt,
    this.expiresAt,
    required this.reward,
  });

  factory UserRedemption.fromJson(Map<String, dynamic> json) {
    return UserRedemption(
      id: json['id'],
      coinCost: json['coinCost'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      voucherCode: json['voucherCode'],
      redeemedAt: DateTime.parse(json['redeemedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      reward: Reward.fromJson(json['reward']),
    );
  }
}

/// Redemption Categories
const rewardCategories = [
  'ALL',
  'FITNESS',
  'FOOD',
  'LIFESTYLE',
  'SHOPPING',
  'TRAVEL',
  'ENTERTAINMENT',
];

/// Rewards State
class RewardsCatalogState {
  final bool isLoading;
  final List<Reward> rewards;
  final List<UserRedemption> myOffers;
  final String selectedCategory;
  final String? error;

  RewardsCatalogState({
    this.isLoading = false,
    this.rewards = const [],
    this.myOffers = const [],
    this.selectedCategory = 'ALL',
    this.error,
  });

  RewardsCatalogState copyWith({
    bool? isLoading,
    List<Reward>? rewards,
    List<UserRedemption>? myOffers,
    String? selectedCategory,
    String? error,
  }) {
    return RewardsCatalogState(
      isLoading: isLoading ?? this.isLoading,
      rewards: rewards ?? this.rewards,
      myOffers: myOffers ?? this.myOffers,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error,
    );
  }
}

/// Rewards Catalog Provider
final rewardsCatalogProvider = StateNotifierProvider<RewardsCatalogNotifier, RewardsCatalogState>((ref) {
  return RewardsCatalogNotifier(ref.watch(apiServiceProvider));
});

class RewardsCatalogNotifier extends StateNotifier<RewardsCatalogState> {
  final ApiService _apiService;

  RewardsCatalogNotifier(this._apiService) : super(RewardsCatalogState());

  /// Fetch rewards catalog
  Future<void> fetchCatalog({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final queryParams = category != null && category != 'ALL' ? '?category=$category' : '';
      final response = await _apiService.get('/rewards/catalog$queryParams');

      state = state.copyWith(
        isLoading: false,
        rewards: (response.data as List).map((e) => Reward.fromJson(e)).toList(),
        selectedCategory: category ?? 'ALL',
      );
    } on DioException catch (e) {
      // Error handling
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  /// Fetch my offers
  Future<void> fetchMyOffers() async {
    try {
      final response = await _apiService.get('/rewards/my-offers');
      state = state.copyWith(
        myOffers: (response.data as List).map((e) => UserRedemption.fromJson(e)).toList(),
      );
    } catch (e) {
      // Keep existing or empty
    }
  }

  /// Redeem a reward
  Future<Map<String, dynamic>?> redeemReward(String rewardId) async {
    try {
      final response = await _apiService.post('/rewards/redeem', data: {'rewardId': rewardId});
      
      // Refresh catalog and my offers
      await fetchCatalog(category: state.selectedCategory);
      await fetchMyOffers();
      
      return response.data;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Set category filter
  void setCategory(String category) {
    fetchCatalog(category: category);
  }

  /// Demo rewards
  // Removed _demoRewards

}
