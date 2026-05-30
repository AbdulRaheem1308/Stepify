import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DailyStatsRow extends StatelessWidget {
  final double distanceKm;
  final int calories;
  final int minutes;

  const DailyStatsRow({
    super.key,
    required this.distanceKm,
    required this.calories,
    required this.minutes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Walked',
            distanceKm.toStringAsFixed(2),
            Icons.directions_walk_rounded,
            AppTheme.secondaryBlue,
            'km',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            context,
            'Burned',
            '$calories',
            Icons.local_fire_department_rounded,
            AppTheme.accentRed,
            'kcal',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            context,
            'Active',
            '$minutes',
            Icons.schedule_rounded,
            AppTheme.primaryGreen,
            'mins',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String unit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.02 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container with soft background tint
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          
          // Value & Unit row baseline aligned
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.blueGrey.shade500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          
          // Label uppercase, spaced out
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: isDark ? Colors.white38 : Colors.blueGrey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

