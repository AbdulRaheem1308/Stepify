import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final type = LeaderboardType.values[_tabController.index];
      ref.read(leaderboardProvider.notifier).setType(type);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.neutral500,
          indicatorColor: AppTheme.primaryGreen,
          tabs: [
            Tab(text: l10n.global),
            Tab(text: l10n.friends),
            const Tab(text: 'Corporate'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time Filters
          _buildTimeFilters(context, state),
          
          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.neutral100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.leaderboard_outlined, size: 48, color: AppTheme.neutral400),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Leaderboard is empty',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start walking to appear here!',
                              style: TextStyle(color: AppTheme.neutral500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(leaderboardProvider.notifier).fetchLeaderboard(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100), // Space for sticky footer
                          itemCount: state.entries.length,
                          itemBuilder: (context, index) {
                            final entry = state.entries[index];
                            return _buildLeaderboardItem(context, entry, index);
                          },
                        ),
                      ),
          ),
          
          // Sticky User Rank
          if (state.currentUserEntry != null)
            _buildStickyRank(context, state.currentUserEntry!),
        ],
      ),
    );
  }

  Widget _buildTimeFilters(BuildContext context, LeaderboardState state) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TimeFrame.values.map((frame) {
          final isSelected = state.timeFrame == frame;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getFrameLabel(frame)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(leaderboardProvider.notifier).setTimeFrame(frame);
                }
              },
              backgroundColor: AppTheme.neutral100,
              selectedColor: AppTheme.primaryGreen.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFrameLabel(TimeFrame frame) {
    switch (frame) {
      case TimeFrame.daily: return 'Today';
      case TimeFrame.weekly: return 'This Week';
      case TimeFrame.monthly: return 'This Month';
      case TimeFrame.allTime: return 'All Time';
    }
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    Color? rankColor;
    if (index == 0) rankColor = const Color(0xFFFFD700); // Gold
    else if (index == 1) rankColor = const Color(0xFFC0C0C0); // Silver
    else if (index == 2) rankColor = const Color(0xFFCD7F32); // Bronze
    else rankColor = AppTheme.neutral500;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppTheme.primaryGreen.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser ? Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            backgroundColor: AppTheme.neutral200,
            child: Text(entry.username[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          
          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (index < 3)
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 14, color: AppTheme.accentOrange),
                      const SizedBox(width: 4),
                      Text('On Fire!', style: TextStyle(color: AppTheme.accentOrange, fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ),
          
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              _buildTrendIcon(entry.trend),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTrendIcon(int trend) {
    if (trend > 0) return const Icon(Icons.arrow_drop_up, color: AppTheme.success, size: 20);
    if (trend < 0) return const Icon(Icons.arrow_drop_down, color: AppTheme.error, size: 20);
    return const Icon(Icons.remove, color: AppTheme.neutral400, size: 16);
  }

  Widget _buildStickyRank(BuildContext context, LeaderboardEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your Rank', style: TextStyle(color: AppTheme.neutral500, fontSize: 12)),
                Text(
                  '#${entry.rank}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryGreen),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${entry.xp} XP',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
             _buildTrendIcon(entry.trend),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 500.ms);
  }
}
