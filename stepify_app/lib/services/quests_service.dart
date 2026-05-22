import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/quests/domain/models/quest_model.dart';
import 'api_service.dart';

/// Service for quest/adventure-mode endpoints.
class QuestsService {
  final ApiService _api;

  const QuestsService(this._api);

  /// Returns all available quests from the backend.
  ///
  /// Returns an empty list on failure so the UI degrades gracefully.
  Future<List<Quest>> getAllQuests() async {
    try {
      final response = await _api.get('/quests');
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              Quest.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      debugPrint('QuestsService: Error fetching quests: $e');
      return [];
    }
  }

  /// Enrolls the current user into [questId].
  ///
  /// The user identity is inferred from the JWT on the backend.
  /// Throws [ApiError] on failure.
  Future<void> joinQuest(String questId) async {
    assert(questId.isNotEmpty, 'questId must not be empty');
    try {
      await _api.post('/quests/$questId/join', data: {});
    } catch (e) {
      throw ApiError.from(e);
    }
  }

  /// Returns the current user's active/completed quests.
  ///
  /// The user identity is inferred from the JWT on the backend.
  /// Throws [ApiError] on failure.
  Future<List<Quest>> getMyQuests() async {
    try {
      final response = await _api.get('/quests/my-quests');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) {
        // Create a defensive copy before mutation to avoid side-effects if
        // the same JSON object is referenced elsewhere.
        final questJson =
            Map<String, dynamic>.from(json['quest'] as Map<dynamic, dynamic>);
        // Overlay user-specific progress fields from the UserQuest wrapper.
        questJson['status'] = json['status'] as String?;
        questJson['currentStageIndex'] = json['currentStageIndex'] as int?;
        return Quest.fromJson(questJson);
      }).toList();
    } catch (e) {
      throw ApiError.from(e);
    }
  }
}

/// Riverpod provider for [QuestsService].
final questsServiceProvider = Provider<QuestsService>((ref) {
  return QuestsService(ref.read(apiServiceProvider));
});
