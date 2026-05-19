import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../services/storage_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/presentation/providers/streak_provider.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';
import '../../../gamification/presentation/providers/badges_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';


/// Screen 24: Enhanced User Profile (Pro Version)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = StorageService.getUser();
    final streak = ref.watch(streakProvider).currentStreak;
    final level = ref.watch(gamificationProvider).level;

    // Listen for badge errors
    ref.listen(badgesProvider, (prev, next) {
      if (!next.isLoading && next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: Column(
        children: [
          _buildCompactHeader(context, user, streak, level),
          Container(
            color: AppTheme.primaryDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentYellow,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Badges'),
                Tab(text: 'Activity'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildBadgesPreviewTab(),
                _buildMilestonesTab(),
                _buildPrivacySettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, Map<String, dynamic>? user, int streak, int level) {
    final dashboard = ref.watch(dashboardProvider);
    final badgeCount = ref.watch(badgesProvider).badges.where((b) => b.status == BadgeStatus.unlocked).length;
    final totalSteps = dashboard.todaySteps?.stepCount ?? 0;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Builder(
                    builder: (context) {
                      final avatarUrl = user?['avatarUrl'];
                      final hasAvatar = avatarUrl != null && avatarUrl != 'default';
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white24,
                          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                          child: hasAvatar
                              ? null
                              : Text(
                                  user?['name']?[0] ?? 'G',
                                  style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      );
                    }
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.editProfile),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentYellow, 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 12, color: AppTheme.primaryDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?['name'] ?? 'Guest User',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $level  •  Joined Jan 2026',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Settings Button
              IconButton(
                onPressed: () => context.push(AppRoutes.settings),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('$streak', 'Day Streak', Icons.local_fire_department),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildHeaderStat(_formatSteps(totalSteps), 'Total Steps', Icons.directions_walk),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildHeaderStat('$badgeCount', 'Badges', Icons.military_tech),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000000) return '${(steps / 1000000).toStringAsFixed(1)}M';
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(0)}k';
    return '$steps';
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final dashboardState = ref.watch(dashboardProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (dashboardState.userStats != null)
          _buildLifetimeStats(dashboardState.userStats!),
      ],
    );
  }

  Widget _buildLifetimeStats(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lifetime Achievements'),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                   Expanded(
                     child: _buildStatItem(
                       'Total Steps', 
                       _formatSteps(stats['lifetimeSteps'] ?? 0), 
                       Icons.directions_walk,
                       AppTheme.primaryGreen
                     ),
                   ),
                   Expanded(
                     child: _buildStatItem(
                       'Best Day', 
                       _formatSteps(stats['bestDaySteps'] ?? 0), 
                       Icons.emoji_events,
                       AppTheme.accentOrange
                     ),
                   ),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                   Expanded(
                     child: _buildStatItem(
                       'Total Distance', 
                       '${(double.tryParse(stats['lifetimeDistanceKm']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1)} km', 
                       Icons.map,
                       AppTheme.accentPurple
                     ),
                   ),
                   Expanded(
                     child: _buildStatItem(
                       'Calories', 
                       '${(stats['lifetimeCalories'] ?? 0) ~/ 1000}k', 
                       Icons.local_fire_department,
                       AppTheme.error
                     ),
                   ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: AppTheme.neutral500, fontSize: 12)),
      ],
    );
  }



  Widget _buildBadgesPreviewTab() {
     final state = ref.watch(badgesProvider);
     final badges = state.badges; // Show all by default or filter for 'unlocked' if desired
     
     if (badges.isEmpty) return const Center(child: Text('No badges yet'));
     
     return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          // Re-using logic from BadgesScreen for consistency (simplified)
          final isLocked = badge.status == BadgeStatus.locked;
          
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isLocked ? [] : [
                      BoxShadow(color: AppTheme.accentOrange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isLocked ? AppTheme.neutral200 : Colors.white,
                    child: Icon(
                      isLocked ? Icons.lock : Icons.emoji_events, 
                      size: 24, 
                      color: isLocked ? AppTheme.neutral400 : AppTheme.accentOrange
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2,
              ),
            ],
          );
        },
     );
  }

  Widget _buildMilestonesTab() {
    final state = ref.watch(badgesProvider);
    // Filter for unlocked badges
    final unlockedBadges = state.badges.where((b) => b.status == BadgeStatus.unlocked).toList();
    
    if (unlockedBadges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: AppTheme.neutral300),
            SizedBox(height: 16),
            Text('No milestones yet', style: TextStyle(color: AppTheme.neutral500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: unlockedBadges.length,
      itemBuilder: (context, index) {
        final badge = unlockedBadges[index];
        return Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag, color: AppTheme.accentPurple),
              ),
              title: Text(badge.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(badge.description),
              trailing: Text(
                'Unlocked', 
                style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
              ),
            ),
            if (index < unlockedBadges.length - 1)
              const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildPrivacySettingsTab() {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle('Corporate Wellness'),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: AppTheme.primaryGreen.withOpacity(0.05),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.business, color: AppTheme.primaryGreen),
          ),
          title: const Text('My Company', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('View leaderboard and challenges'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.neutral400),
          onTap: () {
            // Check if user is already in a company (logic usually in provider/local storage)
            // For now, let's navigate to dashboard which handles "not a member" state or redirects
            // Ideally we check `ref.read(companyProvider).member` but it might not be loaded yet.
            // Let's just go to Join screen for demo if we don't know, or let dashboard redirect.
             context.push(AppRoutes.companyJoin); 
             // Ideally: context.push(AppRoutes.companyDashboard); 
             // but 'companyJoin' is safer entry point which can check status or let user enter code.
          },
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Privacy & Visibility'),
        SwitchListTile(
          value: settings.isPublic,
          onChanged: notifier.togglePublicProfile,
          title: const Text('Public Profile'),
          subtitle: const Text('Allow others to view your profile details'),
          activeColor: AppTheme.primaryGreen,
        ),
        SwitchListTile(
          value: settings.showOnLeaderboard,
          onChanged: notifier.toggleShowOnLeaderboard,
          title: const Text('Show on Leaderboards'),
          subtitle: const Text('Compete with community and friends'),
          activeColor: AppTheme.primaryGreen,
        ),
        SwitchListTile(
          value: settings.showMilestones,
          onChanged: notifier.toggleShowMilestones,
          title: const Text('Share Milestones'),
          subtitle: const Text('Auto-post achievements to community feed'),
          activeColor: AppTheme.primaryGreen,
        ),
        const Divider(height: 32),
        _buildSectionTitle('Account'),
        ListTile(
          leading: const Icon(Icons.logout, color: AppTheme.error),
          title: const Text('Logout', style: TextStyle(color: AppTheme.error)),
          onTap: () async {
             await ref.read(authProvider.notifier).logout();
             if (mounted) context.go(AppRoutes.login);
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
