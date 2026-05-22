import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../providers/messaging_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(messagingProvider);
    
    Widget buildBody() {
      if (state.isLoading && state.conversations.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (state.error != null && state.conversations.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(messagingProvider.notifier).clearError();
                    ref.read(messagingProvider.notifier).loadConversations();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      }

      if (state.conversations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.chat_bubble_outline, size: 60, color: AppTheme.neutral300),
               const SizedBox(height: 16),
               Text(l10n.noMessagesYet),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => ref.read(messagingProvider.notifier).loadConversations(),
        child: ListView.separated(
          itemCount: state.conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conv = state.conversations[index];
            final userName = conv.otherUser.name ?? l10n.unknownUser;
            final lastMessageText = conv.lastMessage?.content ?? '';
            final timeText = conv.lastMessage != null ? _formatTime(conv.lastMessage!.timestamp) : '';
            final unreadText = conv.unreadCount > 0 ? '${conv.unreadCount} unread' : '';
            
            return Semantics(
              label: '$userName. $lastMessageText. $timeText. $unreadText',
              button: true,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  backgroundImage: conv.otherUser.photoUrl != null 
                      ? NetworkImage(conv.otherUser.photoUrl!) 
                      : null,
                  child: conv.otherUser.photoUrl == null
                      ? Text(userName.isNotEmpty ? userName[0] : '?', style: const TextStyle(color: AppTheme.primaryGreen))
                      : null,
                ),
                title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: conv.unreadCount > 0 
                        ? Theme.of(context).textTheme.bodyLarge?.color 
                        : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     if (conv.lastMessage != null)
                       Text(
                         timeText,
                         style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                       ),
                     const SizedBox(height: 4),
                     if (conv.unreadCount > 0)
                       Container(
                         padding: const EdgeInsets.all(6),
                         decoration: const BoxDecoration(
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
                  context.push('/messages/${conv.id}', extra: userName);
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesTitle)),
      body: buildBody(),
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
