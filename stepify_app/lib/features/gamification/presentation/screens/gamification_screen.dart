import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/gamification_provider.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          
          if (state.isLoading)
             const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Level Header
                  _buildLevelHeader(context, state),
                  const SizedBox(height: 30),
                  
                  // Stats Grid (Rank & Streak)
                  _buildStatsGrid(context, state),
                  const SizedBox(height: 20),
                  
                  // Adventure Quests Card
                  _buildQuestsCard(context),
                  const SizedBox(height: 30),
                  
                  // Activity Timeline Title
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Timeline - show empty state if no activity
                  if (state.recentActivity.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timeline, size: 48, color: AppTheme.neutral300),
                          const SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: TextStyle(
                              color: AppTheme.neutral500,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start walking to earn XP and see your progress!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.neutral400, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.recentActivity.asMap().entries.map((entry) {
                      return _buildTimelineItem(context, entry.value, entry.key == state.recentActivity.length - 1);
                    }),
                  
                  const SizedBox(height: 40),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          tooltip: 'Rules & Levels',
          onPressed: () => context.push(AppRoutes.xpRules),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Your Journey', style: TextStyle(color: Colors.white)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
               // Decorative pattern
               Positioned(
                 right: -30, top: -50,
                 child: Icon(Icons.star, size: 200, color: Colors.white.withOpacity(0.1)),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context, GamificationState state) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120, height: 120,
              child: CircularProgressIndicator(
                value: state.progress,
                strokeWidth: 10,
                backgroundColor: AppTheme.neutral200,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
              ),
            ),
            Column(
              children: [
                Text(
                  'LEVEL',
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  '${state.level}',
                  style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        
        const SizedBox(height: 16),
        
        Text(
          state.levelTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.neutral900,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          '${state.currentXp} / ${state.nextLevelXp} XP',
          style: TextStyle(color: AppTheme.neutral600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, GamificationState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Global Rank',
            '#${state.globalRank}',
            Icons.public,
            AppTheme.secondaryBlue,
            onTap: () => context.push(AppRoutes.leaderboard),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Streak',
            '${state.currentStreak} Days',
            Icons.local_fire_department,
            AppTheme.accentOrange,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildQuestsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.quests),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.rewardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: AppTheme.accentOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Adventure Quests',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                   SizedBox(height: 4),
                  Text(
                    'Embark on story-driven journeys',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppTheme.neutral500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, ActivityEvent event, bool isLast) {
    // Determine icon and color based on type
    IconData icon;
    Color color;
    switch(event.type) {
      case 'steps': icon = Icons.directions_walk; color = AppTheme.primaryGreen; break;
      case 'streak': icon = Icons.local_fire_department; color = AppTheme.accentOrange; break;
      case 'badge': icon = Icons.emoji_events; color = AppTheme.accentYellow; break;
      case 'challenge': icon = Icons.flag; color = AppTheme.accentPurple; break;
      default: icon = Icons.star; color = AppTheme.secondaryBlue;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppTheme.neutral200.withOpacity(0.5))),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('+${event.xpEarned} XP', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event.description, style: TextStyle(color: AppTheme.neutral600)),
                  const SizedBox(height: 4),
                  Text(_timeAgo(event.timestamp), style: TextStyle(color: AppTheme.neutral400, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
  
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
