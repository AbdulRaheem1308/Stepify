import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/wallet_provider.dart';

/// My Wallet Screen (Screen 6)
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['ALL', 'EARNED', 'REDEEMED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    Future.microtask(() {
      ref.read(walletProvider.notifier).fetchWalletData();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(walletProvider.notifier).setFilter(_filters[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).fetchWalletData(),
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Balance
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildBalanceBanner(state),
              ),
              title: const Text('My Wallet'),
              centerTitle: true,
            ),

            // Filter Tabs
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: AppTheme.neutral500,
                  indicatorColor: AppTheme.primaryGreen,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Earned'),
                    Tab(text: 'Redeemed'),
                  ],
                ),
              ),
            ),

            // Stats Summary
            SliverToBoxAdapter(
              child: _buildStatsSummary(state),
            ),

            // Transaction List
            state.isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : state.filteredTransactions.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final tx = state.filteredTransactions[index];
                              return _buildTransactionCard(tx, index);
                            },
                            childCount: state.filteredTransactions.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBanner(WalletState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 36),
                  const SizedBox(width: 8),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: state.balance),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'coins',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lifetime: ${state.lifetimePoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} coins earned',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(WalletState state) {
    final earned = state.transactions.where((t) => t.isEarning).fold<int>(0, (sum, t) => sum + t.points);
    final spent = state.transactions.where((t) => t.isRedemption).fold<int>(0, (sum, t) => sum + t.points.abs());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.arrow_upward,
              iconColor: AppTheme.success,
              label: 'Total Earned',
              value: '+$earned',
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.arrow_downward,
              iconColor: AppTheme.error,
              label: 'Total Spent',
              value: '-$spent',
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppTheme.neutral500, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction tx, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTypeColor(tx.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(tx.type),
              color: _getTypeColor(tx.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? _getTypeLabel(tx.type),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(tx.createdAt),
                  style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.isEarning ? '+${tx.points}' : '${tx.points}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: tx.isEarning ? AppTheme.success : AppTheme.error,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    size: 12,
                    color: AppTheme.accentYellow,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'coins',
                    style: TextStyle(color: AppTheme.neutral500, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'STEPS':
        return Icons.directions_walk;
      case 'STREAK_BONUS':
        return Icons.local_fire_department;
      case 'MILESTONE':
        return Icons.emoji_events;
      case 'AD_REWARD':
        return Icons.play_circle_filled;
      case 'REFERRAL':
        return Icons.people;
      case 'REDEMPTION':
        return Icons.card_giftcard;
      default:
        return Icons.stars_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'STEPS':
        return AppTheme.primaryGreen;
      case 'STREAK_BONUS':
        return AppTheme.accentOrange;
      case 'MILESTONE':
        return AppTheme.accentPurple;
      case 'AD_REWARD':
        return AppTheme.secondaryBlue;
      case 'REFERRAL':
        return AppTheme.accentPink;
      case 'REDEMPTION':
        return AppTheme.error;
      default:
        return AppTheme.neutral500;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'STEPS':
        return 'Steps Reward';
      case 'STREAK_BONUS':
        return 'Streak Bonus';
      case 'MILESTONE':
        return 'Achievement';
      case 'AD_REWARD':
        return 'Watch & Earn';
      case 'REFERRAL':
        return 'Friend Bonus';
      case 'REDEMPTION':
        return 'Redemption';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} min ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start walking to earn coins!',
            style: TextStyle(color: AppTheme.neutral500),
          ),
        ],
      ),
    );
  }
}

/// Tab Bar Delegate for sticky tabs
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
