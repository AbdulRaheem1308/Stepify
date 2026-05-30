import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wellnex_app/features/offers/presentation/screens/offers_screen.dart';
import 'package:wellnex_app/services/api_service.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

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
        home: OffersScreen(),
      ),
    );
  }

  testWidgets('OffersScreen shows empty state when no offers', (WidgetTester tester) async {
    when(() => mockApiService.get('/offers')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/offers'), data: [], statusCode: 200),
    );
    when(() => mockApiService.get('/offers/my')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/offers/my'), data: [], statusCode: 200),
    );

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    expect(find.text('No offers available'), findsOneWidget);
  });

  testWidgets('OffersScreen shows featured and sponsor offers', (WidgetTester tester) async {
    when(() => mockApiService.get('/offers')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers'),
        data: [
          {
            'id': 'o1',
            'title': 'Watch & Earn',
            'providerName': 'AdMob',
            'rewardCoins': 10,
            'offerType': 'WATCH_TO_EARN',
            'description': 'Watch a 30s ad to earn 10 coins.',
          },
          {
            'id': 'o2',
            'title': 'Take a Survey',
            'providerName': 'SurveyMonkey',
            'rewardCoins': 50,
            'offerType': 'SURVEY',
            'description': 'Take a short survey.',
          }
        ],
        statusCode: 200,
      ),
    );
    when(() => mockApiService.get('/offers/my')).thenAnswer(
      (_) async => Response(requestOptions: RequestOptions(path: '/offers/my'), data: [], statusCode: 200),
    );

    final container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Watch & Earn'), findsNWidgets(2)); // Title and section title might match, wait title is 'Watch & Earn', section is 'Watch & Earn'
    expect(find.text('Sponsor Deals'), findsOneWidget);
    expect(find.text('Take a Survey'), findsOneWidget);
  });
}
