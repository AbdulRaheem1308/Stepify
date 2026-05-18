import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../providers/messaging_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(messagingProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: state.conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.chat_bubble_outline, size: 60, color: AppTheme.neutral300),
                   const SizedBox(height: 16),
                   const Text('No messages yet'),
                ],
              ),
            )
          : ListView.separated(
              itemCount: state.conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                    backgroundImage: conv.otherUser.photoUrl != null 
                        ? NetworkImage(conv.otherUser.photoUrl!) 
                        : null,
                    child: conv.otherUser.photoUrl == null
                        ? Text((conv.otherUser.name ?? 'Unknown')[0], style: const TextStyle(color: AppTheme.primaryGreen))
                        : null,
                  ),
                  title: Text(conv.otherUser.name ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    conv.lastMessage?.content ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conv.unreadCount > 0 ? Colors.black : AppTheme.neutral500,
                      fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       if (conv.lastMessage != null)
                         Text(
                           _formatTime(conv.lastMessage!.timestamp),
                           style: const TextStyle(fontSize: 12, color: AppTheme.neutral500),
                         ),
                       const SizedBox(height: 4),
                       if (conv.unreadCount > 0)
                         Container(
                           padding: const EdgeInsets.all(6),
                           decoration: BoxDecoration(
                             color: AppTheme.primaryGreen,
                             shape: BoxShape.circle,
                           ),
                           child: Text(
                             '${conv.unreadCount}',
                             style: const TextStyle(color: Colors.white, fontSize: 10),
                           ),
                         ),
                    ],
                  ),
                  onTap: () {
                    context.push('/messages/${conv.id}', extra: conv.otherUser.name ?? 'User');
                  },
                );
              },
            ),
    );
  }

  String _formatTime(DateTime time) {
    // Simple formatter (e.g. 10:30 AM or Yesterday)
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return DateFormat.jm().format(time);
    }
    return DateFormat.MMMd().format(time);
  }
}
