import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';

/// Direct hardware pedometer service using the phone's built-in step sensor.
///
/// Tracks cumulative sensor steps since boot, stores a per-day baseline in
/// [StorageService], and emits the computed "steps today" count to callers.
///
/// This is a singleton — use the factory constructor `PedometerService()`.
class PedometerService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  final Pedometer _pedometer = Pedometer();
  @visibleForTesting
  Stream<int>? mockStepCountStream;
  StreamSubscription<int>? _subscription;

  void Function(int stepsToday)? _onStepsChanged;
  void Function(String error)? _onErrorOccurred;

  bool _isListening = false;

  /// Whether the pedometer stream is currently active.
  bool get isListening => _isListening;

  // Hive storage keys
  static const String _savedStepsTodayKey = 'pedometer_saved_steps_today';
  static const String _lastDateKey = 'pedometer_last_sync_date';
  static const String _lastSensorStepsKey = 'pedometer_last_sensor_steps';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts listening to the hardware step counter.
  ///
  /// [onStepsChanged] receives the computed "steps today" count on every
  /// sensor event.  [onErrorOccurred] is called with a human-readable message
  /// on errors.
  ///
  /// Calling this again while already listening updates the callbacks without
  /// restarting the stream.
  Future<void> startListening({
    required void Function(int stepsToday) onStepsChanged,
    void Function(String error)? onErrorOccurred,
  }) async {
    _onStepsChanged = onStepsChanged;
    _onErrorOccurred = onErrorOccurred;

    if (_isListening) return;

    // Request activity recognition on Android (no-op on iOS).
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestActivityPermission();
    }

    try {
      final stream = mockStepCountStream ?? _pedometer.stepCountStream();
      _subscription = stream.listen(
        _onStepCountEvent,
        onError: _onStepCountError,
        cancelOnError: false,
      );
      _isListening = true;
    } catch (e) {
      debugPrint('PedometerService: Failed to start stream: $e');
      _onErrorOccurred?.call('Sensor stream error: $e');
    }
  }

  /// Stops the sensor stream subscription.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Retrieves a single point-in-time "steps today" count. 
  /// Useful for background isolate/WorkManager jobs where we don't want to keep a stream open forever.
  Future<int> getCurrentSteps() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _requestActivityPermission();
    }

    // Await the very first event from the hardware step stream (with timeout)
    try {
      final stream = mockStepCountStream ?? _pedometer.stepCountStream();
      final sensorSteps = await stream.first.timeout(const Duration(seconds: 2));
      
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final lastSyncDate = StorageService.get<String>(_lastDateKey) ?? '';
      
      int savedStepsToday = StorageService.get<int>(_savedStepsTodayKey) ?? 0;
      int lastSensorSteps = StorageService.get<int>(_lastSensorStepsKey) ?? -1;

      if (lastSyncDate != todayStr) {
        savedStepsToday = 0;
        lastSensorSteps = sensorSteps;
        await StorageService.put(_lastDateKey, todayStr);
      }

      if (lastSensorSteps == -1) {
        lastSensorSteps = sensorSteps;
      }

      int delta = sensorSteps - lastSensorSteps;
      if (delta < 0) {
        delta = sensorSteps;
      }

      savedStepsToday += delta;
      lastSensorSteps = sensorSteps;

      await StorageService.put(_savedStepsTodayKey, savedStepsToday);
      await StorageService.put(_lastSensorStepsKey, lastSensorSteps);

      return savedStepsToday;
    } catch (e) {
      debugPrint('PedometerService: Failed to get current steps: $e');
      
      // Fallback: Try to use the last known cumulative sensor steps from today
      try {
        final savedStepsToday = StorageService.get<int>(_savedStepsTodayKey);
        if (savedStepsToday != null && savedStepsToday > 0) {
          final todayStr = DateTime.now().toIso8601String().split('T')[0];
          final lastSyncDate = StorageService.get<String>(_lastDateKey) ?? '';
          
          if (lastSyncDate == todayStr) {
            debugPrint('PedometerService: Using saved steps fallback: $savedStepsToday');
            return savedStepsToday;
          }
        }
      } catch (fallbackErr) {
        debugPrint('PedometerService: Fallback lookup error: $fallbackErr');
      }

      return 0; // Fallback to 0 if sensor fails (e.g. permission denied or no hardware sensor)
    }
  }

  // ── Permission ─────────────────────────────────────────────────────────────

  Future<void> _requestActivityPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
    } catch (_) {
      // Retry once if a concurrent request interfered.
      try {
        await Future<void>.delayed(const Duration(seconds: 1));
        final status = await Permission.activityRecognition.request();
      } catch (retryError) {
        debugPrint('PedometerService: Permission request error: $retryError');
        _onErrorOccurred?.call('Permission error: $retryError');
      }
    }
  }

  // ── Step Processing ────────────────────────────────────────────────────────

  /// Processes a raw cumulative step count from the hardware sensor.
  ///
  /// Computes "steps today" by subtracting a stored daily baseline from the
  /// raw cumulative count.  Resets the baseline at midnight or on device
  /// reboot (when cumulative count drops below the stored baseline).
  Future<void> _onStepCountEvent(int sensorSteps) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final lastSyncDate = StorageService.get<String>(_lastDateKey) ?? '';
    
    int savedStepsToday = StorageService.get<int>(_savedStepsTodayKey) ?? 0;
    int lastSensorSteps = StorageService.get<int>(_lastSensorStepsKey) ?? -1;

    // New day reset
    if (lastSyncDate != todayStr) {
      savedStepsToday = 0;
      lastSensorSteps = sensorSteps;
      await StorageService.put(_lastDateKey, todayStr);
      debugPrint('PedometerService: New day reset for $todayStr');
    }

    if (lastSensorSteps == -1) {
      lastSensorSteps = sensorSteps;
    }

    int delta = sensorSteps - lastSensorSteps;

    // Handle device reboot or sensor tracking resets
    if (delta < 0) {
      debugPrint('PedometerService: Sensor reset detected! Old: $lastSensorSteps, New: $sensorSteps');
      delta = sensorSteps; // Assume sensor restarted from 0
    }

    savedStepsToday += delta;
    lastSensorSteps = sensorSteps;

    await StorageService.put(_savedStepsTodayKey, savedStepsToday);
    await StorageService.put(_lastSensorStepsKey, lastSensorSteps);

    _onStepsChanged?.call(savedStepsToday);
  }

  void _onStepCountError(dynamic error) {
    debugPrint('PedometerService: Hardware sensor error: $error');
    _onErrorOccurred?.call('Hardware error: $error');
  }
}
