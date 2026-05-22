import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/ai/domain/models/suggestion_model.dart';

/// Heuristic AI coaching engine that generates contextual fitness suggestions.
///
/// In a production app this would call an ML API (e.g. Vertex AI, OpenAI).
/// For now it uses rule-based logic to simulate personalised coaching.
class AiService {
  const AiService();

  /// Generates a list of [Suggestion]s based on the user's current activity.
  ///
  /// [currentSteps]      — steps completed so far today.
  /// [dailyGoal]         — target steps for the day.
  /// [lastActivityTime]  — timestamp of the most recent logged activity.
  /// [seed]              — optional seed for deterministic random suggestions
  ///                        (useful in tests).
  Future<List<Suggestion>> generateSuggestions({
    required int currentSteps,
    required int dailyGoal,
    required DateTime lastActivityTime,
    int? seed,
  }) async {
    assert(currentSteps >= 0, 'currentSteps must be non-negative');
    assert(dailyGoal > 0, 'dailyGoal must be positive');

    final suggestions = <Suggestion>[];
    final random = seed != null ? Random(seed) : Random();

    // ── 1. Goal progress ────────────────────────────────────────────────────
    if (currentSteps < dailyGoal * 0.1) {
      suggestions.add(Suggestion(
        id: 'start_day',
        title: "Start your engine! 🚀",
        description:
            "You've barely moved today. How about a 10-minute walk to wake up?",
        type: SuggestionType.motivation,
        actionLabel: 'Log Activity',
        actionRoute: '/activity/log',
      ));
    } else if (currentSteps >= dailyGoal) {
      suggestions.add(Suggestion(
        id: 'goal_met',
        title: 'Goal Crushed! 🎉',
        description:
            "You hit your $dailyGoal steps! Why not stretch or do some yoga now?",
        type: SuggestionType.wellness,
        actionLabel: 'Log Yoga',
        actionRoute: '/activity/log',
      ));
    } else if (currentSteps > dailyGoal * 0.8) {
      final remaining = dailyGoal - currentSteps;
      suggestions.add(Suggestion(
        id: 'almost_there',
        title: 'Almost there!',
        description:
            "Only $remaining steps to go. A quick lap around the block will do it!",
        type: SuggestionType.workout,
      ));
    }

    // ── 2. Inactivity alert ─────────────────────────────────────────────────
    final hoursSinceActivity =
        DateTime.now().difference(lastActivityTime).inHours;
    if (hoursSinceActivity > 3 && currentSteps < dailyGoal) {
      suggestions.add(Suggestion(
        id: 'sedentary_alert',
        title: 'Time to move? 🕰️',
        description:
            "You haven't logged activity in $hoursSinceActivity hours. Stretch your legs!",
        type: SuggestionType.wellness,
      ));
    }

    // ── 3. Hydration reminder (non-deterministic unless seed provided) ───────
    if (random.nextBool()) {
      suggestions.add(Suggestion(
        id: 'hydration',
        title: 'Stay Hydrated 💧',
        description: 'Pro tip: Drink a glass of water before your next walk.',
        type: SuggestionType.hydration,
      ));
    }

    // ── 4. Evening stroll nudge ─────────────────────────────────────────────
    final hour = DateTime.now().hour;
    if (hour >= 18 && currentSteps < 3000) {
      suggestions.add(Suggestion(
        id: 'evening_walk',
        title: 'Evening Stroll? 🌙',
        description:
            "It's a nice evening. Perfect time to catch up on steps.",
        type: SuggestionType.workout,
      ));
    }

    debugPrint(
        'AiService: Generated ${suggestions.length} suggestions '
        '(steps=$currentSteps, goal=$dailyGoal)');

    return suggestions;
  }
}

/// Riverpod provider for [AiService].
final aiServiceProvider = Provider<AiService>((ref) => const AiService());
