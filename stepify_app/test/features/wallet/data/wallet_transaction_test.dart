import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/wallet/presentation/providers/wallet_provider.dart';

void main() {
  // ─── WalletTransaction ───────────────────────────────────────────────────

  group('WalletTransaction model', () {
    final baseJson = {
      'id': 'tx1',
      'type': 'STEPS',
      'points': 150,
      'description': 'Daily walk reward',
      'createdAt': '2025-01-15T10:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final tx = WalletTransaction.fromJson(baseJson);
      expect(tx.id, 'tx1');
      expect(tx.type, 'STEPS');
      expect(tx.points, 150);
      expect(tx.description, 'Daily walk reward');
      expect(tx.createdAt, DateTime.parse('2025-01-15T10:00:00.000Z'));
    });

    test('fromJson uses _id fallback when id is missing', () {
      final json = {...baseJson, '_id': 'mongo123'}..remove('id');
      final tx = WalletTransaction.fromJson(json);
      expect(tx.id, 'mongo123');
    });

    test('fromJson defaults to STEPS type when type is null', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('type');
      final tx = WalletTransaction.fromJson(json);
      expect(tx.type, TransactionType.steps);
    });

    test('fromJson defaults to 0 points when points is null', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('points');
      final tx = WalletTransaction.fromJson(json);
      expect(tx.points, 0);
    });

    test('fromJson handles null createdAt gracefully', () {
      final json = Map<String, dynamic>.from(baseJson)..remove('createdAt');
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final tx = WalletTransaction.fromJson(json);
      expect(tx.createdAt.isAfter(before), isTrue);
    });

    test('fromJson handles malformed createdAt gracefully', () {
      final json = {...baseJson, 'createdAt': 'not-a-date'};
      expect(() => WalletTransaction.fromJson(json), returnsNormally);
      final tx = WalletTransaction.fromJson(json);
      // Falls back to DateTime.now()
      expect(tx.createdAt, isA<DateTime>());
    });

    test('fromJson handles empty string createdAt gracefully', () {
      final json = {...baseJson, 'createdAt': ''};
      expect(() => WalletTransaction.fromJson(json), returnsNormally);
    });

    test('isEarning returns true when points > 0', () {
      final tx = WalletTransaction.fromJson(baseJson);
      expect(tx.isEarning, isTrue);
    });

    test('isEarning returns false when points <= 0', () {
      final tx = WalletTransaction.fromJson({...baseJson, 'points': -50});
      expect(tx.isEarning, isFalse);
    });

    test('isRedemption returns true when points < 0', () {
      final tx = WalletTransaction.fromJson({...baseJson, 'points': -50});
      expect(tx.isRedemption, isTrue);
    });

    test('isRedemption returns true when type is REDEMPTION regardless of points', () {
      final tx = WalletTransaction.fromJson({...baseJson, 'type': 'REDEMPTION', 'points': 0});
      expect(tx.isRedemption, isTrue);
    });

    test('toJson serialises all fields', () {
      final tx = WalletTransaction.fromJson(baseJson);
      final json = tx.toJson();
      expect(json['id'], 'tx1');
      expect(json['type'], 'STEPS');
      expect(json['points'], 150);
      expect(json['description'], 'Daily walk reward');
      expect(json['createdAt'], isA<String>());
    });

    test('copyWith produces updated copy', () {
      final tx = WalletTransaction.fromJson(baseJson);
      final copy = tx.copyWith(points: 999, type: 'MILESTONE');
      expect(copy.points, 999);
      expect(copy.type, 'MILESTONE');
      expect(copy.id, tx.id); // unchanged
    });

    test('equality by id', () {
      final a = WalletTransaction.fromJson(baseJson);
      final b = WalletTransaction.fromJson({...baseJson, 'points': 999});
      expect(a, equals(b)); // same id
    });

    test('inequality when ids differ', () {
      final a = WalletTransaction.fromJson(baseJson);
      final b = WalletTransaction.fromJson({...baseJson, 'id': 'tx2'});
      expect(a, isNot(equals(b)));
    });

    test('hashCode equals for same id', () {
      final a = WalletTransaction.fromJson(baseJson);
      final b = WalletTransaction.fromJson({...baseJson, 'points': 999});
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns readable string', () {
      final tx = WalletTransaction.fromJson(baseJson);
      expect(tx.toString(), contains('tx1'));
      expect(tx.toString(), contains('STEPS'));
    });
  });

  // ─── WalletState ─────────────────────────────────────────────────────────

  group('WalletState', () {
    final tx1 = WalletTransaction(
      id: 'a',
      type: TransactionType.steps,
      points: 100,
      createdAt: DateTime.now(),
    );
    final tx2 = WalletTransaction(
      id: 'b',
      type: TransactionType.redemption,
      points: -50,
      createdAt: DateTime.now(),
    );
    final tx3 = WalletTransaction(
      id: 'c',
      type: TransactionType.streakBonus,
      points: 200,
      createdAt: DateTime.now(),
    );

    test('default state is correct', () {
      const state = WalletState();
      expect(state.isLoading, isFalse);
      expect(state.balance, 0);
      expect(state.lifetimePoints, 0);
      expect(state.transactions, isEmpty);
      expect(state.selectedFilter, TransactionFilter.all);
      expect(state.error, isNull);
    });

    test('copyWith updates fields', () {
      const state = WalletState();
      final updated = state.copyWith(balance: 500, isLoading: true);
      expect(updated.balance, 500);
      expect(updated.isLoading, isTrue);
    });

    test('copyWith with clearError sets error to null', () {
      final state = const WalletState().copyWith(error: 'oops');
      expect(state.error, 'oops');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith preserves existing error when not clearing', () {
      final state = const WalletState().copyWith(error: 'existing');
      final updated = state.copyWith(balance: 100);
      expect(updated.error, 'existing');
    });

    test('filteredTransactions ALL returns all', () {
      final state = WalletState(
        transactions: [tx1, tx2, tx3],
        selectedFilter: TransactionFilter.all,
      );
      expect(state.filteredTransactions.length, 3);
    });

    test('filteredTransactions EARNED returns only earning', () {
      final state = WalletState(
        transactions: [tx1, tx2, tx3],
        selectedFilter: TransactionFilter.earned,
      );
      final result = state.filteredTransactions;
      expect(result.every((t) => t.isEarning), isTrue);
      expect(result.length, 2); // tx1 and tx3
    });

    test('filteredTransactions REDEEMED returns only redemptions', () {
      final state = WalletState(
        transactions: [tx1, tx2, tx3],
        selectedFilter: TransactionFilter.redeemed,
      );
      final result = state.filteredTransactions;
      expect(result.every((t) => t.isRedemption), isTrue);
      expect(result.length, 1); // tx2
    });

    test('totalEarned sums all positive points', () {
      final state = WalletState(transactions: [tx1, tx2, tx3]);
      expect(state.totalEarned, 300); // 100 + 200
    });

    test('totalSpent sums absolute values of negative points', () {
      final state = WalletState(transactions: [tx1, tx2, tx3]);
      expect(state.totalSpent, 50);
    });

    test('totalEarned is 0 when no earning transactions', () {
      final state = WalletState(transactions: [tx2]);
      expect(state.totalEarned, 0);
    });

    test('totalSpent is 0 when no redemption transactions', () {
      final state = WalletState(transactions: [tx1, tx3]);
      expect(state.totalSpent, 0);
    });
  });

  // ─── TransactionType / TransactionFilter constants ────────────────────────

  group('TransactionType constants', () {
    test('all expected types are defined', () {
      expect(TransactionType.steps, 'STEPS');
      expect(TransactionType.streakBonus, 'STREAK_BONUS');
      expect(TransactionType.milestone, 'MILESTONE');
      expect(TransactionType.adReward, 'AD_REWARD');
      expect(TransactionType.referral, 'REFERRAL');
      expect(TransactionType.redemption, 'REDEMPTION');
    });
  });

  group('TransactionFilter constants', () {
    test('all expected filters are defined', () {
      expect(TransactionFilter.all, 'ALL');
      expect(TransactionFilter.earned, 'EARNED');
      expect(TransactionFilter.redeemed, 'REDEEMED');
    });
  });
}
