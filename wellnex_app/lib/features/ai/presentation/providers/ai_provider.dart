import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/services/ai_service.dart';
import '../../domain/models/suggestion_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class AiSuggestionsState {
  final List<Suggestion> suggestions;
  final bool isLoading;
  final String? error;

  const AiSuggestionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  AiSuggestionsState copyWith({
    List<Suggestion>? suggestions,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AiSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiSuggestionsNotifier extends StateNotifier<AiSuggestionsState> {
  final AiService _aiService;
  final Ref _ref;

  AiSuggestionsNotifier(this._aiService, this._ref) : super(const AiSuggestionsState());

  Future<void> refreshSuggestions() async {
    state = state.copyWith(isLoading: true, clearError: true);

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
      
      state = state.copyWith(suggestions: suggestions, isLoading: false);
    } catch (e) {
      // Use ApiError if we want, or just a generic string
      state = state.copyWith(
        isLoading: false, 
        error: e.toString(),
      );
    }
  }
}

final aiSuggestionsProvider = StateNotifierProvider.autoDispose<AiSuggestionsNotifier, AiSuggestionsState>((ref) {
  return AiSuggestionsNotifier(ref.watch(aiServiceProvider), ref);
});
