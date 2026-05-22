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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is QuestStage &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.targetSteps == targetSteps &&
      other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      targetSteps.hashCode ^
      isCompleted.hashCode;
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

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    QuestDifficulty? difficulty,
    QuestStatus? status,
    List<QuestStage>? stages,
    int? currentStageIndex,
    int? rewardXp,
    int? rewardCoins,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      stages: stages ?? this.stages,
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardCoins: rewardCoins ?? this.rewardCoins,
    );
  }
  
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Quest &&
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.imageUrl == imageUrl &&
      other.difficulty == difficulty &&
      other.status == status &&
      _listEquals(other.stages, stages) &&
      other.currentStageIndex == currentStageIndex &&
      other.rewardXp == rewardXp &&
      other.rewardCoins == rewardCoins;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      difficulty.hashCode ^
      status.hashCode ^
      Object.hashAll(stages) ^
      currentStageIndex.hashCode ^
      rewardXp.hashCode ^
      rewardCoins.hashCode;
  }

  bool _listEquals(List<QuestStage> a, List<QuestStage> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
