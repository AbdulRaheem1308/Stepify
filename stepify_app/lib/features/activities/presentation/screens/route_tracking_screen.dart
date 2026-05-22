import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/location_service.dart';
import '../../domain/models/activity_model.dart';
import '../providers/activity_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

/// GPS Route Tracking Screen
/// Shows a live-drawn route path, elapsed time, distance, and calories.
/// Uses CustomPainter to project latitude/longitude onto screen coordinates.
class RouteTrackingScreen extends ConsumerStatefulWidget {
  const RouteTrackingScreen({super.key});

  @override
  ConsumerState<RouteTrackingScreen> createState() => _RouteTrackingScreenState();
}

class _RouteTrackingScreenState extends ConsumerState<RouteTrackingScreen>
    with TickerProviderStateMixin {
  final _locationService = LocationService();

  bool _isTracking = false;
  bool _isPaused = false;
  Position? _currentPosition;
  double _totalDistanceMetres = 0;
  
  // Robust time tracking
  DateTime? _trackingStartTime;
  int _accumulatedSeconds = 0;
  int _currentSessionSeconds = 0;
  Timer? _timer;

  // Animation for the pulsing current-position dot
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const double _caloriesPerMetre = 0.06; // ~60 kcal/km walking

  int get _totalElapsedSeconds => _accumulatedSeconds + _currentSessionSeconds;

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
      _accumulatedSeconds = 0;
      _currentSessionSeconds = 0;
      _trackingStartTime = DateTime.now();
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
          _stopTracking(AppLocalizations.of(context)!);
        }
      },
    );

    if (!started) {
      setState(() => _isTracking = false);
      return;
    }

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _trackingStartTime = DateTime.now();
    // Update UI every second using the robust absolute time diff
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _trackingStartTime != null && !_isPaused) {
        setState(() {
          _currentSessionSeconds = DateTime.now().difference(_trackingStartTime!).inSeconds;
        });
      }
    });
  }

  void _pauseTracking() {
    if (_trackingStartTime != null) {
      _accumulatedSeconds += DateTime.now().difference(_trackingStartTime!).inSeconds;
      _currentSessionSeconds = 0;
      _trackingStartTime = null;
    }
    setState(() => _isPaused = true);
    _locationService.stopRouteTracking();
    _timer?.cancel();
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
    _startTimer();
  }

  void _stopTracking(AppLocalizations l10n) {
    _pauseTracking();

    if (_totalDistanceMetres < 50 || _totalElapsedSeconds < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.routeTooShort)),
      );
      _endSession();
      return;
    }

    // Show save dialog
    final distanceStr = (_totalDistanceMetres / 1000).toStringAsFixed(2);
    final durationStr = _formatDuration(_totalElapsedSeconds);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveWorkoutTitle),
        content: Text(l10n.saveWorkoutDesc(distanceStr, durationStr)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endSession();
            },
            child: Text(l10n.discard, style: const TextStyle(color: AppTheme.error)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _saveRouteToBackend(l10n);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            child: Text(l10n.saveRoute),
          ),
        ],
      ),
    );
  }

  void _endSession() {
    _locationService.stopRouteTracking();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
      _isPaused = false;
      _totalDistanceMetres = 0;
      _accumulatedSeconds = 0;
      _currentSessionSeconds = 0;
      _trackingStartTime = null;
    });
  }

  Future<void> _saveRouteToBackend(AppLocalizations l10n) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
    );

    final error = await ref.read(activityProvider.notifier).logActivity(
      type: ActivityType.running, // Defaulting GPS routes to running for now
      duration: Duration(seconds: _totalElapsedSeconds),
      distanceKm: _totalDistanceMetres / 1000.0,
    );

    if (mounted) Navigator.pop(context); // pop loading

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: AppTheme.error));
      _endSession();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.done), backgroundColor: AppTheme.success));
      _endSession();
    }
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
    if (_totalDistanceMetres < 10 || _totalElapsedSeconds < 5) return 0;
    return (_totalElapsedSeconds / 60) / (_totalDistanceMetres / 1000);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final points = _locationService.routePoints;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.gpsRouteTracker),
        centerTitle: true,
        leading: Tooltip(
          message: l10n.back,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: l10n.back,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ),
        actions: [
          if (_isTracking)
            Semantics(
              label: l10n.endTracking,
              button: true,
              child: TextButton(
                onPressed: () => _stopTracking(l10n),
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                child: Text(l10n.endTracking, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
              ),
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
                                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isTracking ? l10n.acquiringGps : l10n.tapStartToTrack,
                                style: const TextStyle(color: Colors.white54, fontSize: 15),
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

                // Pulsing GPS dot overlay
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
                                color: (_isPaused ? Colors.orange : AppTheme.primaryGreen).withValues(alpha: 0.6),
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
                    child: Semantics(
                      label: 'GPS accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(0)} metres',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ExcludeSemantics(
                              child: Icon(Icons.gps_fixed, size: 12, color: AppTheme.primaryGreen),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '±${_currentPosition!.accuracy.toStringAsFixed(0)}m',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      label: l10n.distance,
                      value: _totalDistanceMetres >= 1000
                          ? '${(_totalDistanceMetres / 1000).toStringAsFixed(2)} km'
                          : '${_totalDistanceMetres.toStringAsFixed(0)} m',
                      icon: Icons.straighten,
                    ),
                    _buildStat(
                      label: l10n.activeMinutes,
                      value: _formatDuration(_totalElapsedSeconds),
                      icon: Icons.timer_outlined,
                    ),
                    _buildStat(
                      label: l10n.calories,
                      value: '${_estimatedCalories.toStringAsFixed(0)} kcal',
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_paceMinPerKm > 0)
                  Text(
                    'Pace: ${_paceMinPerKm.toStringAsFixed(1)} min/km',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),

                const SizedBox(height: 20),

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
                          onTap: () => _stopTracking(l10n),
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
    return Semantics(
      label: '$label: $value',
      child: Column(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
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

    final latRange = (maxLat - minLat).clamp(0.0001, double.infinity);
    final lngRange = (maxLng - minLng).clamp(0.0001, double.infinity);
    final latPad = latRange * 0.15;
    final lngPad = lngRange * 0.15;

    minLat -= latPad; maxLat += latPad;
    minLng -= lngPad; maxLng += lngPad;

    Offset project(Position pos) {
      final x = (pos.longitude - minLng) / (maxLng - minLng) * size.width;
      final y = (1 - (pos.latitude - minLat) / (maxLat - minLat)) * size.height;
      return Offset(x, y);
    }

    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.25)
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

    final routePaint = Paint()
      ..color = routeColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);

    final startOffset = project(points.first);
    canvas.drawCircle(startOffset, 8, Paint()..color = Colors.white);
    canvas.drawCircle(startOffset, 5, Paint()..color = routeColor);

    final endOffset = project(points.last);
    canvas.drawCircle(endOffset, 10, Paint()..color = routeColor.withValues(alpha: 0.3));
    canvas.drawCircle(endOffset, 6, Paint()..color = Colors.white);
    canvas.drawCircle(endOffset, 3, Paint()..color = routeColor);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.points.length != points.length;
}
