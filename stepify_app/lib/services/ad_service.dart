import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/remote_config_service.dart';

/// AdMob service handling Banner, Interstitial, Rewarded, and Native ads.
///
/// Ad IDs are selected at runtime based on build mode and platform.
/// Production IDs must be set via environment config before release.
class AdService {
  final RemoteConfigService _remoteConfigService;

  AdService(this._remoteConfigService);

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Loaded native ads keyed by factoryId
  final Map<String, NativeAd> _nativeAds = {};

  // Retry backoff state
  int _interstitialRetryAttempt = 0;
  int _rewardedRetryAttempt = 0;
  static const int _maxRetryAttempts = 5;

  /// Whether Google Mobile Ads is supported on the current platform.
  bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Initialise the AdMob SDK and pre-load ads.
  Future<void> initialize() async {
    if (!_isSupported) return;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdService: AdMob init failed: $e');
    }
  }

  // ── Ad Unit IDs ─────────────────────────────────────────────────────────────

  /// Banner ad unit ID. Uses Google test IDs in debug mode.
  String get bannerAdUnitId {
    if (!_isSupported) return '';
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    // TODO(release): Replace with your production Ad Unit IDs from AdMob console.
    return defaultTargetPlatform == TargetPlatform.android
        ? const String.fromEnvironment('BANNER_AD_UNIT_ANDROID',
            defaultValue: 'ca-app-pub-REPLACE_ME/BANNER_ANDROID')
        : const String.fromEnvironment('BANNER_AD_UNIT_IOS',
            defaultValue: 'ca-app-pub-REPLACE_ME/BANNER_IOS');
  }

  /// Interstitial ad unit ID.
  String get interstitialAdUnitId {
    if (!_isSupported) return '';
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    // TODO(release): Replace with your production Ad Unit IDs from AdMob console.
    return defaultTargetPlatform == TargetPlatform.android
        ? const String.fromEnvironment('INTERSTITIAL_AD_UNIT_ANDROID',
            defaultValue: 'ca-app-pub-REPLACE_ME/INTERSTITIAL_ANDROID')
        : const String.fromEnvironment('INTERSTITIAL_AD_UNIT_IOS',
            defaultValue: 'ca-app-pub-REPLACE_ME/INTERSTITIAL_IOS');
  }

  /// Rewarded ad unit ID.
  String get rewardedAdUnitId {
    if (!_isSupported) return '';
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    // TODO(release): Replace with your production Ad Unit IDs from AdMob console.
    return defaultTargetPlatform == TargetPlatform.android
        ? const String.fromEnvironment('REWARDED_AD_UNIT_ANDROID',
            defaultValue: 'ca-app-pub-REPLACE_ME/REWARDED_ANDROID')
        : const String.fromEnvironment('REWARDED_AD_UNIT_IOS',
            defaultValue: 'ca-app-pub-REPLACE_ME/REWARDED_IOS');
  }

  /// Native ad unit ID.
  String get nativeAdUnitId {
    if (!_isSupported) return '';
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
    // TODO(release): Replace with your production Ad Unit IDs from AdMob console.
    return defaultTargetPlatform == TargetPlatform.android
        ? const String.fromEnvironment('NATIVE_AD_UNIT_ANDROID',
            defaultValue: 'ca-app-pub-REPLACE_ME/NATIVE_ANDROID')
        : const String.fromEnvironment('NATIVE_AD_UNIT_IOS',
            defaultValue: 'ca-app-pub-REPLACE_ME/NATIVE_IOS');
  }

  // ── Banner ──────────────────────────────────────────────────────────────────

  /// Creates and returns a [BannerAd] ready to be loaded by the caller.
  BannerAd? createBannerAd() {
    if (!_isSupported) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('AdService: Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdService: Banner failed to load: $error');
        },
      ),
    );
  }

  // ── Interstitial ─────────────────────────────────────────────────────────────

  void _loadInterstitialAd() {
    if (!_isSupported) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _interstitialRetryAttempt = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial failed to load: $error');
          _isInterstitialAdReady = false;
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    if (_interstitialRetryAttempt >= _maxRetryAttempts) return;
    _interstitialRetryAttempt++;
    final delay = Duration(seconds: (1 << _interstitialRetryAttempt).clamp(1, 64));
    Future.delayed(delay, _loadInterstitialAd);
  }

  // ── Rewarded ─────────────────────────────────────────────────────────────────

  /// Whether a rewarded ad is loaded and ready to show.
  bool get isRewardedAdReady => _isRewardedAdReady && _rewardedAd != null;

  void loadRewardedAd() {
    if (!_isSupported) return;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _rewardedRetryAttempt = 0;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
          _scheduleRewardedRetry();
        },
      ),
    );
  }

  void _scheduleRewardedRetry() {
    if (_rewardedRetryAttempt >= _maxRetryAttempts) return;
    _rewardedRetryAttempt++;
    final delay = Duration(seconds: (1 << _rewardedRetryAttempt).clamp(1, 64));
    Future.delayed(delay, loadRewardedAd);
  }

  /// Shows a rewarded ad. Calls [onUserEarnedReward] on success, or
  /// [onAdFailedToShow] if the ad is not ready.
  void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    required VoidCallback onAdFailedToShow,
  }) {
    if (!_isSupported || !isRewardedAdReady) {
      onAdFailedToShow();
      return;
    }
    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) => onUserEarnedReward(reward),
    );
  }

  // ── Interstitial Show ────────────────────────────────────────────────────────

  DateTime? _lastAdTime;

  Duration get _minAdInterval =>
      Duration(seconds: _remoteConfigService.interstitialAdIntervalSeconds);

  /// Shows the interstitial ad if ready and frequency cap allows.
  void showInterstitialAd() {
    if (!_isSupported) return;
    final now = DateTime.now();
    if (_lastAdTime != null && now.difference(_lastAdTime!) < _minAdInterval) {
      return;
    }
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _lastAdTime = now;
    } else {
      if (!_isInterstitialAdReady) _loadInterstitialAd();
    }
  }

  // ── Native ────────────────────────────────────────────────────────────────────

  /// Loads a native ad with the given [factoryId].
  ///
  /// The factory must be registered in `MainActivity.kt` / `AppDelegate.swift`.
  /// Previously loaded ads with the same factoryId are disposed before reloading.
  Future<NativeAd?> loadNativeAd({required String factoryId}) async {
    if (!_isSupported) return null;

    // Dispose previous ad for this factoryId to prevent leaks
    _nativeAds[factoryId]?.dispose();
    _nativeAds.remove(factoryId);

    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeAds[factoryId] = ad as NativeAd;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Native ad failed ($factoryId): $error');
          ad.dispose();
        },
      ),
    );

    await nativeAd.load();
    return nativeAd;
  }

  /// Dispose all loaded ads. Call when the service is no longer needed.
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    for (final ad in _nativeAds.values) {
      ad.dispose();
    }
    _nativeAds.clear();
  }
}

/// Riverpod provider for [AdService].
final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService(remoteConfigServiceProvider);
  ref.onDispose(service.dispose);
  return service;
});

