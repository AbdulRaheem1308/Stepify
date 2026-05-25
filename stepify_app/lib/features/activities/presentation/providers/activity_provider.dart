import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';
import '../../domain/models/activity_model.dart';

class ActivityState {
  final List<Activity> recentActivities;
  final bool isLoading;

  const ActivityState({this.recentActivities = const [], this.isLoading = false});
  
  ActivityState copyWith({List<Activity>? recentActivities, bool? isLoading}) {
    return ActivityState(
      recentActivities: recentActivities ?? this.recentActivities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ApiService _api;

  // Security constants for activity validation
  static const int _maxDurationMinutes = 300;  // 5 hours max per session
  static const int _minDurationMinutes = 1;    // at least 1 minute
  static const int _maxPointsPerSession = 900; // 300 min * 3.0 max multiplier

  ActivityNotifier(this._api) : super(const ActivityState());

  /// Fetch real activity history from backend
  Future<void> fetchActivities() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.get('/activities');
      final list = (response.data as List)
          .map<Activity>((e) => Activity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      state = state.copyWith(recentActivities: list, isLoading: false);
    } catch (e) {
      // On failure, keep previous list but stop loading.
      // In a more complex app, we might store the error string in the state.
      state = state.copyWith(isLoading: false);
    }
  }
  
  /// Logs an activity to the backend. Returns an error message if failed, or null on success.
  Future<String?> logActivity({
    required ActivityType type,
    required Duration duration,
    double? distanceKm,
    String? source,
  }) async {
    // ── Security validation ──────────────────────────────────────────────
    if (duration.inMinutes < _minDurationMinutes) {
      return 'Duration must be at least $_minDurationMinutes minute.';
    }
    if (duration.inMinutes > _maxDurationMinutes) {
      return 'Duration cannot exceed $_maxDurationMinutes minutes (5 hours) per session.';
    }
    
    // Distance sanity: max realistic distance per activity type
    if (distanceKm != null) {
      final maxKm = _maxDistanceKm(type, duration.inMinutes);
      if (distanceKm > maxKm) {
        return 'Distance entered ($distanceKm km) is unrealistic for ${duration.inMinutes} minutes of ${type.name}.';
      }
    }
    // ────────────────────────────────────────────────────────────────────

    state = state.copyWith(isLoading: true);

    final multiplier = Activity.getPointsMultiplier(type);
    final rawPoints = (duration.inMinutes * multiplier).toInt();
    final points = rawPoints.clamp(0, _maxPointsPerSession);
    final calories = _calculateCalories(type, duration.inMinutes);

    try {
      // POST to backend — backend is the source of truth for points and ID
      final response = await _api.post('/activities', data: {
        'type': type.name,
        'durationMinutes': duration.inMinutes,
        'distanceKm': distanceKm ?? 0,
        'caloriesBurned': calories,
        'startTime': DateTime.now().toUtc().toIso8601String(),
        'source': source ?? 'manual',
      });
      
      // If the backend returns the newly created activity, we use it.
      // Otherwise we fall back to a local representation.
      Activity newActivity;
      if (response.data != null && response.data is Map) {
        newActivity = Activity.fromJson(Map<String, dynamic>.from(response.data as Map));
      } else {
        newActivity = Activity(
          id: DateTime.now().toIso8601String(),
          type: type,
          startTime: DateTime.now(),
          duration: duration,
          caloriesBurned: calories,
          distanceKm: distanceKm ?? 0,
          pointsEarned: points,
          source: source ?? 'manual',
        );
      }

      state = state.copyWith(
        recentActivities: [newActivity, ...state.recentActivities],
        isLoading: false,
      );
      return null; // Success
    } catch (e) {
      state = state.copyWith(isLoading: false);
      final apiError = ApiError.from(e);
      return apiError.message;
    }
  }

  double _calculateCalories(ActivityType type, int minutes) {
    double calsPerMin = 5;
    if (type == ActivityType.running || type == ActivityType.swimming) calsPerMin = 10;
    if (type == ActivityType.cycling || type == ActivityType.gym) calsPerMin = 7;
    if (type == ActivityType.yoga) calsPerMin = 3;
    return minutes * calsPerMin;
  }

  /// Max realistic distance (km) for given activity type and duration
  double _maxDistanceKm(ActivityType type, int minutes) {
    switch (type) {
      case ActivityType.running:  return minutes * 0.35; // ~21 km/h elite
      case ActivityType.cycling:  return minutes * 0.9;  // ~54 km/h sprint
      case ActivityType.walking:  return minutes * 0.12; // ~7.2 km/h fast walk
      case ActivityType.hiking:   return minutes * 0.1;
      case ActivityType.swimming: return minutes * 0.05; // ~3 km/h
      default:                    return double.infinity;
    }
  }
}

final activityProvider = StateNotifierProvider.autoDispose<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(ref.read(apiServiceProvider));
});
