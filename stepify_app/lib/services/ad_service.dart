import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/remote_config_service.dart';

class AdService {
  final RemoteConfigService _remoteConfigService;
  
  AdService(this._remoteConfigService);

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  
  // Track loaded native ads
  final Map<String, NativeAd> _nativeAds = {};

  // Check if Ads are supported (Android/iOS only, not Web)
  bool get _isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (!_isSupported) return;
    try {
      await MobileAds.instance.initialize();
      _loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob Init Failed: $e');
    }
  }

  // Banner Ad Unit ID
  String get bannerAdUnitId {
    if (!_isSupported) return '';
    
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-xxxxxxxxxxxxxxxx/1111111111'
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/2222222222';
  }

  // Interstitial Ad Unit ID
  String get interstitialAdUnitId {
    if (!_isSupported) return '';

    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-xxxxxxxxxxxxxxxx/3333333333'
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/4444444444'; 
  }

  // Rewarded Ad Unit ID
  String get rewardedAdUnitId {
    if (!_isSupported) return '';

    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-xxxxxxxxxxxxxxxx/5555555555'
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/6666666666';
  }

  // Native Ad Unit ID
  String get nativeAdUnitId {
    if (!_isSupported) return '';

    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-3940256099942544/2247696110' // Android native advanced test ID
          : 'ca-app-pub-3940256099942544/3986624511'; // iOS native advanced test ID
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-xxxxxxxxxxxxxxxx/7777777777'
        : 'ca-app-pub-xxxxxxxxxxxxxxxx/8888888888';
  }

  // Create Banner Ad
  BannerAd? createBannerAd() {
    if (!_isSupported) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('Banner Ad loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner Ad failed to load: $error');
        },
      ),
    );
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    if (!_isSupported) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('Interstitial Ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Check if Rewarded Ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady && _rewardedAd != null;

  // Load Rewarded Ad
  void loadRewardedAd() {
    if (!_isSupported) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('Rewarded Ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next one
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // Show Rewarded Ad
  void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    required VoidCallback onAdFailedToShow,
  }) {
    if (!_isSupported || !_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('Rewarded ad not ready, calling fallback');
      onAdFailedToShow();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onUserEarnedReward(reward);
      },
    );
  }

  DateTime? _lastAdTime;
  
  // Dynamic Interval from Remote Config
  Duration get _minAdInterval => Duration(seconds: _remoteConfigService.interstitialAdIntervalSeconds);

  // Show Interstitial Ad (e.g. after workout)
  void showInterstitialAd() {
    if (!_isSupported) return;

    final now = DateTime.now();
    
    // Frequency Capping: Don't show if last ad was less than 2 mins ago
    if (_lastAdTime != null && now.difference(_lastAdTime!) < _minAdInterval) {
      debugPrint('Ad suppressed by frequency cap');
      return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _lastAdTime = now;
    } else {
      debugPrint('Interstitial not ready yet');
      // Optionally load it now if it failed earlier
      if (!_isInterstitialAdReady) _loadInterstitialAd();
    }
  }

  // Load a Native Ad
  Future<NativeAd?> loadNativeAd({required String factoryId}) async {
    if (!_isSupported) return null;
    
    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: factoryId, // Needs to be configured in MainActivity.java / AppDelegate.swift
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('Native Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
    
    await nativeAd.load();
    return nativeAd;
  }
  
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    for (final ad in _nativeAds.values) {
      ad.dispose();
    }
    _nativeAds.clear();
  }
}

final adServiceProvider = Provider<AdService>((ref) {
  return AdService(remoteConfigServiceProvider);
});
