import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/constants/app_constants.dart';

class LeaderboardUser {
  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String? fitnessLevel;
  final int stepCount;
  final int calories;

  LeaderboardUser({
    required this.rank,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.fitnessLevel,
    required this.stepCount,
    required this.calories,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      rank: json['rank'] ?? 0,
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      fitnessLevel: json['fitnessLevel'],
      stepCount: json['stepCount'] ?? 0,
      calories: json['calories'] ?? 0,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<List<LeaderboardUser>> {
  io.Socket? _socket;

  LeaderboardNotifier() : super([]) {
    _initSocket();
  }

  void _initSocket() {
    // Assuming AppConstants.apiBaseUrl has the host, e.g., 'http://10.0.2.2:3000/api/v1'
    final uri = Uri.parse(AppConstants.apiBaseUrl);
    final socketUrl = '${uri.scheme}://${uri.host}:${uri.port}/leaderboard';

    _socket = io.io(socketUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket?.onConnect((_) {
      _socket?.emit('join_leaderboard', {'userId': 'current_user_id'}); // Ideally pass actual user ID
    });

    _socket?.on('leaderboard_update', (data) {
      if (data is List) {
        final users = data.map((e) => LeaderboardUser.fromJson(e as Map<String, dynamic>)).toList();
        state = users;
      }
    });

    _socket?.onDisconnect((_) => print('Disconnected from Leaderboard Socket'));
    _socket?.connect();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

final leaderboardProvider = StateNotifierProvider.autoDispose<LeaderboardNotifier, List<LeaderboardUser>>((ref) {
  return LeaderboardNotifier();
});

