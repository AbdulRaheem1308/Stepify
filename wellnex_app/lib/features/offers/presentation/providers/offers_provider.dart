import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum OfferType { watchToEarn, survey, appInstall, purchase, externalSignup }

class Offer {
  final String id;
  final String title;
  final String providerName;
  final String? imageUrl;
  final int rewardCoins;
  final OfferType type;
  final String description;
  final String? actionUrl;

  Offer({
    required this.id,
    required this.title,
    required this.providerName,
    this.imageUrl,
    required this.rewardCoins,
    required this.type,
    required this.description,
    this.actionUrl,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      rewardCoins: json['rewardCoins'] ?? 0,
      type: _parseOfferType(json['offerType']?.toString()),
      description: json['description']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          providerName == other.providerName &&
          imageUrl == other.imageUrl &&
          rewardCoins == other.rewardCoins &&
          type == other.type &&
          description == other.description &&
          actionUrl == other.actionUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      providerName.hashCode ^
      imageUrl.hashCode ^
      rewardCoins.hashCode ^
      type.hashCode ^
      description.hashCode ^
      actionUrl.hashCode;

  static OfferType _parseOfferType(String? type) {
    switch (type) {
      case 'WATCH_TO_EARN': return OfferType.watchToEarn;
      case 'SURVEY': return OfferType.survey;
      case 'APP_INSTALL': return OfferType.appInstall;
      case 'PURCHASE': return OfferType.purchase;
      case 'EXTERNAL_SIGNUP': return OfferType.externalSignup;
      default: return OfferType.watchToEarn;
    }
  }
}

class UserOffer {
  final String id;
  final Offer offer;
  final String status;
  final DateTime startedAt;
  final DateTime? completedAt;

  UserOffer({
    required this.id,
    required this.offer,
    required this.status,
    required this.startedAt,
    this.completedAt,
  });

  factory UserOffer.fromJson(Map<String, dynamic> json) {
    DateTime parsedStartedAt;
    try {
      parsedStartedAt = json['startedAt'] != null
          ? DateTime.parse(json['startedAt'].toString())
          : DateTime.now();
    } catch (_) {
      parsedStartedAt = DateTime.now();
    }

    DateTime? parsedCompletedAt;
    if (json['completedAt'] != null) {
      try {
        parsedCompletedAt = DateTime.parse(json['completedAt'].toString());
      } catch (_) {}
    }

    return UserOffer(
      id: json['id']?.toString() ?? '',
      offer: Offer.fromJson(json['offer'] ?? {}),
      status: json['status']?.toString() ?? 'STARTED',
      startedAt: parsedStartedAt,
      completedAt: parsedCompletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOffer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          offer == other.offer &&
          status == other.status &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      offer.hashCode ^
      status.hashCode ^
      startedAt.hashCode ^
      completedAt.hashCode;
}

class OffersState {
  final List<Offer> allOffers;
  final List<UserOffer> myOffers;
  final bool isLoading;
  final String? error;

  OffersState({
    this.allOffers = const [],
    this.myOffers = const [],
    this.isLoading = false,
    this.error,
  });

  OffersState copyWith({
    List<Offer>? allOffers,
    List<UserOffer>? myOffers,
    bool? isLoading,
    String? error,
  }) {
    return OffersState(
      allOffers: allOffers ?? this.allOffers,
      myOffers: myOffers ?? this.myOffers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Filter getters for Screen 17 tabs
  List<UserOffer> get activeOffers => myOffers.where((o) => o.status == 'STARTED').toList();
  List<UserOffer> get completedOffers => myOffers.where((o) => o.status == 'REWARDED').toList();
  List<UserOffer> get expiredOffers => myOffers.where((o) => o.status == 'EXPIRED').toList();

  // Featured = Watch-to-Earn offers
  List<Offer> get featuredOffers => allOffers.where((o) => o.type == OfferType.watchToEarn).toList();
  List<Offer> get sponsorOffers => allOffers.where((o) => o.type != OfferType.watchToEarn).toList();
}

class OffersNotifier extends StateNotifier<OffersState> {
  final ApiService _apiService;

  OffersNotifier(this._apiService) : super(OffersState()) {
    loadOffers();
  }

  Future<void> loadOffers() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        _apiService.get('/offers'),
        _apiService.get('/offers/my'),
      ]);

      final allOffers = (results[0].data as List)
          .map((json) => Offer.fromJson(json))
          .toList();
      final myOffers = (results[1].data as List)
          .map((json) => UserOffer.fromJson(json))
          .toList();

      state = state.copyWith(
        allOffers: allOffers,
        myOffers: myOffers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiError.from(e).message);
    }
  }

  Future<void> startOffer(String offerId) async {
    try {
      await _apiService.post('/offers/$offerId/start');
      await loadOffers();
    } catch (e) {
      state = state.copyWith(error: ApiError.from(e).message);
    }
  }

  Future<int> completeOffer(String offerId) async {
    try {
      final response = await _apiService.post('/offers/$offerId/complete');
      await loadOffers();
      return response.data['rewarded'] ?? 0;
    } catch (e) {
      state = state.copyWith(error: ApiError.from(e).message);
      return 0;
    }
  }
  
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final offersProvider = StateNotifierProvider.autoDispose<OffersNotifier, OffersState>((ref) {
  return OffersNotifier(ref.watch(apiServiceProvider));
});
