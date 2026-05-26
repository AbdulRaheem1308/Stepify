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
          title: 'Stepify Coins',
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

    return Row(
      children: [
        // Level Card
        Expanded(
          child: GestureDetector(
            onTap: onLevelTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 100, // Fixed height for alignment
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '$xpPercentage%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: xpProgress,
                        backgroundColor: Theme.of(context).dividerColor.withAlpha(77),
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Experience Points',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: IconButton(
                      icon: Icon(Icons.info_outline, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                      onPressed: () => _showExplainer(context),
                      tooltip: 'How it works',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
              height: 100,
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
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
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
                         'Stepify Coins',
                         style: TextStyle(
                           color: Colors.white70,
                           fontSize: 12,
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
