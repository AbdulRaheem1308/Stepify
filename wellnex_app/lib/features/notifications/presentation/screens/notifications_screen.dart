import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

/// Screen 10: Notification Center
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationsProvider);
    final notifications = _filterNotifications(state.notifications, state.activeFilter);

    // Error listener
    ref.listen<NotificationsState>(notificationsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () {
                ref.read(notificationsProvider.notifier).clearError();
                ref.read(notificationsProvider.notifier).loadNotifications();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.notifications}${state.unreadCount > 0 ? ' (${state.unreadCount})' : ''}'),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Mark all as read',
            child: IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: notifications.isEmpty ? null : () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            ),
          ),
        ],
      ),
      body: state.isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
              child: Column(
                children: [
                  // Filter Tabs
                  _buildFilterTabs(context, ref, state.activeFilter),
                  const SizedBox(height: 8),

                  // Notification List
                  Expanded(
                    child: notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return NotificationCard(
                                notification: notification,
                                onTap: () {
                                  ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                                  if (notification.actionUrl != null) {
                                    context.push(notification.actionUrl!);
                                  }
                                },
                                onDismiss: () {
                                  ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Notification removed'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ).animate().slideX(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms).fadeIn();
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications, String filter) {
    if (filter == 'All') return notifications;
    if (filter == 'Challenges') return notifications.where((n) => n.type == NotificationType.challenge).toList();
    if (filter == 'Rewards') {
      return notifications.where((n) => 
        n.type == NotificationType.reward || 
        n.type == NotificationType.achievement || 
        n.type == NotificationType.steps
      ).toList();
    }
    if (filter == 'Social') return notifications.where((n) => n.type == NotificationType.social).toList();
    return notifications;
  }

  Widget _buildFilterTabs(BuildContext context, WidgetRef ref, String activeFilter) {
    final filters = ['All', 'Challenges', 'Rewards', 'Social'];
    return Semantics(
      label: 'Notification filters',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: filters.map((filter) {
            final isSelected = activeFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Semantics(
                label: filter,
                selected: isSelected,
                button: true,
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(notificationsProvider.notifier).setFilter(filter);
                    }
                  },
                  backgroundColor: Theme.of(context).cardColor,
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryGreen : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  showCheckmark: false,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(child: Icon(Icons.notifications_none, size: 64, color: AppTheme.neutral300)),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(color: AppTheme.neutral500)),
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
