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
        Expanded(child: _buildStatItem(context, 'km walked', '${distanceKm.toStringAsFixed(2)}', Icons.location_on_outlined, AppTheme.secondaryBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(context, 'calories', '$calories', Icons.flash_on_outlined, AppTheme.accentRed)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(context, 'minutes', '$minutes', Icons.timer_outlined, AppTheme.primaryGreen)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
