import 'dart:math';
import '../features/ai/domain/models/suggestion_model.dart';


class AiService {
  // Simple heuristic engine simulating "AI"
  Future<List<Suggestion>> generateSuggestions({
    required int currentSteps,
    required int dailyGoal,
    required DateTime lastActivityTime,
  }) async {
    // Simulate network/processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final List<Suggestion> suggestions = [];
    final random = Random();

    // 1. Goal Progress Logic
    if (currentSteps < dailyGoal * 0.1) {
      suggestions.add(Suggestion(
        id: 'start_day',
        title: 'Start your engine! 🚀',
        description: "You've barely moved today. How about a 10-minute walk to wake up?",
        type: SuggestionType.motivation,
        actionLabel: 'Log Activity',
        actionRoute: '/activity/log',
      ));
    } else if (currentSteps >= dailyGoal) {
      suggestions.add(Suggestion(
        id: 'goal_met',
        title: 'Goal Crushed! 🎉',
        description: "You hit your $dailyGoal steps! Why not stretch or do some yoga now?",
        type: SuggestionType.wellness,
        actionLabel: 'Log Yoga',
        actionRoute: '/activity/log',
      ));
    } else if (currentSteps > dailyGoal * 0.8) {
      final remaining = dailyGoal - currentSteps;
      suggestions.add(Suggestion(
        id: 'almost_there',
        title: 'Almost there!',
        description: "Only $remaining steps to go. A quick lap around the block will do it!",
        type: SuggestionType.workout,
      ));
    }

    // 2. Inactivity Logic
    final hoursSinceActivity = DateTime.now().difference(lastActivityTime).inHours;
    if (hoursSinceActivity > 3 && currentSteps < dailyGoal) {
      suggestions.add(Suggestion(
        id: 'sedentary_alert',
        title: 'Time to move? 🕰️',
        description: "You haven't logged activity in $hoursSinceActivity hours. Stretch your legs!",
        type: SuggestionType.wellness,
      ));
    }

    // 3. Random Wellness/Hydration (Simulating variety)
    if (random.nextBool()) {
      suggestions.add(Suggestion(
        id: 'hydration',
        title: 'Stay Hydrated 💧',
        description: "Pro tip: Drink a glass of water before your next walk.",
        type: SuggestionType.hydration,
      ));
    }

    // 4. Pattern Recognition (Mock)
    final hour = DateTime.now().hour;
    if (hour >= 18 && currentSteps < 3000) {
      suggestions.add(Suggestion(
        id: 'evening_walk',
        title: 'Evening Stroll? 🌙',
        description: "It's a nice evening. Perfect time to catch up on steps.",
        type: SuggestionType.workout,
      ));
    }

    return suggestions;
  }
}
