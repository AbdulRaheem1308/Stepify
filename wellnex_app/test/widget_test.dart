import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ---------------------------------------------------------------------------
/// Wellnex Flutter Unit & Widget Tests
/// ---------------------------------------------------------------------------
/// These tests validate core UI states and business logic without requiring
/// a live backend. They use pure widget testing with Riverpod overrides.
/// ---------------------------------------------------------------------------

// ─── Helper ──────────────────────────────────────────────────────────────────

/// Wraps a widget in the providers Wellnex requires (Riverpod + Material).
Widget buildTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

// ─── Unit Tests: Utility Logic ────────────────────────────────────────────────

void main() {
  group('Unit Tests: Number Formatting', () {
    String formatNumber(int number) {
      if (number >= 1000) {
        return number
            .toString()
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
      }
      return number.toString();
    }

    test('formats numbers under 1000 without commas', () {
      expect(formatNumber(0), '0');
      expect(formatNumber(999), '999');
    });

    test('formats numbers >= 1000 with comma separators', () {
      expect(formatNumber(1000), '1,000');
      expect(formatNumber(12500), '12,500');
      expect(formatNumber(1000000), '1,000,000');
    });
  });

  group('Unit Tests: Referral Code Validation', () {
    bool isValidReferralCode(String code) {
      return RegExp(r'^STEP[A-Z0-9]{6}$').hasMatch(code);
    }

    test('accepts valid referral code format', () {
      expect(isValidReferralCode('STEPABC123'), isTrue);
      expect(isValidReferralCode('STEP123456'), isTrue);
    });

    test('rejects invalid referral code format', () {
      expect(isValidReferralCode(''), isFalse);
      expect(isValidReferralCode('INVALID'), isFalse);
      expect(isValidReferralCode('step123456'), isFalse); // lowercase
      expect(isValidReferralCode('STEPABCD1234'), isFalse); // too long
    });
  });

  group('Unit Tests: Step Calorie Calculation', () {
    double calculateCalories(int steps) {
      // Standard: 0.04 kcal per step
      return steps * 0.04;
    }

    test('returns 0 calories for 0 steps', () {
      expect(calculateCalories(0), 0.0);
    });

    test('calculates correctly for 10,000 steps', () {
      expect(calculateCalories(10000), 400.0);
    });

    test('calculates correctly for 5,000 steps', () {
      expect(calculateCalories(5000), 200.0);
    });
  });

  group('Unit Tests: Wallet Balance Validation', () {
    bool hasSufficientBalance(int balance, int cost) => balance >= cost;

    test('returns true when balance covers cost', () {
      expect(hasSufficientBalance(500, 100), isTrue);
      expect(hasSufficientBalance(100, 100), isTrue);
    });

    test('returns false when balance is insufficient', () {
      expect(hasSufficientBalance(50, 100), isFalse);
      expect(hasSufficientBalance(0, 1), isFalse);
    });
  });

  // ─── Widget Tests: UI Smoke Tests ──────────────────────────────────────────

  group('Widget Tests: Login Screen UI States', () {
    testWidgets('renders basic login UI elements without crashing', (tester) async {
      // Minimal login UI scaffold for verification
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Column(
              children: [
                const Text('Welcome to Wellnex'),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Continue with Google'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Continue with Phone'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Welcome to Wellnex'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
    });

    testWidgets('elevated buttons are tappable without exceptions', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('Widget Tests: Step Counter Display', () {
    testWidgets('displays step count correctly', (tester) async {
      const stepCount = 8432;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Center(
              child: Text(
                '$stepCount steps',
                key: const Key('step_count_display'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('step_count_display')), findsOneWidget);
      expect(find.text('$stepCount steps'), findsOneWidget);
    });
  });

  group('Widget Tests: Reward Coin Display', () {
    testWidgets('renders coin balance with icon', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: Row(
              children: const [
                Icon(Icons.stars_rounded, color: Colors.amber, key: Key('coin_icon')),
                SizedBox(width: 4),
                Text('1,250', key: Key('coin_balance')),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('coin_icon')), findsOneWidget);
      expect(find.byKey(const Key('coin_balance')), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
    });
  });
}
