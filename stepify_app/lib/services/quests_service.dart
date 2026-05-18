import 'package:dio/dio.dart';
import '../features/quests/domain/models/quest_model.dart';
import 'api_service.dart';

class QuestsService {
  final ApiService _api;

  QuestsService(this._api);

  Future<List<Quest>> getAllQuests() async {
    try {
      final response = await _api.get('/quests');
      final List data = response.data;
      return data.map((json) => Quest.fromJson(json)).toList();
    } catch (e) {
      // Fallback for demo if backend not ready or empty
      print('Error fetching quests: $e');
      return []; 
    }
  }

  Future<void> joinQuest(String questId, String userId) async {
    await _api.post('/quests/$questId/join', data: {'userId': userId});
  }

  Future<List<Quest>> getMyQuests(String userId) async {
    final response = await _api.get('/quests/my-quests/$userId');
    final List data = response.data;
    // Map UserQuest response to Quest (or separate model if needed)
    // For simplicity, we assume backend returns a structure we can map to Quest
    // Or we need to parsing logic here.
    // The backend `getUserQuests` returns `UserQuest` including `quest`.
    // Let's assume we extract the nested quest and add status to it.
    return data.map((json) {
       final questJson = json['quest'];
       questJson['status'] = json['status']; // Overlay status
       questJson['currentStageIndex'] = json['currentStageIndex'];
       return Quest.fromJson(questJson);
    }).toList();
  }
}
