import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/api_service.dart';

enum NotificationType { challenge, reward, social, system, achievement, steps }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      description: json['message'] ?? '',
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'achievement': return NotificationType.achievement;
      case 'steps': return NotificationType.steps;
      case 'streak_bonus': return NotificationType.reward;
      case 'referral': return NotificationType.social;
      case 'challenge': return NotificationType.challenge;
      default: return NotificationType.system;
    }
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      description: description,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl,
    );
  }
}

class NotificationsState {
  final List<AppNotification> notifications;
  final String activeFilter;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.notifications = const [],
    this.activeFilter = 'All',
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    String? activeFilter,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      activeFilter: activeFilter ?? this.activeFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final ApiService _apiService;

  NotificationsNotifier(this._apiService) : super(NotificationsState()) {
    loadNotifications();
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiService.get('/notifications');
      final notifications = (response.data as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      // Show empty state on error - no demo data
      state = state.copyWith(notifications: [], isLoading: false, error: e.toString());
    }
  }

  void markAsRead(String id) {
    _apiService.post('/notifications/$id/read').ignore();
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        return n.id == id ? n.copyWith(isRead: true) : n;
      }).toList(),
    );
  }

  void markAllAsRead() {
    _apiService.post('/notifications/all/read').ignore();
    state = state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  void deleteNotification(String id) {
    _apiService.post('/notifications/$id/delete').ignore();
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != id).toList(),
    );
  }
  
  // Demo data removed - notifications are fetched from API only
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(apiServiceProvider));
});
