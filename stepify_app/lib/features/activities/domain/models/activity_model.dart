enum ActivityType {
  walking,
  running,
  cycling,
  yoga,
  swimming,
  gym,
  hiking,
}

class Activity {
  final String id;
  final ActivityType type;
  final DateTime startTime;
  final Duration duration;
  final double caloriesBurned;
  final double distanceKm; // 0 for non-distance activities
  final int pointsEarned;

  Activity({
    required this.id,
    required this.type,
    required this.startTime,
    required this.duration,
    required this.caloriesBurned,
    this.distanceKm = 0,
    required this.pointsEarned,
  });

  String get name {
    switch (type) {
      case ActivityType.walking: return 'Walking';
      case ActivityType.running: return 'Running';
      case ActivityType.cycling: return 'Cycling';
      case ActivityType.yoga: return 'Yoga';
      case ActivityType.swimming: return 'Swimming';
      case ActivityType.gym: return 'Gym Workout';
      case ActivityType.hiking: return 'Hiking';
    }
  }

  // Multiplier logic: 1 min of activity = X points
  static double getPointsMultiplier(ActivityType type) {
    switch (type) {
      case ActivityType.walking: return 1.0;
      case ActivityType.yoga: return 1.5; // Harder
      case ActivityType.cycling: return 2.0;
      case ActivityType.gym: return 2.5;
      case ActivityType.hiking: return 2.5;
      case ActivityType.swimming: return 3.0; // High effort
      case ActivityType.running: return 3.0;
    }
  }
}
