import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/api_constants.dart';

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
  IO.Socket? _socket;

  LeaderboardNotifier() : super([]) {
    _initSocket();
  }

  void _initSocket() {
    // Assuming ApiConstants.baseUrl has the host, e.g., 'http://10.0.2.2:3000'
    final uri = Uri.parse(ApiConstants.baseUrl);
    final socketUrl = '${uri.scheme}://${uri.host}:${uri.port}/leaderboard';

    _socket = IO.io(socketUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket?.onConnect((_) {
      print('Connected to Leaderboard Socket');
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

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, List<LeaderboardUser>>((ref) {
  return LeaderboardNotifier();
});
