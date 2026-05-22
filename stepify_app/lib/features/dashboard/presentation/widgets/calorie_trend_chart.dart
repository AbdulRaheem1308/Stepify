import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class CalorieTrendChart extends StatelessWidget {
  final List<DailyStep> weeklyHistory;

  const CalorieTrendChart({super.key, required this.weeklyHistory});

  @override
  Widget build(BuildContext context) {
    if (weeklyHistory.isEmpty) return const SizedBox.shrink();

    // Estimate calories if not provided (approx 0.04 kcal per step)
    // In a real app, this would come from the backend's 'calories' field directly
    final dataPoints = weeklyHistory.map((e) => Table(
      children: [TableRow(children: [Text('Steps: ${e.steps}'), Text('Cals: ${(e.steps * 0.04).toInt()}')])],
    )).toList();

    // Use a simple bar chart for calories, maybe with a specialized color
    final maxCals = weeklyHistory.fold<double>(0, (max, current) {
      final cals = current.steps * 0.04;
      return cals > max ? cals : max;
    });
    // Fallback to 100 kcal if max is 0 to render clean baseline grid
    final double maxY = maxCals > 0 ? (maxCals * 1.2).toDouble() : 100.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF6B6B), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calorie Burn',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Est. based on steps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutral500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 2.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDark ? AppTheme.neutral800 : Colors.black,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}\n',
                         const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'kcal',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= weeklyHistory.length) return const SizedBox.shrink();
                        final date = weeklyHistory[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat.E().format(date)[0], // M, T, W...
                            style: TextStyle(
                              color: AppTheme.neutral400,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: weeklyHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final cals = item.steps * 0.04; // Simple conversion
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: cals.toDouble(),
                        color: const Color(0xFFFF6B6B),
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: isDark ? Colors.white.withAlpha(15) : AppTheme.neutral50.withAlpha(128),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
