import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stepify_app/features/ai/domain/models/suggestion_model.dart';
import 'package:stepify_app/features/ai/presentation/providers/ai_provider.dart';
import 'package:stepify_app/services/ai_service.dart';
import 'package:stepify_app/features/dashboard/presentation/providers/dashboard_provider.dart';

class MockAiService extends Mock implements AiService {}

void main() {
  late MockAiService mockAiService;
  late ProviderContainer container;

  setUp(() {
    mockAiService = MockAiService();
    
    // Create a mock dashboard state
    final dashboardState = DashboardState(
      todaySteps: TodaySteps(
        stepCount: 5000,
        goal: 10000,
        distanceKm: 3.0,
        caloriesBurned: 150,
        activeMinutes: 45,
        progress: 50,
        goalReached: false,
      ),
    );
    
    // We mock the dashboardProvider with a fake notifier that yields our state
    container = ProviderContainer(
      overrides: [
        aiServiceProvider.overrideWithValue(mockAiService),
        dashboardProvider.overrideWith((ref) => _FakeDashboardNotifier(dashboardState)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AiSuggestionsNotifier', () {
    test('refreshSuggestions updates state with suggestions on success', () async {
      final mockSuggestions = [
        const Suggestion(
          id: '1',
          title: 'Great work!',
          description: 'Keep it up.',
          type: SuggestionType.motivation,
        ),
      ];

      when(() => mockAiService.generateSuggestions(
            currentSteps: any(named: 'currentSteps'),
            dailyGoal: any(named: 'dailyGoal'),
            lastActivityTime: any(named: 'lastActivityTime'),
          )).thenAnswer((_) async => mockSuggestions);

      final notifier = container.read(aiSuggestionsProvider.notifier);
      
      // Before fetch
      expect(container.read(aiSuggestionsProvider).isLoading, isFalse);
      
      final fetchFuture = notifier.refreshSuggestions();
      
      // During fetch
      expect(container.read(aiSuggestionsProvider).isLoading, isTrue);
      expect(container.read(aiSuggestionsProvider).error, isNull);

      await fetchFuture;
      
      // After fetch
      final state = container.read(aiSuggestionsProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.suggestions, equals(mockSuggestions));
    });

    test('refreshSuggestions populates error string on failure', () async {
      when(() => mockAiService.generateSuggestions(
            currentSteps: any(named: 'currentSteps'),
            dailyGoal: any(named: 'dailyGoal'),
            lastActivityTime: any(named: 'lastActivityTime'),
          )).thenThrow(Exception('AI failed to generate insights'));

      final notifier = container.read(aiSuggestionsProvider.notifier);
      await notifier.refreshSuggestions();
      
      final state = container.read(aiSuggestionsProvider);
      expect(state.isLoading, isFalse);
      expect(state.suggestions, isEmpty);
      expect(state.error, contains('AI failed to generate insights'));
    });
  });
}

class _FakeDashboardNotifier extends StateNotifier<DashboardState> implements DashboardNotifier {
  _FakeDashboardNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
