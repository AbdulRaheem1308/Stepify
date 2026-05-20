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

  factory Activity.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    ActivityType parseType(String typeStr) {
      switch (typeStr.toLowerCase()) {
        case 'walking': return ActivityType.walking;
        case 'running': return ActivityType.running;
        case 'cycling': return ActivityType.cycling;
        case 'yoga': return ActivityType.yoga;
        case 'swimming': return ActivityType.swimming;
        case 'gym': return ActivityType.gym;
        case 'hiking': return ActivityType.hiking;
        default: return ActivityType.walking;
      }
    }

    return Activity(
      id: json['id'] as String? ?? '',
      type: parseType(json['type'] as String? ?? 'walking'),
      startTime: json['startTime'] != null 
          ? DateTime.tryParse(json['startTime'] as String) ?? DateTime.now() 
          : DateTime.now(),
      duration: Duration(minutes: json['durationMinutes'] as int? ?? 0),
      caloriesBurned: parseDouble(json['caloriesBurned']),
      distanceKm: parseDouble(json['distanceKm']),
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }

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

