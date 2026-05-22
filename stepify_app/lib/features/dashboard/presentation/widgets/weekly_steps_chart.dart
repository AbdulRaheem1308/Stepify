import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dashboard_provider.dart';

class WeeklyStepsChart extends StatelessWidget {
  final List<DailyStep> weeklyHistory;

  const WeeklyStepsChart({super.key, required this.weeklyHistory});

  @override
  Widget build(BuildContext context) {
    if (weeklyHistory.isEmpty) return const SizedBox.shrink();

    // Find max steps for Y-axis scaling
    final maxSteps = weeklyHistory.fold<int>(0, (max, current) => current.steps > max ? current.steps : max);
    // Add 20% buffer, fallback to 1000 steps if max is 0 to render clean baseline grid
    final double maxY = maxSteps > 0 ? (maxSteps * 1.2).toDouble() : 1000.0;

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
          AspectRatio(
            aspectRatio: 2.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDark ? AppTheme.neutral800 : Colors.black,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 8,
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
                            text: 'steps',
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
                        final now = DateTime.now();
                        final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                        return Padding(
                           padding: const EdgeInsets.only(top: 8),
                           child: Text(
                             DateFormat.E().format(date).toUpperCase(), // MON, TUE...
                             style: TextStyle(
                               color: isToday ? AppTheme.primaryGreen : AppTheme.neutral400,
                               fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                               fontSize: 10,
                             ),
                           ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor.withAlpha(51),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final now = DateTime.now();
                  final isToday = item.date.day == now.day && item.date.month == now.month && item.date.year == now.year;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.steps.toDouble(),
                        gradient: isToday
                            ? const LinearGradient(
                                colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : LinearGradient(
                                colors: [AppTheme.secondaryBlue.withAlpha(128), AppTheme.secondaryBlue.withAlpha(204)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
