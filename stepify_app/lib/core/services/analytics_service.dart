class AnalyticsService {
  FirebaseAnalytics? _analytics;

  FirebaseAnalytics? get analytics {
    if (_analytics == null) {
      // Only access instance if we know we are initialized or platform is correct.
      // But simpler: just catching the error or relying on main.dart to init core.
      // Better: Don't access .instance at all if not mobile.
      try {
        _analytics = FirebaseAnalytics.instance;
      } catch (e) {
        // Ignored
      }
    }
    return _analytics;
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('Analytics: Logged $name');
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> setUserId(String? id) async {
    try {
      await analytics?.setUserId(id: id);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }

  Future<void> setCurrentScreen(String screenName) async {
    try {
      await analytics?.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics Error: $e');
    }
  }
}

final analyticsServiceProvider = AnalyticsService();
