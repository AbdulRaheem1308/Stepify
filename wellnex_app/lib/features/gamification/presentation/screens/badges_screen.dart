import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/badges_provider.dart';

/// Screen 9: Badge & Achievements
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(badgesProvider);
    final allBadges = state.badges;

    // Filtering Logic
    final filteredBadges = state.activeFilter == 'All'
        ? allBadges
        : state.activeFilter == 'Unlocked'
            ? allBadges.where((b) => b.status == BadgeStatus.unlocked).toList()
            : state.activeFilter == 'Locked'
                ? allBadges.where((b) => b.status == BadgeStatus.locked).toList()
                : allBadges.where((b) => b.category == state.activeFilter).toList(); // Simple category match if needed

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.badges),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(context, ref, state.activeFilter, l10n),
          
          const SizedBox(height: 16),
          
          // Badge Grid
          Expanded(
            child: filteredBadges.isEmpty
                ? _buildEmptyState(l10n)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredBadges.length,
                    itemBuilder: (context, index) {
                      final badge = filteredBadges[index];
                      return _buildBadgeItem(context, badge, index, l10n);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, WidgetRef ref, String activeFilter, AppLocalizations l10n) {
    final filters = [
      {'key': 'All', 'label': l10n.filterAll},
      {'key': 'Unlocked', 'label': l10n.filterUnlocked},
      {'key': 'Locked', 'label': l10n.filterLocked},
      {'key': 'Fitness', 'label': l10n.categoryFitness},
      {'key': 'Social', 'label': l10n.categorySocial},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filterObj) {
          final filter = filterObj['key']!;
          final label = filterObj['label']!;
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(badgesProvider.notifier).setFilter(filter);
                }
              },
              backgroundColor: AppTheme.neutral100,
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, Badge badge, int index, AppLocalizations l10n) {
    final isLocked = badge.status == BadgeStatus.locked;
    final inProgress = badge.status == BadgeStatus.inProgress;

    return Semantics(
      label: '${badge.title}. ${isLocked ? l10n.filterLocked : inProgress ? l10n.statusInProgress : l10n.filterUnlocked}.',
      button: true,
      child: GestureDetector(
      onTap: () => _showBadgeDetails(context, badge, l10n),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Badge Icon Container
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isLocked
                        ? []
                        : [
                            BoxShadow(
                              color: _getCategoryColor(badge.category).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: isLocked ? AppTheme.neutral200 : Theme.of(context).colorScheme.surface,
                    child: isLocked
                        ? const Icon(Icons.lock, size: 32, color: AppTheme.neutral400)
                        : Icon(
                            _getBadgeIcon(badge.title),
                            size: 40,
                            color: _getCategoryColor(badge.category),
                          ),
                  ),
                ),
                
                // Progress Ring for In-Progress
                if (inProgress)
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: CircularProgressIndicator(
                      value: badge.progress,
                      strokeWidth: 4,
                      backgroundColor: AppTheme.neutral200,
                      color: AppTheme.accentYellow,
                    ),
                  ),
              ],
            ).animate().scale(delay: (50 * index).ms, duration: 300.ms),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
      ),
      ),
    );
  }
  
  void _showBadgeDetails(BuildContext context, Badge badge, AppLocalizations l10n) {
    final isLocked = badge.status == BadgeStatus.locked;
    final isInProgress = badge.status == BadgeStatus.inProgress;
    final isUnlocked = badge.status == BadgeStatus.unlocked;
    final categoryColor = _getCategoryColor(badge.category);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.neutral300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Badge Icon + Status
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90, height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLocked
                                    ? AppTheme.neutral100
                                    : categoryColor.withValues(alpha: 0.12),
                                boxShadow: isLocked ? [] : [
                                  BoxShadow(
                                    color: categoryColor.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLocked ? Icons.lock_outline : _getBadgeIcon(badge.title),
                                size: 44,
                                color: isLocked ? AppTheme.neutral400 : categoryColor,
                              ),
                            ),
                            if (isInProgress)
                              SizedBox(
                                width: 100, height: 100,
                                child: CircularProgressIndicator(
                                  value: badge.progress,
                                  strokeWidth: 4,
                                  backgroundColor: AppTheme.neutral200,
                                  color: AppTheme.accentYellow,
                                ),
                              ),
                            if (isUnlocked)
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          badge.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: _getStatusColor(badge.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(badge.status).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _getStatusLabel(badge.status, l10n),
                            style: TextStyle(
                              color: _getStatusColor(badge.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.neutral600, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Reward chip
                  if (badge.pointsReward > 0)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color(0xFFD4A017).withValues(alpha: 0.15),
                            const Color(0xFFFFD700).withValues(alpha: 0.1),
                          ]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFD4A017), size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '+${badge.pointsReward} coins on unlock',
                                style: const TextStyle(
                                  color: Color(0xFFD4A017),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Progress section (if in-progress or locked with target)
                  if (!isUnlocked && badge.targetValue != null) ...[
                    Row(
                      children: [
                        Icon(Icons.track_changes, color: categoryColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: badge.progress,
                              backgroundColor: AppTheme.neutral200,
                              color: isInProgress ? AppTheme.accentYellow : AppTheme.neutral300,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${badge.currentValue} / ${badge.targetValue}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge.unlockCriteria,
                      style: const TextStyle(color: AppTheme.neutral500, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // "How to Earn" guide
                  Row(
                    children: [
                      Icon(
                        isUnlocked ? Icons.check_circle : Icons.lightbulb_outline,
                        color: isUnlocked ? AppTheme.success : AppTheme.accentYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUnlocked ? 'How You Earned It' : 'How to Earn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isUnlocked ? AppTheme.success : AppTheme.neutral800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...badge.howToEarn.split('\n').map((step) => step.trim()).where((s) => s.isNotEmpty).map((step) {
                    // Parse step number (e.g., "1. Do something")
                    final dotIdx = step.indexOf('.');
                    final hasNumber = dotIdx > 0 && dotIdx < 3;
                    final stepNum = hasNumber ? step.substring(0, dotIdx) : '';
                    final stepText = hasNumber ? step.substring(dotIdx + 2) : step;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24, height: 24,
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppTheme.success.withValues(alpha: 0.15)
                                  : categoryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                stepNum,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? AppTheme.success : categoryColor,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              stepText,
                              style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.neutral700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Earned date
                  if (isUnlocked && badge.earnedDate != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.neutral500),
                        const SizedBox(width: 6),
                        Text(
                          'Earned on ${_formatDate(badge.earnedDate!)}',
                          style: const TextStyle(color: AppTheme.neutral500, fontSize: 13),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action buttons
                  if (isUnlocked)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.sharingBadge)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.share),
                        label: Text(l10n.shareAchievement, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: categoryColor),
                          foregroundColor: categoryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.directions_walk),
                        label: const Text('Start Walking!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }


  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 64, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text(l10n.noBadgesFound, style: const TextStyle(color: AppTheme.neutral500)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'STEPS':
      case 'DISTANCE':      return AppTheme.primaryGreen;
      case 'STREAK':        return const Color(0xFFFF6B35);  // Orange-red for fire/streak
      case 'CHALLENGE':     return AppTheme.secondaryBlue;
      case 'SOCIAL':        return AppTheme.accentPurple;
      case 'COINS':         return const Color(0xFFD4A017);  // Gold
      case 'COMMUNITY':     return const Color(0xFF00BCD4);  // Cyan
      default:              return AppTheme.accentOrange;
    }
  }


  IconData _getBadgeIcon(String title) {
    final t = title.toLowerCase();
    // Steps / Distance
    if (t.contains('marathon') || t.contains('ultra') || t.contains('50k') || t.contains('100k')) return Icons.directions_run;
    if (t.contains('step') || t.contains('walk') || t.contains('mile') || t.contains('km')) return Icons.directions_walk;
    if (t.contains('distance')) return Icons.straighten;
    // Streak
    if (t.contains('streak') || t.contains('fire') || t.contains('flame')) return Icons.local_fire_department;
    if (t.contains('week') || t.contains('7 day')) return Icons.calendar_view_week;
    if (t.contains('month') || t.contains('30 day')) return Icons.calendar_month;
    // Social
    if (t.contains('friend') || t.contains('squad') || t.contains('social')) return Icons.people;
    if (t.contains('refer') || t.contains('invite')) return Icons.person_add;
    // Challenges
    if (t.contains('challenge') || t.contains('quest')) return Icons.flag;
    if (t.contains('champion') || t.contains('winner')) return Icons.military_tech;
    // Coins / Rewards
    if (t.contains('coin') || t.contains('rich') || t.contains('gold')) return Icons.stars_rounded;
    if (t.contains('reward') || t.contains('redeem')) return Icons.card_giftcard;
    // Time-related
    if (t.contains('early') || t.contains('bird') || t.contains('morning')) return Icons.wb_sunny;
    if (t.contains('night') || t.contains('midnight')) return Icons.nights_stay;
    // General
    if (t.contains('first') || t.contains('beginner') || t.contains('starter')) return Icons.star_border;
    if (t.contains('elite') || t.contains('master') || t.contains('legend')) return Icons.workspace_premium;
    if (t.contains('weekend')) return Icons.weekend;
    return Icons.emoji_events;
  }

  
  Color _getStatusColor(BadgeStatus status) {
    switch (status) {
      case BadgeStatus.unlocked: return AppTheme.success;
      case BadgeStatus.inProgress: return AppTheme.accentYellow;
      case BadgeStatus.locked: return AppTheme.neutral500;
    }
  }
  
  String _getStatusLabel(BadgeStatus status, AppLocalizations l10n) {
    switch (status) {
      case BadgeStatus.unlocked: return l10n.filterUnlocked;
      case BadgeStatus.inProgress: return l10n.statusInProgress;
      case BadgeStatus.locked: return l10n.filterLocked;
    }
  }
}
