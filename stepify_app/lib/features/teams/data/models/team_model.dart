/// Team model for team challenges feature
class Team {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String captainId;
  final String captainName;
  final List<TeamMember> members;
  final int memberCount;
  final int maxMembers;
  final int totalSteps;
  final int weeklySteps;
  final int rank;
  final bool isPublic;
  final String? inviteCode;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.captainId,
    required this.captainName,
    required this.members,
    required this.memberCount,
    this.maxMembers = 10,
    required this.totalSteps,
    required this.weeklySteps,
    this.rank = 0,
    this.isPublic = true,
    this.inviteCode,
    required this.createdAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      captainId: json['captainId'] ?? json['captain']?['id'] ?? '',
      captainName: json['captainName'] ?? json['captain']?['name'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => TeamMember.fromJson(m))
              .toList() ??
          [],
      memberCount: json['memberCount'] ?? json['members']?.length ?? 0,
      maxMembers: json['maxMembers'] ?? 10,
      totalSteps: json['totalSteps'] ?? 0,
      weeklySteps: json['weeklySteps'] ?? 0,
      rank: json['rank'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      inviteCode: json['inviteCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'captainId': captainId,
        'maxMembers': maxMembers,
        'isPublic': isPublic,
      };

  bool get isFull => memberCount >= maxMembers;
}

class TeamMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final int steps;
  final int weeklySteps;
  final bool isCaptain;
  final DateTime joinedAt;

  TeamMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.steps,
    required this.weeklySteps,
    this.isCaptain = false,
    required this.joinedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] ?? json['_id'] ?? json['userId'] ?? '',
      name: json['name'] ?? json['user']?['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'] ?? json['user']?['avatarUrl'],
      steps: json['steps'] ?? json['totalSteps'] ?? 0,
      weeklySteps: json['weeklySteps'] ?? 0,
      isCaptain: json['isCaptain'] ?? json['role'] == 'captain',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
    );
  }
}

class TeamChallenge {
  final String id;
  final String title;
  final String description;
  final String teamId;
  final int targetSteps;
  final int currentSteps;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, completed, failed
  final int rewardCoins;
  final int rewardXp;

  TeamChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.teamId,
    required this.targetSteps,
    required this.currentSteps,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.rewardCoins,
    required this.rewardXp,
  });

  factory TeamChallenge.fromJson(Map<String, dynamic> json) {
    return TeamChallenge(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      teamId: json['teamId'] ?? '',
      targetSteps: json['targetSteps'] ?? 0,
      currentSteps: json['currentSteps'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'active',
      rewardCoins: json['rewardCoins'] ?? 0,
      rewardXp: json['rewardXp'] ?? 0,
    );
  }

  double get progress => targetSteps > 0 ? currentSteps / targetSteps : 0;
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed' || currentSteps >= targetSteps;
}
