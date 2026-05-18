import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:stepify_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/community_provider.dart';

/// Screen 19: Community Feed
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(communityProvider);
    
    // Listen for errors
    ref.listen(communityProvider, (prev, next) {
      if (!next.isLoading && next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.community),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(communityProvider.notifier).loadFeed(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(state.error!),
                      TextButton(
                        onPressed: () => ref.read(communityProvider.notifier).loadFeed(),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : state.posts.isEmpty
                  ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(communityProvider.notifier).loadFeed(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      return _buildFeedCard(context, ref, state.posts[index], index);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostDialog(context, ref),
        label: const Text('Share Milestone'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text('No posts yet', style: TextStyle(fontSize: 18, color: AppTheme.neutral500)),
          const SizedBox(height: 8),
          Text('Be the first to share!', style: TextStyle(color: AppTheme.neutral400)),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share with Community'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What would you like to share?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(communityProvider.notifier).createPost(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, WidgetRef ref, FeedPost post, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                child: Text(
                  post.displayAvatar,
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      timeago.format(post.timestamp),
                      style: const TextStyle(color: AppTheme.neutral500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(_getTypeIcon(post.type), color: AppTheme.neutral400, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(post.content, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),

          // Achievement Visual
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.secondaryBlue.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getTypeIcon(post.type),
                size: 48,
                color: AppTheme.primaryGreen.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              InkWell(
                onTap: () => ref.read(communityProvider.notifier).reactToPost(post.id),
                child: _buildActionButton(Icons.thumb_up_alt_outlined, '${post.likes}'),
              ),
              const SizedBox(width: 24),
              _buildActionButton(Icons.comment_outlined, '${post.comments}'),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: AppTheme.neutral500)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neutral500, size: 20),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppTheme.neutral600, fontWeight: FontWeight.w600)),
      ],
    );
  }

  IconData _getTypeIcon(FeedItemType type) {
    switch (type) {
      case FeedItemType.milestone:
        return Icons.military_tech;
      case FeedItemType.challenge:
        return Icons.emoji_events;
      case FeedItemType.streak:
        return Icons.local_fire_department;
      case FeedItemType.manual:
        return Icons.chat_bubble_outline;
    }
  }
}
