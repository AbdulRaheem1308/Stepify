import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/rewards_catalog_provider.dart';
import '../widgets/reward_card.dart';

/// Rewards Catalog Screen (Screen 4)
class RewardsCatalogScreen extends ConsumerStatefulWidget {
  const RewardsCatalogScreen({super.key});

  @override
  ConsumerState<RewardsCatalogScreen> createState() => _RewardsCatalogScreenState();
}

class _RewardsCatalogScreenState extends ConsumerState<RewardsCatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Fetch data
    Future.microtask(() {
      ref.read(rewardsCatalogProvider.notifier).fetchCatalog();
      ref.read(rewardsCatalogProvider.notifier).fetchMyOffers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showRedemptionConfirmation(Reward reward) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildRedemptionSheet(ctx, reward),
    );
  }

  Widget _buildRedemptionSheet(BuildContext context, Reward reward) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: AppTheme.primaryGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Redeem Reward?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Reward Info
          Text(
            reward.title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Cost display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.accentYellow, size: 28),
                const SizedBox(width: 8),
                Text(
                  '${reward.coinCost} coins',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'This will be deducted from your wallet',
            style: TextStyle(color: AppTheme.neutral500, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.neutral300),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _processRedemption(reward);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Future<void> _processRedemption(Reward reward) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ref.read(rewardsCatalogProvider.notifier).redeemReward(reward.id);

    // Hide loading
    if (mounted) Navigator.pop(context);

    if (result != null && result['success'] == true) {
      // Success!
      _confettiController.play();
      _showSuccessDialog(reward, result['voucherCode'] ?? 'N/A');
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redemption failed. Please try again.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showSuccessDialog(Reward reward, String voucherCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Redemption Successful!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(reward.title, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Your Voucher Code:', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    voucherCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Check "My Offers" to view your reward',
              style: TextStyle(color: AppTheme.neutral500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tabController.animateTo(1); // Switch to My Offers tab
            },
            child: const Text('View My Offers'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.neutral500,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Catalog'),
            Tab(text: 'My Offers'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Catalog Tab
              _buildCatalogTab(state),

              // My Offers Tab
              _buildMyOffersTab(state),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryGreen,
                AppTheme.accentYellow,
                AppTheme.accentPurple,
                AppTheme.secondaryBlue,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab(RewardsCatalogState state) {
    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rewardCategories.length,
            itemBuilder: (context, index) {
              final category = rewardCategories[index];
              final isSelected = state.selectedCategory == category;

              return GestureDetector(
                onTap: () => ref.read(rewardsCatalogProvider.notifier).setCategory(category),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.neutral600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Rewards Grid
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.rewards.isEmpty
                  ? _buildEmptyState('No rewards available', 'Check back later!')
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(rewardsCatalogProvider.notifier)
                          .fetchCatalog(category: state.selectedCategory),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: state.rewards.length,
                        itemBuilder: (context, index) {
                          final reward = state.rewards[index];
                          return RewardCard(
                            reward: reward,
                            onTap: () => _showRedemptionConfirmation(reward),
                            onRedeem: () => _showRedemptionConfirmation(reward),
                          ).animate(delay: (index * 50).ms)
                              .fadeIn(duration: 300.ms)
                              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMyOffersTab(RewardsCatalogState state) {
    if (state.myOffers.isEmpty) {
      return _buildEmptyState('No redeemed rewards', 'Redeem rewards to see them here');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(rewardsCatalogProvider.notifier).fetchMyOffers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.myOffers.length,
        itemBuilder: (context, index) {
          final redemption = state.myOffers[index];
          return _buildMyOfferCard(redemption).animate(delay: (index * 100).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildMyOfferCard(UserRedemption redemption) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_giftcard, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.reward.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${redemption.voucherCode ?? 'N/A'}',
                  style: TextStyle(
                    color: AppTheme.neutral600,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                if (redemption.expiresAt != null)
                  Text(
                    'Expires: ${_formatDate(redemption.expiresAt!)}',
                    style: TextStyle(color: AppTheme.neutral500, fontSize: 11),
                  ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(redemption.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              redemption.status,
              style: TextStyle(
                color: _getStatusColor(redemption.status),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.success;
      case 'USED':
        return AppTheme.neutral500;
      case 'EXPIRED':
        return AppTheme.error;
      default:
        return AppTheme.neutral500;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard_outlined, size: 80, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.neutral500),
          ),
        ],
      ),
    );
  }
}
