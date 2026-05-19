import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

/// Direct hardware-level pedometer service using the phone's built-in sensors
class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  final Pedometer _pedometer = Pedometer();
  StreamSubscription<int>? _subscription;
  void Function(int stepsToday)? _onStepsChanged;
  
  bool _isListening = false;
  
  // Storage keys
  static const _baselineKey = 'pedometer_baseline_steps';
  static const _lastDateKey = 'pedometer_last_sync_date';

  /// Initialize and start listening to the physical mobile step counter
  Future<void> startListening({required void Function(int stepsToday) onStepsChanged}) async {
    if (_isListening) {
      _onStepsChanged = onStepsChanged;
      return;
    }

    _onStepsChanged = onStepsChanged;

    // 1. Request Activity Recognition permission (needed for direct sensor reading on Android)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.activityRecognition.request();
      if (status != PermissionStatus.granted) {
        print('Pedometer: Activity Recognition permission denied.');
        return;
      }
    }

    // 2. Begin listening to the physical step counter stream
    try {
      _subscription = _pedometer.stepCountStream().listen(
        _onStepCountEvent,
        onError: _onStepCountError,
        cancelOnError: false,
      );
      _isListening = true;
      print('🟢 Direct Hardware Pedometer Service Listening');
    } catch (e) {
      print('Pedometer: Error starting stream: $e');
    }
  }

  /// Process step count event from the physical mobile sensor
  void _onStepCountEvent(int sensorSteps) {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];
    
    // Load previously stored data
    final lastSyncDate = StorageService.get<String>(_lastDateKey) ?? '';
    int baseline = StorageService.get<int>(_baselineKey) ?? -1;

    // If it's a new day, or no baseline exists yet
    if (lastSyncDate != todayStr || baseline == -1) {
      baseline = sensorSteps;
      StorageService.put(_baselineKey, baseline);
      StorageService.put(_lastDateKey, todayStr);
      print('Pedometer: Resetting daily baseline to $baseline steps for $todayStr');
    }

    // Today's steps = Total cumulative sensor steps - baseline steps at start of day
    int stepsToday = sensorSteps - baseline;
    if (stepsToday < 0) {
      // Handles case where device reboots and cumulative steps resets to 0
      baseline = sensorSteps;
      StorageService.put(_baselineKey, baseline);
      stepsToday = 0;
    }

    if (_onStepsChanged != null) {
      _onStepsChanged!(stepsToday);
    }
  }

  void _onStepCountError(dynamic error) {
    print('Pedometer: Hardware sensor error: $error');
  }

  /// Stop listening to the sensor
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }
}
