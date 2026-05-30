import 'package:flutter/foundation.dart';

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
  final String source;

  const Activity({
    required this.id,
    required this.type,
    required this.startTime,
    required this.duration,
    required this.caloriesBurned,
    this.distanceKm = 0,
    required this.pointsEarned,
    this.source = 'manual',
  });

  bool get isVerified => source == 'google_fit' || source == 'apple_health';

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      startTime: _parseDate(json['startTime'] as String?),
      duration: Duration(minutes: json['durationMinutes'] as int? ?? 0),
      caloriesBurned: _parseDouble(json['caloriesBurned']),
      distanceKm: _parseDouble(json['distanceKm']),
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      source: json['source'] as String? ?? 'manual',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static ActivityType _parseType(String? typeStr) {
    if (typeStr == null) return ActivityType.walking;
    switch (typeStr.toLowerCase()) {
      case 'walking':
        return ActivityType.walking;
      case 'running':
        return ActivityType.running;
      case 'cycling':
        return ActivityType.cycling;
      case 'yoga':
        return ActivityType.yoga;
      case 'swimming':
        return ActivityType.swimming;
      case 'gym':
        return ActivityType.gym;
      case 'hiking':
        return ActivityType.hiking;
      default:
        return ActivityType.walking;
    }
  }

  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint('ActivityModel: Failed to parse date "$dateStr": $e');
      return DateTime.now();
    }
  }

  // Multiplier logic: 1 min of activity = X points
  static double getPointsMultiplier(ActivityType type) {
    switch (type) {
      case ActivityType.walking:
        return 1.5;
      case ActivityType.yoga:
        return 1.0;
      case ActivityType.cycling:
        return 2.5;
      case ActivityType.gym:
        return 2.5;
      case ActivityType.hiking:
        return 2.0;
      case ActivityType.swimming:
        return 3.0;
      case ActivityType.running:
        return 3.0;
    }
  }

  // Allow immutability
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Activity &&
      other.id == id &&
      other.type == type &&
      other.startTime == startTime &&
      other.duration == duration &&
      other.caloriesBurned == caloriesBurned &&
      other.distanceKm == distanceKm &&
      other.pointsEarned == pointsEarned &&
      other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      startTime,
      duration,
      caloriesBurned,
      distanceKm,
      pointsEarned,
      source,
    );
  }
}
