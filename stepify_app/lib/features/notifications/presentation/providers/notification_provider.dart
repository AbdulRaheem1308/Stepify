import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';

enum NotificationType { challenge, reward, social, system, steps }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;
  final String? iconAsset; 

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.iconAsset,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      description: description,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
      iconAsset: iconAsset,
    );
  }
}

class NotificationState {
  final List<NotificationItem> notifications;
  final bool isLoading;

  NotificationState({this.notifications = const [], this.isLoading = false});
  
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = NotificationState(notifications: state.notifications, isLoading: true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock Data
    final now = DateTime.now();
    final mockData = [
      NotificationItem(
        id: '1',
        type: NotificationType.reward,
        title: 'Reward Unlocked!',
        description: 'You earned the "Week Warrior" badge. Check it out!',
        timestamp: now.subtract(const Duration(minutes: 5)),
        actionRoute: AppRoutes.rewards, // Route to Rewards/Badges
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.social,
        title: 'New Friend Request',
        description: 'Sarah Walker wants to be friends.',
        timestamp: now.subtract(const Duration(hours: 2)),
        actionRoute: AppRoutes.friends,
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.challenge,
        title: 'Challenge Update',
        description: 'You are 2,000 steps away from completing "Weekend Hike".',
        timestamp: now.subtract(const Duration(hours: 5)),
        actionRoute: AppRoutes.challenges,
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.system,
        title: 'System Maintenance',
        description: 'Scheduled maintenance tonight at 2 AM.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        type: NotificationType.steps,
        title: 'Goal Reached!',
        description: 'You hit your 10,000 step goal yesterday. Great job!',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
      ),
      NotificationItem(
        id: '6',
        type: NotificationType.social,
        title: 'Boost Received ⚡',
        description: 'Mike sent you a boost!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        actionRoute: AppRoutes.friends,
      ),
    ];

    state = NotificationState(notifications: mockData, isLoading: false);
  }

  void markAsRead(String id) {
    state = NotificationState(
      notifications: state.notifications.map((n) {
        return n.id == id ? n.copyWith(isRead: true) : n;
      }).toList(),
      isLoading: false,
    );
  }

  void markAllAsRead() {
    state = NotificationState(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
      isLoading: false,
    );
  }

  void deleteNotification(String id) {
    state = NotificationState(
      notifications: state.notifications.where((n) => n.id != id).toList(),
      isLoading: false,
    );
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
