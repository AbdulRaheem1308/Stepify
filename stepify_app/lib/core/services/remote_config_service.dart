import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  FirebaseRemoteConfig? _remoteConfig;
  static const String _keyInterstitialAdInterval = "interstitial_ad_interval_sec";

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      // Set default values
      await _remoteConfig!.setDefaults({
        _keyInterstitialAdInterval: 120, // Default 2 minutes
      });

      // Fetch and activate
      // In dev, fetch often. In prod, fetch less often (e.g. 1 hour)
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode 
            ? const Duration(minutes: 5) // 5 min in debug
            : const Duration(hours: 12),  // 12 hours in prod
      ));

      await _remoteConfig!.fetchAndActivate();
    } catch (e) {
      debugPrint("Remote Config Init Failed: $e");
    }
  }

  /// Get Interstitial Ad Interval in Seconds
  int get interstitialAdIntervalSeconds {
    if (kIsWeb) return 120;
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) return 120; // Default
    if (_remoteConfig == null) return 120;
    
    try {
      return _remoteConfig!.getInt(_keyInterstitialAdInterval);
    } catch (e) {
      return 120;
    }
  }
}

final remoteConfigServiceProvider = RemoteConfigService();
