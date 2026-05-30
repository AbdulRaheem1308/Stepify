import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/core/theme/app_theme.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import '../../domain/models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityLoggingScreen extends ConsumerStatefulWidget {
  const ActivityLoggingScreen({super.key});

  @override
  ConsumerState<ActivityLoggingScreen> createState() => _ActivityLoggingScreenState();
}

class _ActivityLoggingScreenState extends ConsumerState<ActivityLoggingScreen> {
  ActivityType _selectedType = ActivityType.running;
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityProvider);
    final double multiplier = Activity.getPointsMultiplier(_selectedType) * 0.5;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.logWorkout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Tooltip(
          message: l10n.back,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: l10n.back,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─ Section Title ─────────────────────────────────────────────
            Text(
              l10n.whatDidYouDoToday,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // ─ Activity Type Grid ─────────────────────────────────────────
            Semantics(
              label: 'Activity type selector',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.activityType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ActivityType.values.map((type) {
                      final isSelected = _selectedType == type;
                      final label = _formatActivityName(type);
                      return Semantics(
                        label: label,
                        selected: isSelected,
                        button: true,
                        child: ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedType = type);
                          },
                          selectedColor: AppTheme.primaryGreen,
                          backgroundColor: Theme.of(context).cardColor,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          avatar: Icon(
                            _getActivityIcon(type),
                            size: 18,
                            color: isSelected ? Colors.white : AppTheme.primaryGreen,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // ─ Duration Input ─────────────────────────────────────────────
            Semantics(
              label: 'Duration in minutes input',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.durationMinutes,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.timer_outlined, color: AppTheme.primaryGreen),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            // ─ Distance Input (Conditional) ───────────────────────────────
            if (_hasDistance(_selectedType)) ...[
              const SizedBox(height: 20),
              Semantics(
                label: 'Distance in kilometres input',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.distanceKm,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5.2',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryGreen,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.map_outlined, color: AppTheme.primaryGreen),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
            ],

            const SizedBox(height: 32),

            // ─ Points Multiplier Badge ────────────────────────────────────
            Semantics(
              label: 'You will earn ${multiplier.toStringAsFixed(1)} times points for this activity.',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ExcludeSemantics(
                      child: Icon(Icons.bolt_rounded, color: AppTheme.accentYellow),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.earnPointsMultiplier(multiplier.toStringAsFixed(1)),
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ─ Submit Button ──────────────────────────────────────────────
            Semantics(
              label: 'Log workout and earn points',
              button: true,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () => _submitActivity(l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          l10n.logWorkoutAndEarn,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  void _submitActivity(AppLocalizations l10n) async {
    final rawDuration = _durationController.text.trim();
    if (rawDuration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error), backgroundColor: AppTheme.error),
      );
      return;
    }

    final duration = int.tryParse(rawDuration);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid duration entered.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    double? distance;
    if (_hasDistance(_selectedType)) {
      final rawDistance = _distanceController.text.trim();
      if (rawDistance.isNotEmpty) {
        distance = double.tryParse(rawDistance);
        if (distance == null || distance < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid distance entered.'), backgroundColor: AppTheme.error),
          );
          return;
        }
      }
    }

    final error = await ref.read(activityProvider.notifier).logActivity(
          type: _selectedType,
          duration: Duration(minutes: duration),
          distanceKm: distance,
        );

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.error,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.done), // "Done" or localized success message
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).maybePop();
      }
    }
  }

  String _formatActivityName(ActivityType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.walking:
        return Icons.directions_walk_rounded;
      case ActivityType.running:
        return Icons.directions_run_rounded;
      case ActivityType.cycling:
        return Icons.directions_bike_rounded;
      case ActivityType.yoga:
        return Icons.self_improvement_rounded;
      case ActivityType.swimming:
        return Icons.pool_rounded;
      case ActivityType.gym:
        return Icons.fitness_center_rounded;
      case ActivityType.hiking:
        return Icons.hiking_rounded;
    }
  }

  bool _hasDistance(ActivityType type) {
    return type == ActivityType.walking ||
        type == ActivityType.running ||
        type == ActivityType.cycling ||
        type == ActivityType.hiking ||
        type == ActivityType.swimming;
  }
}
