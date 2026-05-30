import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'explainer_bottom_sheet.dart';

class LevelCoinRow extends StatelessWidget {
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int coins;
  final VoidCallback onLevelTap;
  final VoidCallback onCoinTap;

  const LevelCoinRow({
    super.key,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.coins,
    required this.onLevelTap,
    required this.onCoinTap,
  });

  void _showExplainer(BuildContext context) {
    ExplainerBottomSheet.show(
      context,
      title: 'Level & Wallet',
      headerIcon: Icons.account_balance_wallet,
      primaryColor: const Color(0xFFFF9100), // Orange
      items: const [
        ExplainerItem(
          title: 'WN Coins',
          description: 'Your Currency. Spend coins on real-world rewards, premium challenges, or avatar items. Earned by walking and completing quests.',
          icon: Icons.stars_rounded,
        ),
        ExplainerItem(
          title: 'Experience Points (XP)',
          description: 'Your Status. Experience points determine your Level and Leaderboard rank. XP resets monthly to keep competition fresh!',
          icon: Icons.military_tech,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpProgress = (currentXp / nextLevelXp).clamp(0.0, 1.0);
    final xpPercentage = (xpProgress * 100).toInt();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level Card
        Expanded(
          child: GestureDetector(
            onTap: onLevelTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LVL $level',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$xpPercentage%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _showExplainer(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.08),
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(6),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monthly XP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$currentXp/$nextLevelXp XP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Coin Card
        Expanded(
          child: GestureDetector(
            onTap: onCoinTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              // Fixed height removed; using IntrinsicHeight on parent
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC107), Color(0xFFFF6F00)], // Yellow to Orange
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: Colors.white.withAlpha(51),
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.center,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           '$coins',
                           style: const TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.bold,
                             fontSize: 24,
                           ),
                         ),
                         const Text(
                           'WN Coins',
                           style: TextStyle(
                             color: Colors.white70,
                             fontSize: 12,
                           ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }
}
