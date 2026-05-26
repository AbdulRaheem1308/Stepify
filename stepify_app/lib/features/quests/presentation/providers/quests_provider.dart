import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../services/quests_service.dart';
import '../../../../services/api_service.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/quest_model.dart';

class QuestsState {
  final List<Quest> quests;
  final bool isLoading;
  final String? error;

  QuestsState({
    this.quests = const [],
    this.isLoading = false,
    this.error,
  });

  QuestsState copyWith({
    List<Quest>? quests,
    bool? isLoading,
    String? error,
  }) {
    return QuestsState(
      quests: quests ?? this.quests,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null, copyWith allows overriding with null if not handled specifically, but we'll manage it.
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestsState &&
        _listEquals(other.quests, quests) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hashAll(quests) ^ isLoading.hashCode ^ error.hashCode;

  bool _listEquals(List<Quest> a, List<Quest> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class QuestsNotifier extends StateNotifier<QuestsState> {
  final QuestsService _service;
  final String? _userId;

  QuestsNotifier(this._service, this._userId) : super(QuestsState()) {
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    state = QuestsState(isLoading: true, quests: state.quests, error: null);
    try {
      final allQuests = await _service.getAllQuests();
      List<Quest> finalQuests = allQuests;

      if (_userId != null) {
        try {
          final myQuests = await _service.getMyQuests();
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
          debugPrint('Error loading user specific quests: $e');
          state = QuestsState(
            isLoading: false,
            quests: allQuests,
            error: 'Failed to load joined quests: ${e.toString().replaceAll('Exception: ', '')}',
          );
          return;
        }
      }

      state = QuestsState(isLoading: false, quests: finalQuests, error: null);
    } catch (e) {
      state = QuestsState(
        isLoading: false,
        quests: state.quests,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> joinQuest(String questId) async {
    if (_userId == null) {
      state = QuestsState(isLoading: state.isLoading, quests: state.quests, error: 'You must be logged in to join quests.');
      return;
    }
    
    // Optimistic local state update: mark quest as in progress instantly
    final originalQuests = state.quests;
    final updatedQuests = state.quests.map((quest) {
      if (quest.id == questId) {
        return quest.copyWith(status: QuestStatus.inProgress, currentStageIndex: 0);
      }
      return quest;
    }).toList();
    
    state = QuestsState(isLoading: true, quests: updatedQuests, error: null);
    
    try {
      await _service.joinQuest(questId);
      // Refresh quests to get synchronized status from the backend
      await _loadQuests();
    } catch (e) {
      // Revert optimistic update on failure
      state = QuestsState(
        isLoading: false,
        quests: originalQuests,
        error: 'Failed to join quest: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void clearError() {
    state = QuestsState(isLoading: state.isLoading, quests: state.quests, error: null);
  }
}

final questsServiceProvider = Provider<QuestsService>((ref) {
  return QuestsService(ref.watch(apiServiceProvider));
});

final questsProvider = StateNotifierProvider.autoDispose<QuestsNotifier, QuestsState>((ref) {
  final user = ref.watch(currentUserProvider);
  return QuestsNotifier(ref.watch(questsServiceProvider), user?.id);
});
