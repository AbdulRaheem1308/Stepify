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
  StreamSubscription<int>? _subscription;

  void Function(int stepsToday)? _onStepsChanged;
  void Function(String error)? _onErrorOccurred;

  bool _isListening = false;

  /// Whether the pedometer stream is currently active.
  bool get isListening => _isListening;

  // Hive storage keys
  static const String _baselineKey = 'pedometer_baseline_steps';
  static const String _lastDateKey = 'pedometer_last_sync_date';

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
      _subscription = _pedometer.stepCountStream().listen(
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
    int baseline = StorageService.get<int>(_baselineKey) ?? -1;

    // New day or first run — reset baseline.
    if (lastSyncDate != todayStr || baseline == -1) {
      baseline = sensorSteps;
      await StorageService.put(_baselineKey, baseline);
      await StorageService.put(_lastDateKey, todayStr);
      debugPrint(
          'PedometerService: New baseline = $baseline for $todayStr');
    }

    int stepsToday = sensorSteps - baseline;

    // Handle device reboot (cumulative counter resets to 0 or below baseline).
    if (stepsToday < 0) {
      baseline = sensorSteps;
      await StorageService.put(_baselineKey, baseline);
      stepsToday = 0;
    }

    _onStepsChanged?.call(stepsToday);
  }

  void _onStepCountError(dynamic error) {
    debugPrint('PedometerService: Hardware sensor error: $error');
    _onErrorOccurred?.call('Hardware error: $error');
  }
}
