import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';
import '../../domain/models/activity_model.dart';

class ActivityState {
  final List<Activity> recentActivities;
  final bool isLoading;

  ActivityState({this.recentActivities = const [], this.isLoading = false});
  
  ActivityState copyWith({List<Activity>? recentActivities, bool? isLoading}) {
    return ActivityState(
      recentActivities: recentActivities ?? this.recentActivities,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Security constants for activity validation
const int _kMaxDurationMinutes = 300;  // 5 hours max per session
const int _kMinDurationMinutes = 1;    // at least 1 minute
const int _kMaxPointsPerSession = 900; // 300 min * 3.0 max multiplier

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ApiService _api;

  ActivityNotifier(this._api) : super(ActivityState()) {
    // No mock data loaded in production
  }

  /// Fetch real activity history from backend
  Future<void> fetchActivities() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _api.get('/activities');
      final list = (response.data as List)
          .map<Activity>((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(recentActivities: list, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
  
  Future<String?> logActivity({
    required ActivityType type,
    required Duration duration,
    double? distanceKm,
  }) async {
    // ── Security validation (Fix #1 & #2) ──────────────────────────────
    if (duration.inMinutes < _kMinDurationMinutes) {
      return 'Duration must be at least $_kMinDurationMinutes minute.';
    }
    if (duration.inMinutes > _kMaxDurationMinutes) {
      return 'Duration cannot exceed $_kMaxDurationMinutes minutes (5 hours) per session.';
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

    // Calculate stats server-side formula (client shows preview only)
    final multiplier = Activity.getPointsMultiplier(type);
    // Cap points to prevent overflow — backend must re-validate
    final rawPoints = (duration.inMinutes * multiplier).toInt();
    final points = rawPoints.clamp(0, _kMaxPointsPerSession);

    double calsPerMin = 5;
    if (type == ActivityType.running || type == ActivityType.swimming) calsPerMin = 10;
    if (type == ActivityType.cycling || type == ActivityType.gym) calsPerMin = 7;
    if (type == ActivityType.yoga) calsPerMin = 3;

    final calories = duration.inMinutes * calsPerMin;

    try {
      // POST to backend — backend is the source of truth for points
      await _api.post('/activities', data: {
        'type': type.name,
        'durationMinutes': duration.inMinutes,
        'distanceKm': distanceKm ?? 0,
        'caloriesBurned': calories,
        'startTime': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Fall through: show local optimistic result even if offline
    }

    final newActivity = Activity(
      id: DateTime.now().toIso8601String(),
      type: type,
      startTime: DateTime.now(),
      duration: duration,
      caloriesBurned: calories,
      distanceKm: distanceKm ?? 0,
      pointsEarned: points,
    );

    state = state.copyWith(
      recentActivities: [newActivity, ...state.recentActivities],
      isLoading: false,
    );
    return null; // null = success
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

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(ref.read(apiServiceProvider));
});
