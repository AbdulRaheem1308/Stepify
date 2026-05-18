import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notifications_provider.dart';

/// Screen 10: Notification Center
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationsProvider);
    final notifications = _filterNotifications(state.notifications, state.activeFilter);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.notifications}${state.unreadCount > 0 ? ' (${state.unreadCount})' : ''}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Tabs
                _buildFilterTabs(context, ref, state.activeFilter),
                const SizedBox(height: 8),

                // Notification List
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationItem(context, ref, notification, index);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications, String filter) {
    if (filter == 'All') return notifications;
    // Map string filter to Enum if needed, or just compare roughly
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(notificationsProvider.notifier).setFilter(filter);
                }
              },
              backgroundColor: AppTheme.neutral100,
              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                ),
              ),
               showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, WidgetRef ref, AppNotification notification, int index) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppTheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification dismissed'), duration: const Duration(seconds: 1)),
        );
      },
      child: InkWell(
        onTap: () {
          ref.read(notificationsProvider.notifier).markAsRead(notification.id);
          if (notification.actionUrl != null) {
            context.push(notification.actionUrl!);
          } else {
             // Maybe show details dialog if no URL
          }
        },
        child: Container(
          color: notification.isRead ? Colors.transparent : AppTheme.primaryGreen.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.neutral200),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: _getTypeColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.neutral900,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.timestamp),
                          style: const TextStyle(
                            color: AppTheme.neutral500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: const TextStyle(
                         color: AppTheme.neutral600,
                         fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Delete Action
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.neutral400),
                onPressed: () {
                  ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification removed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),

              if (!notification.isRead) ...[
                 const SizedBox(width: 4),
                 Container(
                   width: 8, height: 8,
                   margin: const EdgeInsets.only(top: 12),
                   decoration: const BoxDecoration(
                     color: AppTheme.primaryGreen,
                     shape: BoxShape.circle,
                   ),
                 ),
              ],
            ],
          ),
        ),
      ).animate().slideX(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms).fadeIn(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 64, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(color: AppTheme.neutral500)),
        ],
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.challenge: return Icons.emoji_events;
      case NotificationType.reward: return Icons.card_giftcard;
      case NotificationType.social: return Icons.people;
      case NotificationType.system: return Icons.info_outline;
      case NotificationType.achievement: return Icons.military_tech;
      case NotificationType.steps: return Icons.directions_walk;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.challenge: return AppTheme.accentOrange;
      case NotificationType.reward: return AppTheme.accentPurple;
      case NotificationType.social: return AppTheme.secondaryBlue;
      case NotificationType.system: return AppTheme.neutral500;
      case NotificationType.achievement: return AppTheme.primaryGreen;
      case NotificationType.steps: return AppTheme.primaryGreen;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
