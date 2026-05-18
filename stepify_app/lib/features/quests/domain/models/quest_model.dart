enum QuestDifficulty { easy, medium, hard, legendary }
enum QuestStatus { locked, available, inProgress, completed }

class QuestStage {
  final String id;
  final String title;
  final String description;
  final int targetSteps;
  final bool isCompleted;

  QuestStage({
    required this.id,
    required this.title,
    required this.description,
    required this.targetSteps,
    this.isCompleted = false,
  });

  factory QuestStage.fromJson(Map<String, dynamic> json) {
    return QuestStage(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetSteps: json['targetSteps'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Quest {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // For narrative/theme
  final QuestDifficulty difficulty;
  final QuestStatus status;
  final List<QuestStage> stages;
  final int currentStageIndex;
  final int rewardXp;
  final int rewardCoins;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    this.status = QuestStatus.locked,
    required this.stages,
    this.currentStageIndex = 0,
    required this.rewardXp,
    required this.rewardCoins,
  });
  
  // Helper to check progress
  double get progress {
    if (stages.isEmpty) return 0;
    return currentStageIndex / stages.length;
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      difficulty: _parseDifficulty(json['difficulty']),
      status: _parseStatus(json['status'] ?? 'AVAILABLE'),
      stages: (json['stages'] as List?)?.map((e) => QuestStage.fromJson(e)).toList() ?? [],
      currentStageIndex: json['currentStageIndex'] ?? 0,
      rewardXp: json['rewardXp'],
      rewardCoins: json['rewardCoins'],
    );
  }

  static QuestDifficulty _parseDifficulty(String val) {
    return QuestDifficulty.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == val.toUpperCase(),
      orElse: () => QuestDifficulty.medium,
    );
  }

  static QuestStatus _parseStatus(String val) {
     if (val == 'IN_PROGRESS') return QuestStatus.inProgress;
     if (val == 'COMPLETED') return QuestStatus.completed;
     if (val == 'LOCKED') return QuestStatus.locked;
     return QuestStatus.available;
  }
}
