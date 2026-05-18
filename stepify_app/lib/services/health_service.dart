import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Service to handle HealthKit (iOS) and Google Fit (Android) integration
class HealthService {
  final Health _health = Health();

  /// Define the types of data we want to request
  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
  ];

  /// Configure authorization permissions
  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  /// Check if health data is available and authorized
  Future<bool> requestAuthorization() async {
    // Check if permission handler says we have access (useful for Android pre-check)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.activityRecognition.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    try {
      // Request access to HealthKit/Google Fit
      bool authorized = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      
      return authorized;
    } catch (e) {
      print('Health authorization error: $e');
      return false;
    }
  }

  /// Fetch today's steps
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    try {
      return await _health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (e) {
      print('Error fetching steps: $e');
      return 0;
    }
  }

  /// Method to get step count history for the last [days]
  Future<Map<DateTime, int>> getStepHistory(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final stepsMap = <DateTime, int>{};

    // We can't get daily aggregates easily with a single call that splits by day 
    // in the unified package easily without manual processing, 
    // so we iterate or fetch all points. 
    // Since Health package doesn't give a "getDailySummary", we fetch the aggregate for each day loop.
    
    for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        
        try {
            final steps = await _health.getTotalStepsInInterval(startOfDay, endOfDay) ?? 0;
             stepsMap[startOfDay] = steps;
        } catch (e) {
            print("Error getting steps for $startOfDay: $e");
        }
    }
    
    return stepsMap;
  }
}
