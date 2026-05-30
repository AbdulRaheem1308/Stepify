import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/api_service.dart';
import '../providers/streak_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/widgets/weekly_steps_chart.dart';

/// Screen 14: Streak History - Enhanced UX
class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  List<Map<String, dynamic>> _streakAchievements = [];
  int _monthOffset = 0; // 0 = current month, 1 = last month, etc. (max 5 = 6 months back)

  @override
  void initState() {
    super.initState();
    _fetchStreakAchievements();
  }

  Future<void> _fetchStreakAchievements() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/rewards/achievements');
      final achievements = List<Map<String, dynamic>>.from(response.data ?? []);
      
      // Filter only STREAK category achievements
      final streakOnly = achievements
          .where((a) => a['category'] == 'STREAK')
          .toList()
        ..sort((a, b) => (a['streakRequired'] ?? 0).compareTo(b['streakRequired'] ?? 0));
      
      
      setState(() {
        _streakAchievements = streakOnly;
      });
    } catch (e) {
      debugPrint('Error fetching streak achievements: $e');
      // Keep empty on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(streakProvider);
    final dashboardState = ref.watch(dashboardProvider);
    
    // Use dashboard streak data for header (synced with home screen)
    // Use streakProvider for calendar activity dates
    final currentStreak = dashboardState.streak?.currentStreak ?? state.currentStreak;
    final longestStreak = dashboardState.streak?.longestStreak ?? state.longestStreak;

    if (state.isLoading && dashboardState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.streakHistory)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Compact header with streak info (using dashboard synced data)
          _buildHeader(context, currentStreak, longestStreak, l10n),
          
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Weekly Activity Chart
                if (dashboardState.weeklyHistory.isNotEmpty) ...[
                  _buildSectionHeader(l10n.thisWeeksActivity, Icons.bar_chart),
                  const SizedBox(height: 12),
                  WeeklyStepsChart(weeklyHistory: dashboardState.weeklyHistory),
                  const SizedBox(height: 24),
                ],

                // Calendar Heatmap with period toggle
                _buildCalendarHeader(l10n),
                const SizedBox(height: 12),
                _buildSingleMonthCalendar(context, state.activeDates, l10n),
                const SizedBox(height: 24),

                // Streak Achievements (from database)
                _buildSectionHeader(l10n.streakAchievements, Icons.emoji_events),
                const SizedBox(height: 12),
                if (_streakAchievements.isNotEmpty)
                  _buildStreakAchievements(context, state, l10n)
                else
                  _buildEmptyAchievements(l10n),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int currentStreak, int longestStreak, AppLocalizations l10n) {
    final isActive = currentStreak > 0;
    
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: isActive ? AppTheme.accentOrange : AppTheme.neutral600,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(l10n.streakHistory, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive 
                  ? [AppTheme.accentOrange.withValues(alpha: 0.9), AppTheme.primaryGreen.withValues(alpha: 0.8)]
                  : [AppTheme.neutral500, AppTheme.neutral700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fire icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 32,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 600.ms),
                  const SizedBox(width: 16),
                  // Streak info
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$currentStreak',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'days',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.bestStreak(longestStreak),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.neutral600),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAchievements(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 48, color: AppTheme.neutral400),
          const SizedBox(height: 12),
          Text(
            l10n.noStreakAchievements,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.keepWalkingStreak,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(AppLocalizations l10n) {
    final today = DateTime.now();
    final selectedMonth = DateTime(today.year, today.month - _monthOffset, 1);
    final monthNames = List.generate(12, (i) => DateFormat.MMMM().format(DateTime(2024, i + 1, 1)));
    
    return Row(
      children: [
        Icon(Icons.calendar_month, size: 20, color: AppTheme.neutral600),
        const SizedBox(width: 8),
        Text(
          l10n.activity,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Month navigation
        Container(
          decoration: BoxDecoration(
            color: AppTheme.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Previous month
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: _monthOffset < 5 ? AppTheme.neutral700 : AppTheme.neutral300),
                onPressed: _monthOffset < 5 ? () => setState(() => _monthOffset++) : null,
                padding: EdgeInsets.zero,
                tooltip: 'Previous Month',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Current month label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _monthOffset == 0 ? AppTheme.primaryGreen : AppTheme.neutral700,
                  ),
                ),
              ),
              // Next month
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: _monthOffset > 0 ? AppTheme.neutral700 : AppTheme.neutral300),
                onPressed: _monthOffset > 0 ? () => setState(() => _monthOffset--) : null,
                padding: EdgeInsets.zero,
                tooltip: 'Next Month',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleMonthCalendar(BuildContext context, List<DateTime> activeDates, AppLocalizations l10n) {
    final today = DateTime.now();
    final selectedMonth = DateTime(today.year, today.month - _monthOffset, 1);
    final isCurrentMonth = _monthOffset == 0;
    
    return _buildMonthCard(context, selectedMonth, activeDates, isCurrentMonth, l10n);
  }

  Widget _buildMonthCard(BuildContext context, DateTime month, List<DateTime> activeDates, bool isCurrentMonth, AppLocalizations l10n) {
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate padding for first day (Monday = 0, Sunday = 6)
    final firstWeekday = (firstDayOfMonth.weekday - 1) % 7;
    
    // Count active days in this month
    final activeDaysInMonth = activeDates.where((d) => 
      d.month == month.month && d.year == month.year
    ).length;
    
    // Use DateFormat for localized names
    final weekDays = List.generate(7, (i) => DateFormat.E().format(DateTime(2024, 1, i + 1)).substring(0, 1));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrentMonth ? AppTheme.primaryGreen.withValues(alpha: 0.3) : AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat.yMMMM().format(month),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCurrentMonth ? AppTheme.primaryGreen : AppTheme.neutral700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: activeDaysInMonth > 0 
                      ? AppTheme.primaryGreen.withValues(alpha: 0.1) 
                      : AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.activeDays(activeDaysInMonth),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: activeDaysInMonth > 0 ? AppTheme.primaryGreen : AppTheme.neutral500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => SizedBox(
              width: 28,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: AppTheme.neutral400,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.2,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells for padding
              if (index < firstWeekday) {
                return const SizedBox();
              }
              
              final day = index - firstWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              final isToday = date.day == today.day && 
                             date.month == today.month && 
                             date.year == today.year;
              final isActive = activeDates.any((d) => 
                  d.year == date.year && d.month == date.month && d.day == date.day);
              final isFuture = date.isAfter(today);

              Color bgColor;
              Color textColor;
              if (isFuture) {
                bgColor = AppTheme.neutral50;
                textColor = AppTheme.neutral300;
              } else if (isActive) {
                bgColor = AppTheme.primaryGreen;
                textColor = Colors.white;
              } else {
                bgColor = AppTheme.neutral100;
                textColor = AppTheme.neutral500;
              }

              return Semantics(
                label: '$day. ${isActive ? 'Active' : isFuture ? 'Future' : 'Inactive'}',
                child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: isToday 
                      ? Border.all(color: AppTheme.accentOrange, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isToday || isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * (isCurrentMonth ? 0 : 1)).ms);
  }

  Widget _buildLegendItem(String label, Color color, {bool isBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakAchievements(BuildContext context, StreakState state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        children: _streakAchievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          final days = achievement['streakRequired'] ?? 0;
          final name = achievement['name'] ?? 'Streak Badge';
          final description = achievement['description'] ?? '';
          final unlocked = achievement['unlocked'] ?? false;
          final progress = achievement['progress'] ?? 0;
          final iconName = achievement['icon'] ?? 'local_fire_department';

          return Semantics(
            label: '$name. $description. ${unlocked ? "Unlocked" : "$progress% complete"}.',
            child: Column(
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: unlocked 
                          ? AppTheme.accentYellow.withValues(alpha: 0.2)
                          : AppTheme.neutral100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForName(iconName),
                      color: unlocked ? AppTheme.accentYellow : AppTheme.neutral400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: unlocked ? AppTheme.neutral800 : AppTheme.neutral600,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.neutral500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: AppTheme.neutral100,
                            valueColor: AlwaysStoppedAnimation(
                              unlocked ? AppTheme.primaryGreen : AppTheme.secondaryBlue,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status
                  if (unlocked)
                    const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20)
                  else
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.secondaryBlue,
                      ),
                    ),
                ],
              ),
              if (index < _streakAchievements.length - 1)
                const Divider(height: 16),
            ],
          ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  IconData _getIconForName(String iconName) {
    final iconMap = {
      'local_fire_department': Icons.local_fire_department,
      'calendar_today': Icons.calendar_today,
      'trending_up': Icons.trending_up,
      'whatshot': Icons.whatshot,
      'emoji_events': Icons.emoji_events,
      'military_tech': Icons.military_tech,
      'star': Icons.star,
      'star_outline': Icons.star_outline,
    };
    return iconMap[iconName] ?? Icons.local_fire_department;
  }
}
