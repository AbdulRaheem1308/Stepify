import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import '../../domain/models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityHistoryScreen extends ConsumerWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityProvider);
    final activities = state.recentActivities;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history_toggle_off, size: 60, color: AppTheme.neutral300),
                   const SizedBox(height: 16),
                   const Text('No activities logged yet'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityCard(context, activity);
              },
            ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getActivityIcon(activity.type), color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatActivityName(activity.type),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat('MMM d, h:mm a').format(activity.startTime),
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${activity.pointsEarned} pts',
                style: const TextStyle(
                  color: AppTheme.accentYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${activity.duration.inMinutes} min',
                style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatActivityName(ActivityType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.walking: return Icons.directions_walk;
      case ActivityType.running: return Icons.directions_run;
      case ActivityType.cycling: return Icons.directions_bike;
      case ActivityType.yoga: return Icons.self_improvement;
      case ActivityType.swimming: return Icons.pool;
      case ActivityType.gym: return Icons.fitness_center;
      case ActivityType.hiking: return Icons.hiking;
    }
  }
}
