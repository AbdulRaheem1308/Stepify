import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/quests_service.dart';
import '../../../../services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/quest_model.dart';

class QuestsState {
  final List<Quest> quests;
  final bool isLoading;

  QuestsState({this.quests = const [], this.isLoading = false});
}

class QuestsNotifier extends StateNotifier<QuestsState> {
  final QuestsService _service;
  final String? _userId;

  QuestsNotifier(this._service, this._userId) : super(QuestsState()) {
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    state = QuestsState(isLoading: true, quests: state.quests);
    try {
      final allQuests = await _service.getAllQuests();
      List<Quest> finalQuests = allQuests;

      if (_userId != null) {
        try {
          final myQuests = await _service.getMyQuests(_userId!);
          final myQuestsMap = {for (var mq in myQuests) mq.id: mq};
          
          finalQuests = allQuests.map((quest) {
            if (myQuestsMap.containsKey(quest.id)) {
              final userQuest = myQuestsMap[quest.id]!;
              return quest.copyWith(
                status: userQuest.status,
                currentStageIndex: userQuest.currentStageIndex,
              );
            }
            return quest;
          }).toList();
        } catch (e) {
          print('Error loading user specific quests: $e');
        }
      }

      state = QuestsState(isLoading: false, quests: finalQuests);
    } catch (e) {
      state = QuestsState(isLoading: false, quests: []);
    }
  }

  Future<void> joinQuest(String questId) async {
    if (_userId == null) return;
    try {
      await _service.joinQuest(questId, _userId!);
      // Refresh list to update status
      _loadQuests();
    } catch (e) {
      print("Failed to join quest");
    }
  }
}

final questsServiceProvider = Provider<QuestsService>((ref) {
  return QuestsService(ref.watch(apiServiceProvider));
});

final questsProvider = StateNotifierProvider<QuestsNotifier, QuestsState>((ref) {
  final user = ref.watch(currentUserProvider);
  return QuestsNotifier(ref.watch(questsServiceProvider), user?.id);
});
