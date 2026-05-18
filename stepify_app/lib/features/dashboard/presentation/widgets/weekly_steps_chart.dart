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
    // Add 20% buffer
    final maxY = (maxSteps * 1.2).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Row(
          //       children: [
          //         Container(
          //           padding: const EdgeInsets.all(8),
          //           decoration: BoxDecoration(
          //             color: AppTheme.secondaryBlue.withOpacity(0.1),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: const Icon(Icons.bar_chart_rounded, color: AppTheme.secondaryBlue, size: 20),
          //         ),
          //         const SizedBox(width: 12),
          //         Text(
          //           'Activity',
          //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //     DropdownButton<String>(
          //       value: 'Week',
          //       items: const [DropdownMenuItem(value: 'Week', child: Text('This Week'))],
          //       onChanged: (_) {},
          //       underline: const SizedBox(),
          //       style: TextStyle(color: AppTheme.neutral500, fontSize: 13, fontWeight: FontWeight.w500),
          //       icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 2.2,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.neutral800,
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
                        final isToday = value.toInt() == weeklyHistory.length - 1;
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
                    color: AppTheme.neutral100,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyHistory.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isToday = index == weeklyHistory.length - 1;
                  
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
                                colors: [AppTheme.secondaryBlue.withOpacity(0.5), AppTheme.secondaryBlue.withOpacity(0.8)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppTheme.neutral50.withOpacity(0.5),
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
