import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/notifications/presentation/providers/notifications_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  final jsonResponse = [
    {
      'id': 'n1',
      'type': 'social',
      'title': 'New Friend',
      'message': 'Alice accepted your request',
      'createdAt': '2023-10-25T12:00:00Z',
      'isRead': false,
    },
    {
      'id': 'n2',
      'type': 'reward',
      'title': 'Reward unlocked',
      'message': 'You got 50 coins',
      'createdAt': '2023-10-24T12:00:00Z',
      'isRead': true,
      'actionUrl': '/rewards',
    }
  ];

  test('AppNotification fromJson parses correctly with fallbacks', () {
    final notification = AppNotification.fromJson(jsonResponse[0]);
    expect(notification.id, 'n1');
    expect(notification.type, NotificationType.social);
    expect(notification.title, 'New Friend');
    expect(notification.description, 'Alice accepted your request');
    expect(notification.isRead, false);
    expect(notification.actionUrl, isNull);
  });

  test('AppNotification equality', () {
    final n1 = AppNotification.fromJson(jsonResponse[0]);
    final n2 = AppNotification.fromJson(jsonResponse[0]);
    final n3 = AppNotification.fromJson(jsonResponse[1]);

    expect(n1, equals(n2));
    expect(n1.hashCode, equals(n2.hashCode));
    expect(n1, isNot(equals(n3)));
  });

  test('NotificationsNotifier loads notifications successfully', () async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: jsonResponse,
        statusCode: 200,
      ),
    );

    final notifier = NotificationsNotifier(mockApiService);
    expect(notifier.state.isLoading, true);

    // wait for loadNotifications microtask to finish
    await Future.delayed(Duration.zero);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.notifications.length, 2);
    expect(notifier.state.error, isNull);
    expect(notifier.state.unreadCount, 1);
  });

  test('NotificationsNotifier sets error on failure', () async {
    when(() => mockApiService.get('/notifications')).thenThrow(Exception('Network Error'));

    final notifier = NotificationsNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.notifications, isEmpty);
    expect(notifier.state.error, contains('Network Error'));
  });

  test('markAsRead updates state and calls api', () async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: jsonResponse,
        statusCode: 200,
      ),
    );
    when(() => mockApiService.post(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications/n1/read'),
        data: {},
        statusCode: 200,
      ),
    );

    final notifier = NotificationsNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    expect(notifier.state.unreadCount, 1);

    notifier.markAsRead('n1');

    expect(notifier.state.unreadCount, 0);
    verify(() => mockApiService.post('/notifications/n1/read')).called(1);
  });

  test('deleteNotification removes notification from state and calls api', () async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: jsonResponse,
        statusCode: 200,
      ),
    );
    when(() => mockApiService.post(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications/n1/delete'),
        data: {},
        statusCode: 200,
      ),
    );

    final notifier = NotificationsNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    expect(notifier.state.notifications.length, 2);

    notifier.deleteNotification('n1');

    expect(notifier.state.notifications.length, 1);
    expect(notifier.state.notifications.first.id, 'n2');
    verify(() => mockApiService.post('/notifications/n1/delete')).called(1);
  });
}
