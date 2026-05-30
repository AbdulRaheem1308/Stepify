import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wellnex_app/core/theme/app_theme.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    if (state.error != null || (!state.isLoading && state.suggestions.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      label: 'AI Insights section',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppTheme.accentOrange),
                  const SizedBox(width: 6),
                  Text(
                    l10n.aiInsights,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 140, // Height of the cards
            child: state.isLoading
                ? _buildLoadingState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return _SuggestionCard(suggestion: state.suggestions[index])
                          .animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 14,
                width: 140,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 180,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 1200.ms,
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
            );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final color = _getCardColor(suggestion.type);
    final semanticLabel = 'Insight: ${suggestion.title}. ${suggestion.description}'
        '${suggestion.actionLabel != null ? '. Action: ${suggestion.actionLabel}' : ''}';

    return Semantics(
      label: semanticLabel,
      button: suggestion.actionRoute != null,
      onTapHint: suggestion.actionRoute != null ? 'Activate to ${suggestion.actionLabel}' : null,
      child: GestureDetector(
        onTap: suggestion.actionRoute != null ? () => context.push(suggestion.actionRoute!) : null,
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIcon(suggestion.type),
                        size: 16,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (suggestion.actionLabel != null)
                    ExcludeSemantics(
                      child: Text(
                        suggestion.actionLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ExcludeSemantics(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? AppTheme.neutral600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
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
