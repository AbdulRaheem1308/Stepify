/// App-wide constants
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  
  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.2:3000/api/v1',
  );
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  
  // Step Tracking
  static const int defaultDailyGoal = 10000;
  static const double caloriesPerStep = 0.04;
  static const double kmPerStep = 0.000762;
  
  // Rewards
  static const double pointsPerStep = 0.1;
  static const int adRewardPoints = 10;
  static const int adCooldownMinutes = 5;
  
  // Streak Milestones
  static const Map<int, int> streakBonuses = {
    7: 50,
    30: 200,
    100: 500,
    365: 2000,
  };
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // AdMob (Test IDs - Replace in production)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Check Helper
  static void checkProductionConfig() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      if (bannerAdUnitId.contains('3940256099942544') || // Google Test Account ID
          interstitialAdUnitId.contains('3940256099942544') ||
          rewardedAdUnitId.contains('3940256099942544')) {
        debugPrint('⚠️ CRITICAL WARNING: Using AdMob Test Unit IDs in PRODUCTION build!');
      }
      
      if (apiBaseUrl.contains('localhost')) {
         debugPrint('⚠️ CRITICAL WARNING: API URL set to localhost in PRODUCTION build! Real devices cannot connect to localhost.');
      }
    }
  }
}
