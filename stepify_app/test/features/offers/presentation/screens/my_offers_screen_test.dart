import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/offers/presentation/screens/my_offers_screen.dart';
import 'package:stepify_app/services/api_service.dart';

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
        home: MyOffersScreen(),
      ),
    );
  }

  testWidgets('MyOffersScreen shows active, used, expired tabs', (WidgetTester tester) async {
    when(() => mockApiService.get('/offers')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/offers'), data: [], statusCode: 200),
    );
    when(() => mockApiService.get('/offers/my')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers/my'),
        data: [
          {
            'id': 'uo1',
            'offer': {
              'id': 'o2',
              'title': 'Take a Survey',
              'providerName': 'SurveyMonkey',
              'rewardCoins': 50,
              'offerType': 'SURVEY',
              'description': 'Take a short survey.',
            },
            'status': 'STARTED',
            'startedAt': '2023-10-25T12:00:00Z',
          },
          {
            'id': 'uo2',
            'offer': {
              'id': 'o1',
              'title': 'Watch & Earn',
              'providerName': 'AdMob',
              'rewardCoins': 10,
              'offerType': 'WATCH_TO_EARN',
              'description': 'Watch a 30s ad to earn 10 coins.',
            },
            'status': 'REWARDED',
            'startedAt': '2023-10-24T12:00:00Z',
            'completedAt': '2023-10-24T12:05:00Z',
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
    await tester.pumpAndSettle();

    // Default tab is 'Active'
    expect(find.text('Take a Survey'), findsOneWidget);
    expect(find.text('Watch & Earn'), findsNothing);

    // Switch to 'Used' tab
    await tester.tap(find.widgetWithText(Tab, 'Used'));
    await tester.pumpAndSettle();

    expect(find.text('Watch & Earn'), findsOneWidget);
    expect(find.text('Take a Survey'), findsNothing);

    // Switch to 'Expired' tab
    await tester.tap(find.widgetWithText(Tab, 'Expired'));
    await tester.pumpAndSettle();

    expect(find.text('No expired offers.'), findsOneWidget);
  });
}
