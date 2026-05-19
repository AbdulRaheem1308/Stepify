import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/team_model.dart';
import '../providers/teams_provider.dart';
import 'package:stepify_app/features/auth/presentation/providers/auth_provider.dart';

/// Team Detail Screen - View team members, challenges, and stats
class TeamDetailScreen extends ConsumerStatefulWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  ConsumerState<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends ConsumerState<TeamDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(teamsProvider.notifier).fetchTeamDetails(widget.teamId);
      ref.read(teamsProvider.notifier).fetchTeamChallenges(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamsProvider);
    final team = state.currentTeam;

    if (state.isLoading && team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (team == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team')),
        body: const Center(child: Text('Team not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          _buildSliverAppBar(team),
          
          // Stats
          SliverToBoxAdapter(child: _buildStatsRow(team)),
          
          // Members section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Members (${team.memberCount}/${team.maxMembers})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          
          // Members list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = team.members[index];
                return _buildMemberTile(member, index)
                    .animate(delay: (index * 50).ms)
                    .fadeIn()
                    .slideX(begin: 0.1, end: 0);
              },
              childCount: team.members.length,
            ),
          ),

          // Team Challenges section
          if (state.teamChallenges.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Team Challenges',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildChallengeCard(state.teamChallenges[index]),
                childCount: state.teamChallenges.length,
              ),
            ),
          ],

          // Invite code section
          if (team.inviteCode != null)
            SliverToBoxAdapter(child: _buildInviteSection(team)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Team team) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          team.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryGreen, AppTheme.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, team),
          itemBuilder: (context) {
            final currentUserId = ref.watch(authProvider).user?['id'];
            final isCaptain = team.captainId == currentUserId;
            return [
              const PopupMenuItem(value: 'share', child: Text('Share Team')),
              if (isCaptain)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Team', style: TextStyle(color: AppTheme.error)),
                )
              else
                const PopupMenuItem(value: 'leave', child: Text('Leave Team')),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(Team team) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Steps', _formatNumber(team.totalSteps), Icons.directions_walk),
          _buildStatItem('This Week', _formatNumber(team.weeklySteps), Icons.calendar_today),
          _buildStatItem('Rank', '#${team.rank}', Icons.leaderboard),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMemberTile(TeamMember member, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: member.isCaptain 
            ? Border.all(color: AppTheme.accentYellow, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
              backgroundImage: member.avatarUrl != null
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (member.isCaptain)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          member.isCaptain ? 'Team Captain' : 'Member',
          style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(member.weeklySteps),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              'steps this week',
              style: TextStyle(fontSize: 10, color: AppTheme.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(TeamChallenge challenge) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: challenge.isActive 
            ? AppTheme.primaryGradient 
            : null,
        color: challenge.isActive ? null : AppTheme.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: challenge.isActive ? Colors.white : AppTheme.neutral900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(challenge.isActive ? 0.2 : 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: challenge.isActive ? Colors.white : AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: challenge.progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                challenge.isActive ? Colors.white : AppTheme.primaryGreen,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatNumber(challenge.currentSteps)} / ${_formatNumber(challenge.targetSteps)} steps',
            style: TextStyle(
              color: challenge.isActive ? Colors.white70 : AppTheme.neutral500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteSection(Team team) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite Code',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    team.inviteCode ?? '',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: team.inviteCode ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite code copied!')),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Team team) {
    switch (action) {
      case 'share':
        Share.share(
          'Join my team "${team.name}" on Stepify! Use invite code: ${team.inviteCode ?? team.id}',
        );
        break;
      case 'leave':
        _showLeaveConfirmation(team);
        break;
      case 'delete':
        _showDeleteConfirmation(team);
        break;
    }
  }

  void _showDeleteConfirmation(Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team?'),
        content: Text(
          'Are you sure you want to permanently delete "${team.name}"? This action cannot be undone.\n\n'
          'Restrictions:\n'
          '• Only the captain/creator can delete.\n'
          '• Cannot have active challenges.\n'
          '• Cannot have other members in the team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(teamsProvider.notifier).deleteTeam(team.id);
              if (success && mounted) {
                Navigator.pop(context); // Close details page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team deleted successfully')),
                );
              } else if (mounted) {
                final error = ref.read(teamsProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Failed to delete team'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Team?'),
        content: Text('Are you sure you want to leave "${team.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(teamsProvider.notifier).leaveTeam(team.id);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Left team successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
