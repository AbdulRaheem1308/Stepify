// Unit tests for AiService — pure logic, no I/O dependencies.
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/ai/domain/models/suggestion_model.dart';
import 'package:wellnex_app/services/ai_service.dart';

void main() {
  const service = AiService();
  final baseTime = DateTime(2024, 1, 15, 10, 0); // 10 AM

  group('AiService.generateSuggestions — goal progress rules', () {
    test('returns start_day when steps < 10% of goal', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 50,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'start_day'), isTrue);
    });

    test('returns goal_met when steps >= goal', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 10000,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'goal_met'), isTrue);
    });

    test('returns almost_there when steps > 80% of goal but < goal', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 8500,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'almost_there'), isTrue);
      final s = suggestions.firstWhere((s) => s.id == 'almost_there');
      expect(s.description, contains('1500')); // remaining steps
    });

    test('does not return goal_met or almost_there when steps = 0', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 0,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'goal_met'), isFalse);
      expect(suggestions.any((s) => s.id == 'almost_there'), isFalse);
    });
  });

  group('AiService.generateSuggestions — inactivity rule', () {
    test('returns sedentary_alert when inactive > 3h and goal not met', () async {
      final longAgo = DateTime.now().subtract(const Duration(hours: 4));
      final suggestions = await service.generateSuggestions(
        currentSteps: 3000,
        dailyGoal: 10000,
        lastActivityTime: longAgo,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'sedentary_alert'), isTrue);
    });

    test('does not return sedentary_alert when active within 3h', () async {
      final recentTime = DateTime.now().subtract(const Duration(hours: 1));
      final suggestions = await service.generateSuggestions(
        currentSteps: 3000,
        dailyGoal: 10000,
        lastActivityTime: recentTime,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'sedentary_alert'), isFalse);
    });

    test('does not return sedentary_alert when goal already met', () async {
      final longAgo = DateTime.now().subtract(const Duration(hours: 5));
      final suggestions = await service.generateSuggestions(
        currentSteps: 12000,
        dailyGoal: 10000,
        lastActivityTime: longAgo,
        seed: 0,
      );
      expect(suggestions.any((s) => s.id == 'sedentary_alert'), isFalse);
    });
  });

  group('AiService.generateSuggestions — suggestion types', () {
    test('start_day suggestion has motivation type', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 0,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      final s = suggestions.firstWhere((s) => s.id == 'start_day');
      expect(s.type, SuggestionType.motivation);
    });

    test('goal_met suggestion has wellness type', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 10000,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      final s = suggestions.firstWhere((s) => s.id == 'goal_met');
      expect(s.type, SuggestionType.wellness);
    });

    test('start_day has actionRoute pointing to activity log', () async {
      final suggestions = await service.generateSuggestions(
        currentSteps: 0,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 0,
      );
      final s = suggestions.firstWhere((s) => s.id == 'start_day');
      expect(s.actionRoute, '/activity/log');
    });
  });

  group('AiService.generateSuggestions — determinism', () {
    test('same seed produces same hydration suggestion across runs', () async {
      final r1 = await service.generateSuggestions(
        currentSteps: 5000,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 42,
      );
      final r2 = await service.generateSuggestions(
        currentSteps: 5000,
        dailyGoal: 10000,
        lastActivityTime: baseTime,
        seed: 42,
      );
      final hasHydration1 = r1.any((s) => s.id == 'hydration');
      final hasHydration2 = r2.any((s) => s.id == 'hydration');
      expect(hasHydration1, hasHydration2);
    });
  });

  group('AiService.generateSuggestions — asserts', () {
    test('throws AssertionError when dailyGoal is 0', () async {
      expect(
        () async => service.generateSuggestions(
          currentSteps: 0,
          dailyGoal: 0,
          lastActivityTime: baseTime,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws AssertionError when currentSteps is negative', () async {
      expect(
        () async => service.generateSuggestions(
          currentSteps: -1,
          dailyGoal: 10000,
          lastActivityTime: baseTime,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
