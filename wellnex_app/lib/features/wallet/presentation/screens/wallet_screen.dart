import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/wallet_provider.dart';

/// My Wallet Screen
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _filters = [
    TransactionFilter.all,
    TransactionFilter.earned,
    TransactionFilter.redeemed,
  ];

  static const List<String> _filterLabels = ['All', 'Earned', 'Redeemed'];

  // Cache previous balance for smooth counter animation
  int _previousBalance = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    Future.microtask(() {
      if (mounted) {
        ref.read(walletProvider.notifier).fetchWalletData();
      }
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
    final walletState = ref.watch(walletProvider);

    // Show error via SnackBar reactively
    ref.listen<WalletState>(walletProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                ref.read(walletProvider.notifier).fetchWalletData();
              },
            ),
          ),
        );
        ref.read(walletProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletProvider.notifier).fetchWalletData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar with Balance ──
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildBalanceBanner(walletState),
              ),
              title: const Text(
                'My Wallet',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
            ),

            // ── Filter Tabs ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: AppTheme.neutral500,
                  indicatorColor: AppTheme.primaryGreen,
                  indicatorWeight: 3,
                  tabs: _filterLabels
                      .map((label) => Tab(text: label))
                      .toList(),
                ),
              ),
            ),

            // ── Stats Summary ──
            SliverToBoxAdapter(
              child: _buildStatsSummary(walletState),
            ),

            // ── Transaction List / Loading / Empty ──
            if (walletState.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Loading transactions',
                  ),
                ),
              )
            else if (walletState.filteredTransactions.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(walletState.selectedFilter),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tx = walletState.filteredTransactions[index];
                      return _buildTransactionCard(tx, index);
                    },
                    childCount: walletState.filteredTransactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ── Balance Banner ──

  Widget _buildBalanceBanner(WalletState state) {
    // Preserve previous balance so counter animates from the last value, not 0
    final previousBalance = _previousBalance;
    _previousBalance = state.balance;

    final formattedLifetime = _formatNumber(state.lifetimePoints);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Current balance: ${state.balance} coins',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 36,
                      semanticLabel: 'Coin icon',
                    ),
                    const SizedBox(width: 8),
                    TweenAnimationBuilder<int>(
                      key: ValueKey(state.balance), // Reset only when balance changes
                      tween: IntTween(begin: previousBalance, end: state.balance),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Text(
                          _formatNumber(value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'coins',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Lifetime earned: $formattedLifetime coins',
                child: Text(
                  'Lifetime: $formattedLifetime coins earned',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ── Stats Summary Row ──

  Widget _buildStatsSummary(WalletState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.arrow_upward,
              iconColor: AppTheme.success,
              label: 'Total Earned',
              value: '+${_formatNumber(state.totalEarned)}',
              valueColor: AppTheme.success,
              semanticLabel: 'Total earned: ${state.totalEarned} coins',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.arrow_downward,
              iconColor: AppTheme.error,
              label: 'Total Spent',
              value: '-${_formatNumber(state.totalSpent)}',
              valueColor: AppTheme.error,
              semanticLabel: 'Total spent: ${state.totalSpent} coins',
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
    required Color valueColor,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      child: Container(
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
                color: iconColor.withAlpha(26), // ~0.1 opacity
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20, semanticLabel: null),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: AppTheme.neutral500, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Transaction Card ──

  Widget _buildTransactionCard(WalletTransaction tx, int index) {
    final typeColor = _getTypeColor(tx.type);
    final typeIcon = _getTypeIcon(tx.type);
    final label = tx.description ?? _getTypeLabel(tx.type);
    final amountStr = tx.isEarning ? '+${tx.points}' : '${tx.points}';
    final amountColor = tx.isEarning ? AppTheme.success : AppTheme.error;
    final formattedDate = _formatDate(tx.createdAt);

    return Semantics(
      label: '$label, $amountStr coins, $formattedDate',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neutral200),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: typeColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 24, semanticLabel: null),
            ),
            const SizedBox(width: 12),

            // Description + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
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
                  amountStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amountColor,
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
                      semanticLabel: null,
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
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  // ── Helpers ──

  IconData _getTypeIcon(String type) {
    switch (type) {
      case TransactionType.steps:
        return Icons.directions_walk;
      case TransactionType.streakBonus:
        return Icons.local_fire_department;
      case TransactionType.milestone:
        return Icons.emoji_events;
      case TransactionType.adReward:
        return Icons.play_circle_filled;
      case TransactionType.referral:
        return Icons.people;
      case TransactionType.redemption:
        return Icons.card_giftcard;
      default:
        return Icons.stars_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case TransactionType.steps:
        return AppTheme.primaryGreen;
      case TransactionType.streakBonus:
        return AppTheme.accentOrange;
      case TransactionType.milestone:
        return AppTheme.accentPurple;
      case TransactionType.adReward:
        return AppTheme.secondaryBlue;
      case TransactionType.referral:
        return AppTheme.accentPink;
      case TransactionType.redemption:
        return AppTheme.error;
      default:
        return AppTheme.neutral500;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case TransactionType.steps:
        return 'Steps Reward';
      case TransactionType.streakBonus:
        return 'Streak Bonus';
      case TransactionType.milestone:
        return 'Achievement';
      case TransactionType.adReward:
        return 'Watch & Earn';
      case TransactionType.referral:
        return 'Friend Bonus';
      case TransactionType.redemption:
        return 'Redemption';
      default:
        return 'Transaction';
    }
  }

  /// Safe relative date format. Returns positive diff only — handles clock skew.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      // Future date — likely clock skew; show absolute date
      return DateFormat('dd/MM/yyyy').format(date);
    }

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays == 0) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format a number with comma separators (e.g. 10000 → 10,000)
  String _formatNumber(int number) {
    return NumberFormat('#,##0').format(number);
  }

  Widget _buildEmptyState(String filter) {
    final messages = {
      TransactionFilter.earned: ('No earnings yet', 'Start walking to earn coins!'),
      TransactionFilter.redeemed: ('No redemptions yet', 'Spend your coins on great rewards!'),
    };

    final (title, subtitle) = messages[filter] ??
        ('No transactions yet', 'Start walking to earn coins!');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.neutral300,
              semanticLabel: null,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: AppTheme.neutral500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky tab bar delegate for [SliverPersistentHeader]
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
