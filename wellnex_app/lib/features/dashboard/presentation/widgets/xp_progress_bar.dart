import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated XP Progress Bar widget
class XpProgressBar extends StatelessWidget {
  final int level;
  final int currentProgress; // 0-100
  final int xpToNextLevel;

  const XpProgressBar({
    super.key,
    required this.level,
    required this.currentProgress,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentPurple.withAlpha(51)),
      ),
      child: Row(
        children: [
          // Level Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentPurple, AppTheme.accentPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Lv.$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Progress Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Experience',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$currentProgress%',
                      style: TextStyle(
                        color: AppTheme.accentPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: currentProgress / 100),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppTheme.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentPurple,
                        ),
                        minHeight: 8,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 4),
                Text(
                  '$xpToNextLevel XP to Level ${level + 1}',
                  style: TextStyle(
                    color: AppTheme.neutral500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
