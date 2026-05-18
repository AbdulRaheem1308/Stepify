import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
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
                    backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
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
                    color: Colors.orange.withOpacity(0.3),
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
                       color: Colors.white.withOpacity(0.2),
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
