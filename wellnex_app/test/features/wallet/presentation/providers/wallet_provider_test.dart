import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:wellnex_app/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:wellnex_app/services/api_service.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockApiService extends Mock implements ApiService {}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Response<dynamic> _response(dynamic data) => Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: 200,
    );

const _walletJson = {'balance': 1200, 'lifetimePoints': 5000};

final _txListJson = [
  {
    'id': 'tx1',
    'type': 'STEPS',
    'points': 100,
    'description': 'Daily walk',
    'createdAt': '2025-01-10T09:00:00.000Z',
  },
  {
    'id': 'tx2',
    'type': 'REDEMPTION',
    'points': -200,
    'description': 'Gift card',
    'createdAt': '2025-01-11T09:00:00.000Z',
  },
];

WalletNotifier _makeNotifier(MockApiService api) => WalletNotifier(api);

ProviderContainer _makeContainer(MockApiService api) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(api),
    ],
  );
}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    registerFallbackValue(RequestOptions(path: ''));
  });

  // ─── Initial State ────────────────────────────────────────────────────────

  group('WalletNotifier initial state', () {
    test('is correct', () {
      final notifier = _makeNotifier(mockApi);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.balance, 0);
      expect(notifier.state.lifetimePoints, 0);
      expect(notifier.state.transactions, isEmpty);
      expect(notifier.state.selectedFilter, TransactionFilter.all);
      expect(notifier.state.error, isNull);
    });
  });

  // ─── fetchWalletData ──────────────────────────────────────────────────────

  group('WalletNotifier fetchWalletData', () {
    test('sets loading then populates state on success (data wrapped in {data:[]})', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': _txListJson}));

      final notifier = _makeNotifier(mockApi);
      final future = notifier.fetchWalletData();

      // Immediately after starting, isLoading should be true
      expect(notifier.state.isLoading, isTrue);

      await future;

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.balance, 1200);
      expect(notifier.state.lifetimePoints, 5000);
      expect(notifier.state.transactions.length, 2);
      expect(notifier.state.error, isNull);
    });

    test('works when transactions response is a bare List', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response(_txListJson));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.transactions.length, 2);
    });

    test('works when transactions are in {transactions:[]} key', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'transactions': _txListJson}));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.transactions.length, 2);
    });

    test('handles null transactions data gracefully', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response(null));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.transactions, isEmpty);
      expect(notifier.state.error, isNull);
    });

    test('sets error state on API failure', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));
      when(() => mockApi.get('/rewards/transactions'))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('clears previous error on retry', () async {
      // First call fails
      when(() => mockApi.get('/rewards/wallet'))
          .thenThrow(Exception('network error'));
      when(() => mockApi.get('/rewards/transactions'))
          .thenThrow(Exception('network error'));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();
      expect(notifier.state.error, isNotNull);

      // Second call succeeds
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': _txListJson}));

      await notifier.fetchWalletData();
      expect(notifier.state.error, isNull);
      expect(notifier.state.balance, 1200);
    });

    test('correctly parses balance and lifetimePoints from wallet data', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response({'balance': 0, 'lifetimePoints': 99999}));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': []}));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.balance, 0);
      expect(notifier.state.lifetimePoints, 99999);
    });

    test('uses 0 as fallback when balance is missing from response', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(<String, dynamic>{}));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': []}));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      expect(notifier.state.balance, 0);
      expect(notifier.state.lifetimePoints, 0);
    });
  });

  // ─── setFilter ────────────────────────────────────────────────────────────

  group('WalletNotifier setFilter', () {
    test('updates selectedFilter', () {
      final notifier = _makeNotifier(mockApi);
      notifier.setFilter(TransactionFilter.earned);
      expect(notifier.state.selectedFilter, TransactionFilter.earned);
    });

    test('switching to REDEEMED filters correctly', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': _txListJson}));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      notifier.setFilter(TransactionFilter.redeemed);
      expect(notifier.state.selectedFilter, TransactionFilter.redeemed);
      expect(
        notifier.state.filteredTransactions.every((t) => t.isRedemption),
        isTrue,
      );
    });

    test('switching back to ALL shows all transactions', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenAnswer((_) async => _response(_walletJson));
      when(() => mockApi.get('/rewards/transactions'))
          .thenAnswer((_) async => _response({'data': _txListJson}));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();

      notifier.setFilter(TransactionFilter.earned);
      notifier.setFilter(TransactionFilter.all);
      expect(notifier.state.filteredTransactions.length, 2);
    });
  });

  // ─── clearError ───────────────────────────────────────────────────────────

  group('WalletNotifier clearError', () {
    test('resets error to null', () async {
      when(() => mockApi.get('/rewards/wallet'))
          .thenThrow(Exception('fail'));
      when(() => mockApi.get('/rewards/transactions'))
          .thenThrow(Exception('fail'));

      final notifier = _makeNotifier(mockApi);
      await notifier.fetchWalletData();
      expect(notifier.state.error, isNotNull);

      notifier.clearError();
      expect(notifier.state.error, isNull);
    });

    test('is a no-op when error is already null', () {
      final notifier = _makeNotifier(mockApi);
      expect(() => notifier.clearError(), returnsNormally);
      expect(notifier.state.error, isNull);
    });
  });

  // ─── Provider integration ─────────────────────────────────────────────────

  group('walletProvider integration', () {
    test('can be overridden in ProviderContainer', () {
      final container = _makeContainer(mockApi);
      addTearDown(container.dispose);

      final state = container.read(walletProvider);
      expect(state.balance, 0);
    });

    test('notifier accessible via container', () {
      final container = _makeContainer(mockApi);
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      expect(notifier, isA<WalletNotifier>());
    });
  });
}
