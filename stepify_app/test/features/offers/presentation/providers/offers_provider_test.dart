import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/offers/presentation/providers/offers_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  final jsonOffersResponse = [
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
  ];

  final jsonMyOffersResponse = [
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
  ];

  test('Offer fromJson parses correctly with fallbacks', () {
    final offer = Offer.fromJson(jsonOffersResponse[0]);
    expect(offer.id, 'o1');
    expect(offer.type, OfferType.watchToEarn);
    expect(offer.title, 'Watch & Earn');
    expect(offer.rewardCoins, 10);
  });

  test('UserOffer fromJson parses correctly with fallbacks', () {
    final userOffer = UserOffer.fromJson(jsonMyOffersResponse[0]);
    expect(userOffer.id, 'uo1');
    expect(userOffer.status, 'STARTED');
    expect(userOffer.offer.id, 'o2');
    expect(userOffer.completedAt, isNull);

    final userOffer2 = UserOffer.fromJson(jsonMyOffersResponse[1]);
    expect(userOffer2.completedAt, isNotNull);
  });

  test('OffersNotifier loads offers successfully', () async {
    when(() => mockApiService.get('/offers')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers'),
        data: jsonOffersResponse,
        statusCode: 200,
      ),
    );
    when(() => mockApiService.get('/offers/my')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers/my'),
        data: jsonMyOffersResponse,
        statusCode: 200,
      ),
    );

    final notifier = OffersNotifier(mockApiService);
    expect(notifier.state.isLoading, true);

    await Future.delayed(Duration.zero);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.allOffers.length, 2);
    expect(notifier.state.myOffers.length, 2);
    expect(notifier.state.error, isNull);

    // Filter checks
    expect(notifier.state.activeOffers.length, 1);
    expect(notifier.state.activeOffers.first.id, 'uo1');
    
    expect(notifier.state.completedOffers.length, 1);
    
    expect(notifier.state.featuredOffers.length, 1);
    expect(notifier.state.featuredOffers.first.type, OfferType.watchToEarn);

    expect(notifier.state.sponsorOffers.length, 1);
    expect(notifier.state.sponsorOffers.first.type, OfferType.survey);
  });

  test('OffersNotifier sets error on failure', () async {
    when(() => mockApiService.get('/offers')).thenThrow(Exception('Network Error'));

    final notifier = OffersNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.allOffers, isEmpty);
    expect(notifier.state.error, contains('Network Error'));
  });

  test('startOffer calls api and reloads offers', () async {
    when(() => mockApiService.get('/offers')).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/offers'), data: [], statusCode: 200));
    when(() => mockApiService.get('/offers/my')).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/offers/my'), data: [], statusCode: 200));
    
    when(() => mockApiService.post('/offers/o1/start')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers/o1/start'),
        data: {},
        statusCode: 200,
      ),
    );

    final notifier = OffersNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    await notifier.startOffer('o1');

    verify(() => mockApiService.post('/offers/o1/start')).called(1);
    verify(() => mockApiService.get('/offers')).called(2);
  });

  test('completeOffer calls api and returns reward', () async {
    when(() => mockApiService.get('/offers')).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/offers'), data: [], statusCode: 200));
    when(() => mockApiService.get('/offers/my')).thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/offers/my'), data: [], statusCode: 200));
    
    when(() => mockApiService.post('/offers/o1/complete')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/offers/o1/complete'),
        data: {'rewarded': 25},
        statusCode: 200,
      ),
    );

    final notifier = OffersNotifier(mockApiService);
    await Future.delayed(Duration.zero);

    final reward = await notifier.completeOffer('o1');

    expect(reward, 25);
    verify(() => mockApiService.post('/offers/o1/complete')).called(1);
  });
}
