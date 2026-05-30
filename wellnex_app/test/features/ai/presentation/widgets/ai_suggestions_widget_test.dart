import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/features/ai/domain/models/suggestion_model.dart';
import 'package:wellnex_app/features/ai/presentation/providers/ai_provider.dart';
import 'package:wellnex_app/features/ai/presentation/widgets/ai_suggestions_widget.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createWidgetUnderTest(AiSuggestionsState state) {
    return ProviderScope(
      overrides: [
        aiSuggestionsProvider.overrideWith((ref) => _MockAiSuggestionsNotifier(state)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: AiSuggestionsWidget()),
      ),
    );
  }

  group('AiSuggestionsWidget', () {
    testWidgets('renders shimmer loading state when isLoading is true', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const AiSuggestionsState(isLoading: true),
      ));

      // pump once to trigger the layout
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI Insights'), findsOneWidget);
      // The shimmer containers don't have text, but we can verify the ListView is built
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders nothing when there is an error', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const AiSuggestionsState(error: 'Failed to load'),
      ));

      expect(find.text('AI Insights'), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders nothing when not loading and suggestions are empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        const AiSuggestionsState(isLoading: false, suggestions: []),
      ));

      expect(find.text('AI Insights'), findsNothing);
    });

    testWidgets('renders populated suggestions correctly', (tester) async {
      final suggestions = [
        const Suggestion(
          id: '1',
          title: 'Drink more water',
          description: 'You need hydration.',
          type: SuggestionType.hydration,
          actionLabel: 'Log Water',
          actionRoute: '/log',
        ),
      ];

      await tester.pumpWidget(createWidgetUnderTest(
        AiSuggestionsState(isLoading: false, suggestions: suggestions),
      ));
      
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('AI Insights'), findsOneWidget);
      expect(find.text('Drink more water'), findsOneWidget);
      expect(find.text('You need hydration.'), findsOneWidget);
      expect(find.text('Log Water'), findsOneWidget);
    });
  });
}

class _MockAiSuggestionsNotifier extends StateNotifier<AiSuggestionsState> implements AiSuggestionsNotifier {
  _MockAiSuggestionsNotifier(super.state);

  @override
  Future<void> refreshSuggestions() async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
