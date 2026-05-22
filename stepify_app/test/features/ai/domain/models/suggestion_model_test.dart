import 'package:flutter_test/flutter_test.dart';
import 'package:stepify_app/features/ai/domain/models/suggestion_model.dart';

void main() {
  group('SuggestionModel', () {
    test('fromJson parses correctly with valid data', () {
      final json = {
        'id': '1',
        'title': 'Drink Water',
        'description': 'Hydration is key.',
        'type': 'hydration',
        'actionLabel': 'Log Water',
        'actionRoute': '/log-water',
      };

      final suggestion = Suggestion.fromJson(json);

      expect(suggestion.id, '1');
      expect(suggestion.title, 'Drink Water');
      expect(suggestion.description, 'Hydration is key.');
      expect(suggestion.type, SuggestionType.hydration);
      expect(suggestion.actionLabel, 'Log Water');
      expect(suggestion.actionRoute, '/log-water');
    });

    test('fromJson handles nulls and missing fields gracefully', () {
      final json = <String, dynamic>{};

      final suggestion = Suggestion.fromJson(json);

      expect(suggestion.id, '');
      expect(suggestion.title, 'Insight');
      expect(suggestion.description, '');
      expect(suggestion.type, SuggestionType.wellness); // Default
      expect(suggestion.actionLabel, isNull);
      expect(suggestion.actionRoute, isNull);
    });

    test('toJson serializes correctly', () {
      const suggestion = Suggestion(
        id: '2',
        title: 'Sleep',
        description: 'Get some rest.',
        type: SuggestionType.rest,
        actionLabel: 'Go to bed',
      );

      final json = suggestion.toJson();

      expect(json['id'], '2');
      expect(json['title'], 'Sleep');
      expect(json['description'], 'Get some rest.');
      expect(json['type'], 'rest');
      expect(json['actionLabel'], 'Go to bed');
      expect(json.containsKey('actionRoute'), isFalse);
    });

    test('equality and hashCode work properly', () {
      const s1 = Suggestion(
        id: '1',
        title: 'Walk',
        description: 'Take a walk.',
        type: SuggestionType.workout,
      );
      const s2 = Suggestion(
        id: '1',
        title: 'Walk',
        description: 'Take a walk.',
        type: SuggestionType.workout,
      );
      const s3 = Suggestion(
        id: '2',
        title: 'Walk',
        description: 'Take a walk.',
        type: SuggestionType.workout,
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });
}
