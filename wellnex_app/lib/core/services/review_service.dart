import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  static const String _lastReviewRequestKey = 'last_review_request_date';

  Future<void> requestReviewIfAppropriate() async {
    try {
      if (await _inAppReview.isAvailable()) {
        final shouldRequest = await _shouldRequestReview();
        if (shouldRequest) {
          await _inAppReview.requestReview();
          await _updateLastRequestDate();
        }
      }
    } catch (e) {
      // Ignore errors silently
    }
  }

  Future<bool> _shouldRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequestTs = prefs.getInt(_lastReviewRequestKey);
    
    if (lastRequestTs == null) {
      // First time? Maybe wait a bit longer, but for now allow it.
      return true;
    }

    final lastRequestDate = DateTime.fromMillisecondsSinceEpoch(lastRequestTs);
    final daysSince = DateTime.now().difference(lastRequestDate).inDays;
    
    // Don't ask more than once every 30 days
    return daysSince >= 30;
  }

  Future<void> _updateLastRequestDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReviewRequestKey, DateTime.now().millisecondsSinceEpoch);
  }
}

final reviewServiceProvider = ReviewService();
