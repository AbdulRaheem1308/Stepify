import 'package:flutter/material.dart';
import 'explainer_bottom_sheet.dart';

class StreakBanner extends StatelessWidget {
  final int streakDays;
  final int bestStreak;
  final VoidCallback onTap;

  const StreakBanner({
    super.key,
    required this.streakDays,
    required this.bestStreak,
    required this.onTap,
  });

  void _showExplainer(BuildContext context) {
    ExplainerBottomSheet.show(
      context,
      title: 'Daily Streaks',
      headerIcon: Icons.local_fire_department,
      primaryColor: const Color(0xFFFF9100), // Orange
      items: const [
        ExplainerItem(
          title: 'Keep the Flame Alive',
          description: 'Hit your daily step goal before midnight (in your local timezone) to keep your streak going.',
        ),
        ExplainerItem(
          title: 'Don\'t Miss a Day!',
          description: 'If you miss a single day, your current streak will reset to zero! Can you beat your personal best?',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF44336), Color(0xFFFF9100)], // Red to Orange
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF44336).withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$streakDays days',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showExplainer(context),
                        child: const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$bestStreak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Best Streak',
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
    );
  }
}
