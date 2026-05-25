import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../domain/models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../providers/health_sync_provider.dart';

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthSyncProvider.notifier).syncRecentWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityProvider);
    final activities = state.recentActivities;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.activityHistory,
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
      body: activities.isEmpty
          ? _buildEmptyState(context, l10n)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityCard(context, activity, index, l10n);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              size: 64,
              color: AppTheme.primaryGreen.withValues(alpha: 0.5),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            l10n.noActivitiesYet,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            l10n.logFirstWorkout,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, Activity activity, int index, AppLocalizations l10n) {
    final iconData = _getActivityIcon(activity.type);
    final activityName = _formatActivityName(activity.type);
    final dateStr = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_jm()
        .format(activity.startTime.toLocal());
    final durationStr = '${activity.duration.inMinutes} ${l10n.activeMinutes.split(' ')[1].toLowerCase()}';
    final pointsStr = '+${activity.pointsEarned} pts';

    return Semantics(
      label: '$activityName. $dateStr. $durationStr. ${activity.pointsEarned} points earned.',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Activity icon
            ExcludeSemantics(
              child: Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(iconData, color: AppTheme.primaryGreen, size: 24),
              ),
            ),
            const SizedBox(width: 16),

            // Activity name & timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        activityName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (activity.isVerified) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'Verified by Apple Health / Google Fit',
                          child: Icon(Icons.verified, size: 16, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Points & duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pointsStr,
                    style: const TextStyle(
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  durationStr,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOut);
  }

  String _formatActivityName(ActivityType type) {
    // In a full production app with more languages, we might use l10n variables for these too.
    // For now, capitalising the enum name works for English, and we rely on translations in Hindi
    // if we added specific keys. Here we just fallback to Capitalised English.
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
}
