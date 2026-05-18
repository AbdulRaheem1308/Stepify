import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import '../../domain/models/suggestion_model.dart';
import '../providers/ai_provider.dart';

class AiSuggestionsWidget extends ConsumerStatefulWidget {
  const AiSuggestionsWidget({super.key});

  @override
  ConsumerState<AiSuggestionsWidget> createState() => _AiSuggestionsWidgetState();
}

class _AiSuggestionsWidgetState extends ConsumerState<AiSuggestionsWidget> {
  @override
  void initState() {
    super.initState();
    // Load initial suggestions
    Future.microtask(() => ref.read(aiSuggestionsProvider.notifier).refreshSuggestions());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiSuggestionsProvider);

    if (state.suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppTheme.accentOrange),
              const SizedBox(width: 6),
              const Text(
                'AI Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140, // Height of the cards
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _SuggestionCard(suggestion: state.suggestions[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(suggestion.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getCardColor(suggestion.type).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(suggestion.type),
                  size: 16,
                  color: _getCardColor(suggestion.type),
                ),
              ),
              const Spacer(),
              if (suggestion.actionLabel != null)
                GestureDetector(
                  onTap: () {
                    if (suggestion.actionRoute != null) {
                      context.push(suggestion.actionRoute!);
                    }
                  },
                  child: Text(
                    suggestion.actionLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getCardColor(suggestion.type),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              suggestion.description,
              style: const TextStyle(fontSize: 12, color: AppTheme.neutral600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.workout:
        return AppTheme.primaryGreen;
      case SuggestionType.hydration:
        return Colors.blue;
      case SuggestionType.rest:
        return Colors.purple;
      case SuggestionType.motivation:
        return AppTheme.accentOrange;
      default:
        return AppTheme.primaryGreen;
    }
  }

  IconData _getIcon(SuggestionType type) {
    switch (type) {
      case SuggestionType.workout:
        return Icons.directions_run;
      case SuggestionType.hydration:
        return Icons.local_drink;
      case SuggestionType.rest:
        return Icons.bed;
      case SuggestionType.motivation:
        return Icons.local_fire_department;
      default:
        return Icons.lightbulb;
    }
  }
}
