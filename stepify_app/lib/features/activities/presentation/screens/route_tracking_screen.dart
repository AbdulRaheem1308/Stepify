import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/location_service.dart';

/// GPS Route Tracking Screen
/// Shows a live-drawn route path, elapsed time, distance, and calories.
/// Uses CustomPainter to project latitude/longitude onto screen coordinates —
/// no external map SDK or API key required.
class RouteTrackingScreen extends StatefulWidget {
  const RouteTrackingScreen({super.key});

  @override
  State<RouteTrackingScreen> createState() => _RouteTrackingScreenState();
}

class _RouteTrackingScreenState extends State<RouteTrackingScreen>
    with TickerProviderStateMixin {
  final _locationService = LocationService();

  bool _isTracking = false;
  bool _isPaused = false;
  Position? _currentPosition;
  double _totalDistanceMetres = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Animation for the pulsing current-position dot
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _caloriesPerMetre = 0.06; // ~60 kcal/km walking

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _locationService.stopRouteTracking();
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    _locationService.clearRoute();
    setState(() {
      _isTracking = true;
      _isPaused = false;
      _totalDistanceMetres = 0;
      _elapsedSeconds = 0;
    });

    final started = await _locationService.startRouteTracking(
      onUpdate: (position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _totalDistanceMetres = _locationService.totalDistanceMetres;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('GPS error: $error'), backgroundColor: AppTheme.error),
          );
          _stopTracking();
        }
      },
    );

    if (!started) {
      setState(() => _isTracking = false);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _pauseTracking() {
    setState(() => _isPaused = true);
    _locationService.stopRouteTracking();
  }

  Future<void> _resumeTracking() async {
    setState(() => _isPaused = false);
    await _locationService.startRouteTracking(
      onUpdate: (position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _totalDistanceMetres = _locationService.totalDistanceMetres;
          });
        }
      },
    );
  }

  void _stopTracking() {
    _locationService.stopRouteTracking();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
      _isPaused = false;
    });
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _estimatedCalories => _totalDistanceMetres * _caloriesPerMetre;
  double get _paceMinPerKm {
    if (_totalDistanceMetres < 10 || _elapsedSeconds < 5) return 0;
    return (_elapsedSeconds / 60) / (_totalDistanceMetres / 1000);
  }

  @override
  Widget build(BuildContext context) {
    final points = _locationService.routePoints;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('GPS Route Tracker'),
        centerTitle: true,
        actions: [
          if (_isTracking)
            TextButton(
              onPressed: _stopTracking,
              child: const Text('End', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Route Canvas ──────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Route drawing canvas
                Container(
                  width: double.infinity,
                  color: const Color(0xFF0D1117),
                  child: points.length < 2
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 64,
                                color: AppTheme.primaryGreen.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isTracking
                                    ? 'Acquiring GPS signal...'
                                    : 'Tap Start to begin tracking your route',
                                style: TextStyle(color: Colors.white54, fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : CustomPaint(
                          painter: _RoutePainter(
                            points: points,
                            routeColor: AppTheme.primaryGreen,
                            backgroundColor: const Color(0xFF0D1117),
                          ),
                          child: const SizedBox.expand(),
                        ),
                ),

                // Pulsing GPS dot overlay (top-right status)
                if (_isTracking)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isPaused ? Colors.orange : AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isPaused ? Colors.orange : AppTheme.primaryGreen).withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Accuracy badge
                if (_currentPosition != null && _isTracking)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_fixed, size: 12, color: AppTheme.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            '±${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Stats Panel ───────────────────────────────────────────────────
          Container(
            color: const Color(0xFF161B22),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Top stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      label: 'Distance',
                      value: _totalDistanceMetres >= 1000
                          ? '${(_totalDistanceMetres / 1000).toStringAsFixed(2)} km'
                          : '${_totalDistanceMetres.toStringAsFixed(0)} m',
                      icon: Icons.straighten,
                    ),
                    _buildStat(
                      label: 'Time',
                      value: _formatDuration(_elapsedSeconds),
                      icon: Icons.timer_outlined,
                    ),
                    _buildStat(
                      label: 'Calories',
                      value: '${_estimatedCalories.toStringAsFixed(0)} kcal',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Pace
                if (_paceMinPerKm > 0)
                  Text(
                    'Pace: ${_paceMinPerKm.toStringAsFixed(1)} min/km',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),

                const SizedBox(height: 20),

                // Controls
                if (!_isTracking)
                  _buildControlButton(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    color: AppTheme.primaryGreen,
                    onTap: _startTracking,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlButton(
                          label: _isPaused ? 'Resume' : 'Pause',
                          icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          color: Colors.orange,
                          onTap: _isPaused ? _resumeTracking : _pauseTracking,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildControlButton(
                          label: 'Stop',
                          icon: Icons.stop_rounded,
                          color: AppTheme.error,
                          onTap: _stopTracking,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({required String label, required String value, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ─── Route Painter ────────────────────────────────────────────────────────────

class _RoutePainter extends CustomPainter {
  final List<Position> points;
  final Color routeColor;
  final Color backgroundColor;

  const _RoutePainter({
    required this.points,
    required this.routeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Find bounding box of all GPS points
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    // Add padding (10% of range)
    final latRange = (maxLat - minLat).clamp(0.0001, double.infinity);
    final lngRange = (maxLng - minLng).clamp(0.0001, double.infinity);
    final latPad = latRange * 0.15;
    final lngPad = lngRange * 0.15;

    minLat -= latPad; maxLat += latPad;
    minLng -= lngPad; maxLng += lngPad;

    // Project lat/lng → screen offset
    Offset project(Position pos) {
      final x = (pos.longitude - minLng) / (maxLng - minLng) * size.width;
      // Invert Y because latitude increases upwards
      final y = (1 - (pos.latitude - minLat) / (maxLat - minLat)) * size.height;
      return Offset(x, y);
    }

    // Draw route shadow (glow effect)
    final glowPaint = Paint()
      ..color = routeColor.withOpacity(0.25)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(project(points.first).dx, project(points.first).dy);
    for (int i = 1; i < points.length; i++) {
      final o = project(points[i]);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(path, glowPaint);

    // Draw main route line
    final routePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    // Draw start dot
    final startOffset = project(points.first);
    canvas.drawCircle(startOffset, 8, Paint()..color = Colors.white);
    canvas.drawCircle(startOffset, 5, Paint()..color = routeColor);

    // Draw current position dot
    final endOffset = project(points.last);
    canvas.drawCircle(endOffset, 10, Paint()..color = routeColor.withOpacity(0.3));
    canvas.drawCircle(endOffset, 6, Paint()..color = Colors.white);
    canvas.drawCircle(endOffset, 3, Paint()..color = routeColor);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.points.length != points.length;
}
