import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Extended location service providing country detection and continuous
/// GPS route tracking.
///
/// This is a singleton — use the factory constructor `LocationService()`.
class LocationService {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  final List<Position> _routePoints = [];
  bool _isTracking = false;

  /// Maximum number of GPS points kept in memory per session.
  ///
  /// Capping prevents unbounded memory growth during very long sessions.
  static const int _maxRoutePoints = 10000;

  /// Accumulated total distance so far — updated incrementally to avoid O(N)
  /// recomputation on every UI rebuild.
  double _accumulatedDistanceMetres = 0.0;

  /// An unmodifiable view of the recorded route positions.
  List<Position> get routePoints => List.unmodifiable(_routePoints);

  /// Whether GPS route tracking is currently active.
  bool get isTracking => _isTracking;

  /// Total distance walked in the current session (metres).
  double get totalDistanceMetres => _accumulatedDistanceMetres;

  // ── Permission Helper ─────────────────────────────────────────────────────

  /// Ensures location permission is granted and the location service is
  /// enabled. Returns `true` when the app can obtain location fixes.
  ///
  /// If the user has permanently denied location access, returns `false`.
  /// Callers should surface guidance to open Settings in that case.
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          'LocationService: Permission permanently denied — '
          'open Settings to grant access.');
      return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // ── Country Detection ─────────────────────────────────────────────────────

  /// Returns the ISO 3166-1 alpha-2 country code for the device's current
  /// position (e.g. `'IN'`, `'US'`), or `null` on failure.
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
      return null;
    }
  }

  // ── Route Tracking ────────────────────────────────────────────────────────

  /// Starts recording GPS route points.
  ///
  /// [onUpdate] fires each time a new position arrives.
  /// [onError] fires when a stream or permission error occurs.
  ///
  /// Returns `true` when tracking was started successfully.
  Future<bool> startRouteTracking({
    required void Function(Position position) onUpdate,
    void Function(String error)? onError,
  }) async {
    if (_isTracking) return true;

    // Check permission BEFORE clearing state so existing data is preserved.
    final granted = await ensurePermission();
    if (!granted) {
      onError?.call('Location permission not granted');
      return false;
    }

    // Safe to reset now.
    _routePoints.clear();
    _accumulatedDistanceMetres = 0.0;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Only emit when device moves ≥ 5 m (battery saving).
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (position) {
          // Incrementally accumulate distance.
          if (_routePoints.isNotEmpty) {
            _accumulatedDistanceMetres += Geolocator.distanceBetween(
              _routePoints.last.latitude,
              _routePoints.last.longitude,
              position.latitude,
              position.longitude,
            );
          }
          // Cap stored points to prevent OOM on very long sessions.
          if (_routePoints.length < _maxRoutePoints) {
            _routePoints.add(position);
          } else {
            debugPrint(
                'LocationService: Route point cap ($_maxRoutePoints) reached');
          }
          onUpdate(position);
        },
        onError: (Object error) {
          debugPrint('LocationService: Stream error: $error');
          onError?.call('GPS error: $error');
        },
        cancelOnError: false,
      );
      _isTracking = true;
      return true;
    } catch (e) {
      onError?.call('Failed to start GPS: $e');
      return false;
    }
  }

  /// Stops recording the GPS route.
  void stopRouteTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    debugPrint(
        'LocationService: 🔴 Tracking stopped — '
        '${_routePoints.length} points, '
        '${_accumulatedDistanceMetres.toStringAsFixed(0)} m');
  }

  /// Clears saved route points and resets the distance accumulator.
  ///
  /// Call this before starting a new session to discard the previous route.
  void clearRoute() {
    _routePoints.clear();
    _accumulatedDistanceMetres = 0.0;
  }
}
