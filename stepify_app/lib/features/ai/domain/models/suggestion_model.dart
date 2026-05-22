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

  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.actionLabel,
    this.actionRoute,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Insight',
      description: json['description'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      if (actionLabel != null) 'actionLabel': actionLabel,
      if (actionRoute != null) 'actionRoute': actionRoute,
    };
  }

  static SuggestionType _parseType(String? typeStr) {
    if (typeStr == null) return SuggestionType.wellness;
    switch (typeStr.toLowerCase()) {
      case 'workout': return SuggestionType.workout;
      case 'hydration': return SuggestionType.hydration;
      case 'wellness': return SuggestionType.wellness;
      case 'motivation': return SuggestionType.motivation;
      case 'rest': return SuggestionType.rest;
      default: return SuggestionType.wellness;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Suggestion &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.type == type &&
      other.actionLabel == actionLabel &&
      other.actionRoute == actionRoute;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      type,
      actionLabel,
      actionRoute,
    );
  }
}
