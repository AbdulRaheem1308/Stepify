import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/rewards_catalog_provider.dart';

/// Reward Card Widget for catalog display
class RewardCard extends StatelessWidget {
  final Reward reward;
  final VoidCallback? onTap;
  final VoidCallback? onRedeem;

  const RewardCard({
    super.key,
    required this.reward,
    this.onTap,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neutral200),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutral200.withValues(alpha: 0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Partner Section - Fixed height
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: _getCategoryGradient(reward.category),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Category Icon
                  Center(
                    child: Icon(
                      _getCategoryIcon(reward.category),
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 40,
                    ),
                  ),
                  
                  // Partner Name
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        reward.partnerName ?? 'Well Nex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Limited Edition Badge
                  if (reward.isLimitedEdition)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.local_fire_department, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content - Expanded to fill remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reward.description,
                          style: TextStyle(
                            color: AppTheme.neutral500,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    // Cost & Redeem Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Coin Cost
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: AppTheme.accentYellow,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${reward.coinCost}',
                              style: TextStyle(
                                color: reward.canAfford ? AppTheme.neutral800 : AppTheme.neutral500,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        
                        // Redeem Button
                        GestureDetector(
                          onTap: reward.canAfford && reward.inStock ? onRedeem : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: reward.canAfford && reward.inStock
                                  ? AppTheme.primaryGreen
                                  : AppTheme.neutral300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Redeem',
                              style: TextStyle(
                                color: reward.canAfford && reward.inStock
                                    ? Colors.white
                                    : AppTheme.neutral500,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category.toUpperCase()) {
      case 'FITNESS':
        return AppTheme.primaryGradient;
      case 'FOOD':
        return const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]);
      case 'ENTERTAINMENT':
        return const LinearGradient(colors: [AppTheme.accentPurple, AppTheme.accentPink]);
      case 'SHOPPING':
        return const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]);
      case 'TRAVEL':
        return const LinearGradient(colors: [AppTheme.secondaryBlue, Color(0xFF42A5F5)]);
      case 'LIFESTYLE':
        return const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]);
      default:
        return const LinearGradient(colors: [AppTheme.neutral500, AppTheme.neutral400]);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FITNESS':
        return Icons.fitness_center;
      case 'FOOD':
        return Icons.restaurant;
      case 'ENTERTAINMENT':
        return Icons.movie;
      case 'SHOPPING':
        return Icons.shopping_bag;
      case 'TRAVEL':
        return Icons.flight;
      case 'LIFESTYLE':
        return Icons.spa;
      default:
        return Icons.card_giftcard;
    }
  }
}
