import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MotivationFooterBanner extends StatelessWidget {
  final int stepsToGo;

  const MotivationFooterBanner({super.key, required this.stepsToGo});

  @override
  Widget build(BuildContext context) {
    if (stepsToGo <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC), // Light Pink/Purple
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: AppTheme.accentRed, size: 20),
              SizedBox(width: 8),
              Text(
                "You're on fire!",
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Just ${stepsToGo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} more steps to go!',
            style: const TextStyle(color: AppTheme.neutral700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
