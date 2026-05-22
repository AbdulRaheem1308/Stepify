import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:stepify_app/features/notifications/presentation/widgets/notification_card.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationsScreen(),
      ),
    );
  }

  testWidgets('NotificationsScreen shows empty state', (WidgetTester tester) async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: [],
        statusCode: 200,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('NotificationsScreen shows notification cards and filters them', (WidgetTester tester) async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: [
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
          }
        ],
        statusCode: 200,
      ),
    );

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pump();
    await tester.pumpAndSettle(); // Wait for animations

    expect(find.byType(NotificationCard), findsNWidgets(2));
    expect(find.text('New Friend'), findsOneWidget);
    expect(find.text('Reward unlocked'), findsOneWidget);

    // Test filter 'Social'
    await tester.tap(find.text('Social'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationCard), findsNWidgets(1));
    expect(find.text('New Friend'), findsOneWidget);
    expect(find.text('Reward unlocked'), findsNothing);
  });

  testWidgets('NotificationCard dismissible works', (WidgetTester tester) async {
    when(() => mockApiService.get('/notifications')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/notifications'),
        data: [
          {
            'id': 'n1',
            'type': 'social',
            'title': 'New Friend',
            'message': 'Alice accepted your request',
            'createdAt': '2023-10-25T12:00:00Z',
            'isRead': false,
          },
        ],
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

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationCard), findsOneWidget);

    // Dismiss
    await tester.drag(find.byType(NotificationCard), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationCard), findsNothing);
    verify(() => mockApiService.post('/notifications/n1/delete')).called(1);
  });
}
