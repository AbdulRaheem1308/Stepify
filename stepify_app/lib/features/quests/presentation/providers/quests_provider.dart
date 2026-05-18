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
      // Ideally we merge with user status (myQuests)
      // For now, simple list
      state = QuestsState(isLoading: false, quests: allQuests);
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
