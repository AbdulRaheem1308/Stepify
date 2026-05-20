import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Extended Location Service — country detection + continuous GPS route tracking
class LocationService {
  // ─── Singleton ──────────────────────────────────────────────────────────────
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _routePoints = [];
  bool _isTracking = false;

  List<Position> get routePoints => List.unmodifiable(_routePoints);
  bool get isTracking => _isTracking;

  /// Total distance walked in the current route session (metres)
  double get totalDistanceMetres {
    if (_routePoints.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < _routePoints.length; i++) {
      total += Geolocator.distanceBetween(
        _routePoints[i - 1].latitude,
        _routePoints[i - 1].longitude,
        _routePoints[i].latitude,
        _routePoints[i].longitude,
      );
    }
    return total;
  }

  // ─── Permission Helper ──────────────────────────────────────────────────────

  /// Ensures location permission is granted. Returns true if ready to use.
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // ─── Country Detection ──────────────────────────────────────────────────────

  /// Returns the ISO country code of the device's current location (e.g. 'IN', 'US').
  static Future<String?> getCurrentCountryCode() async {
    final granted = await ensurePermission();
    if (!granted) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return placemarks.isNotEmpty ? placemarks.first.isoCountryCode : null;
    } catch (e) {
      debugPrint('LocationService.getCurrentCountryCode error: $e');
      return null;
    }
  }

  // ─── Route Tracking ─────────────────────────────────────────────────────────

  /// Start recording GPS route points.
  /// [onUpdate] is called every time a new position arrives.
  Future<bool> startRouteTracking({
    required void Function(Position position) onUpdate,
    void Function(String error)? onError,
  }) async {
    if (_isTracking) return true;

    final granted = await ensurePermission();
    if (!granted) {
      onError?.call('Location permission not granted');
      return false;
    }

    _routePoints.clear();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Emit update only when moved 5+ metres (battery saving)
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (position) {
          _routePoints.add(position);
          onUpdate(position);
        },
        onError: (error) {
          debugPrint('LocationService stream error: $error');
          onError?.call('GPS error: $error');
        },
        cancelOnError: false,
      );
      _isTracking = true;
      debugPrint('🟢 GPS Route Tracking started');
      return true;
    } catch (e) {
      debugPrint('LocationService.startRouteTracking error: $e');
      onError?.call('Failed to start GPS: $e');
      return false;
    }
  }

  /// Stop recording the GPS route.
  void stopRouteTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    debugPrint('🔴 GPS Route Tracking stopped (${_routePoints.length} points recorded)');
  }

  /// Clear saved route points (call before starting a new session).
  void clearRoute() {
    _routePoints.clear();
  }
}
