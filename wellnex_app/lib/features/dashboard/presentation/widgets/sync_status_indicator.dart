import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

/// Sync Status Indicator with rotating animation
class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    required this.status,
    this.lastSyncTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = AppTheme.secondaryBlue;
        return Icon(icon, size: 16, color: color)
            .animate(onComplete: (c) => c.repeat())
            .rotate(duration: 1.seconds);
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = AppTheme.success;
        break;
      case SyncStatus.failed:
        icon = Icons.cloud_off;
        color = AppTheme.error;
        break;
      case SyncStatus.idle:
        icon = Icons.cloud_outlined;
        color = AppTheme.neutral500;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  Color _getBackgroundColor() {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.secondaryBlue.withAlpha(26);
      case SyncStatus.synced:
        return AppTheme.success.withAlpha(26);
      case SyncStatus.failed:
        return AppTheme.error.withAlpha(26);
      case SyncStatus.idle:
        return AppTheme.neutral100;
    }
  }
  
  Color _getTextColor() {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.secondaryBlue;
      case SyncStatus.synced:
        return AppTheme.success;
      case SyncStatus.failed:
        return AppTheme.error;
      case SyncStatus.idle:
        return AppTheme.neutral600;
    }
  }

  String _getStatusText() {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        if (lastSyncTime != null) {
          final diff = DateTime.now().difference(lastSyncTime!);
          if (diff.inMinutes < 1) return 'Just now';
          if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
          return '${diff.inHours}h ago';
        }
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync failed';
      case SyncStatus.idle:
        return 'Tap to sync';
    }
  }
}
