import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/activities/domain/models/activity_model.dart';

void main() {
  group('ActivityModel', () {
    test('fromJson parses correctly with valid data', () {
      final json = {
        'id': 'activity_1',
        'type': 'running',
        'startTime': '2024-01-01T10:00:00Z',
        'durationMinutes': 30,
        'caloriesBurned': 300.5,
        'distanceKm': 5.2,
        'pointsEarned': 90,
      };

      final activity = Activity.fromJson(json);

      expect(activity.id, 'activity_1');
      expect(activity.type, ActivityType.running);
      expect(activity.startTime, DateTime.parse('2024-01-01T10:00:00Z'));
      expect(activity.duration, const Duration(minutes: 30));
      expect(activity.caloriesBurned, 300.5);
      expect(activity.distanceKm, 5.2);
      expect(activity.pointsEarned, 90);
    });

    test('fromJson handles nulls and missing fields gracefully', () {
      final json = <String, dynamic>{};

      final activity = Activity.fromJson(json);

      expect(activity.id, '');
      expect(activity.type, ActivityType.walking); // Default
      // Should not throw on date, will be approx DateTime.now()
      expect(activity.startTime.year, DateTime.now().year);
      expect(activity.duration, const Duration(minutes: 0));
      expect(activity.caloriesBurned, 0.0);
      expect(activity.distanceKm, 0.0);
      expect(activity.pointsEarned, 0);
    });

    test('fromJson parses types ignoring case', () {
      final json = {'type': 'YOGA'};
      final activity = Activity.fromJson(json);
      expect(activity.type, ActivityType.yoga);
    });

    test('fromJson handles string integers and string floats', () {
      final json = {
        'caloriesBurned': '150',
        'distanceKm': '2.5',
      };
      final activity = Activity.fromJson(json);
      expect(activity.caloriesBurned, 150.0);
      expect(activity.distanceKm, 2.5);
    });

    test('getPointsMultiplier returns correct values', () {
      expect(Activity.getPointsMultiplier(ActivityType.walking), 1.0);
      expect(Activity.getPointsMultiplier(ActivityType.yoga), 1.5);
      expect(Activity.getPointsMultiplier(ActivityType.cycling), 2.0);
      expect(Activity.getPointsMultiplier(ActivityType.gym), 2.5);
      expect(Activity.getPointsMultiplier(ActivityType.hiking), 2.5);
      expect(Activity.getPointsMultiplier(ActivityType.swimming), 3.0);
      expect(Activity.getPointsMultiplier(ActivityType.running), 3.0);
    });

    test('equality and hashCode work properly', () {
      final a1 = Activity(
        id: '1',
        type: ActivityType.walking,
        startTime: DateTime(2024),
        duration: const Duration(minutes: 30),
        caloriesBurned: 100,
        pointsEarned: 30,
      );
      final a2 = Activity(
        id: '1',
        type: ActivityType.walking,
        startTime: DateTime(2024),
        duration: const Duration(minutes: 30),
        caloriesBurned: 100,
        pointsEarned: 30,
      );
      final a3 = Activity(
        id: '2',
        type: ActivityType.walking,
        startTime: DateTime(2024),
        duration: const Duration(minutes: 30),
        caloriesBurned: 100,
        pointsEarned: 30,
      );

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1, isNot(equals(a3)));
    });
  });
}
