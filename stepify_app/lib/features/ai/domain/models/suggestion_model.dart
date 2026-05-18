enum SuggestionType {
  workout,
  hydration,
  wellness,
  motivation,
  rest
}

class Suggestion {
  final String id;
  final String title;
  final String description;
  final SuggestionType type;
  final String? actionLabel;
  final String? actionRoute;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.actionLabel,
    this.actionRoute,
  });
}
