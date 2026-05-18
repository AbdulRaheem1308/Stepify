import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/services/ai_service.dart';
import '../../domain/models/suggestion_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

final aiServiceProvider = Provider((ref) => AiService());

class AiSuggestionsState {
  final List<Suggestion> suggestions;
  final bool isLoading;

  AiSuggestionsState({this.suggestions = const [], this.isLoading = false});
}

class AiSuggestionsNotifier extends StateNotifier<AiSuggestionsState> {
  final AiService _aiService;
  final Ref _ref;

  AiSuggestionsNotifier(this._aiService, this._ref) : super(AiSuggestionsState());

  Future<void> refreshSuggestions() async {
    state = AiSuggestionsState(suggestions: state.suggestions, isLoading: true);

    // Get real context from dashboard provider
    final dashboard = _ref.read(dashboardProvider);
    final currentSteps = dashboard.todaySteps?.stepCount ?? 4500;
    final dailyGoal = dashboard.todaySteps?.goal ?? 10000;
    final lastActivity = dashboard.todaySteps != null 
        ? DateTime.now() // Assume active if data present
        : DateTime.now().subtract(const Duration(hours: 4));

    try {
      final suggestions = await _aiService.generateSuggestions(
        currentSteps: currentSteps,
        dailyGoal: dailyGoal,
        lastActivityTime: lastActivity,
      );
      
      state = AiSuggestionsState(suggestions: suggestions, isLoading: false);
    } catch (e) {
      state = AiSuggestionsState(suggestions: [], isLoading: false);
    }
  }
}

final aiSuggestionsProvider = StateNotifierProvider<AiSuggestionsNotifier, AiSuggestionsState>((ref) {
  return AiSuggestionsNotifier(ref.watch(aiServiceProvider), ref);
});
