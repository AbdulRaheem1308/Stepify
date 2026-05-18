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

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ApiService _api; // For future backend sync

  ActivityNotifier(this._api) : super(ActivityState()) {
    _loadMockData();
  }

  void _loadMockData() {
    // Generate some fake history
    state = state.copyWith(recentActivities: [
      Activity(
        id: '1',
        type: ActivityType.running,
        startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        duration: const Duration(minutes: 30),
        caloriesBurned: 300,
        distanceKm: 5.0,
        pointsEarned: 90, // 30 * 3
      ),
      Activity(
        id: '2',
        type: ActivityType.yoga,
        startTime: DateTime.now().subtract(const Duration(days: 2, hours: 14)),
        duration: const Duration(minutes: 45),
        caloriesBurned: 150,
        pointsEarned: 67, // 45 * 1.5
      ),
    ]);
  }
  
  Future<void> logActivity({
    required ActivityType type,
    required Duration duration,
    double? distanceKm,
  }) async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Calculate Stats
    final multiplier = Activity.getPointsMultiplier(type);
    final points = (duration.inMinutes * multiplier).toInt();
    
    // Rough calorie estimation (METs logic simplified)
    // Running ~10 kcal/min, Walking ~4, Yoga ~3
    double calsPerMin = 5;
    if (type == ActivityType.running || type == ActivityType.swimming) calsPerMin = 10;
    if (type == ActivityType.cycling || type == ActivityType.gym) calsPerMin = 7;
    if (type == ActivityType.yoga) calsPerMin = 3;
    
    final calories = duration.inMinutes * calsPerMin;

    final newActivity = Activity(
      id: DateTime.now().toIso8601String(),
      type: type,
      startTime: DateTime.now(),
      duration: duration,
      caloriesBurned: calories,
      distanceKm: distanceKm ?? 0,
      pointsEarned: points,
    );
    
    // Prepend to list
    state = state.copyWith(
      recentActivities: [newActivity, ...state.recentActivities],
      isLoading: false,
    );
  }
}

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier(ref.read(apiServiceProvider));
});
