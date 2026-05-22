import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badge.status == BadgeStatus.locked ? Icons.lock_outline : _getBadgeIcon(badge.title),
              size: 64,
              color: badge.status == BadgeStatus.locked
                  ? AppTheme.neutral400
                  : _getCategoryColor(badge.category),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(badge.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.neutral600, fontSize: 16),
            ),
            if (badge.status != BadgeStatus.unlocked) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.unlockCriteria),
              Text(
                badge.unlockCriteria,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (badge.status == BadgeStatus.inProgress) ...[ 
                 const SizedBox(height: 12),
                 LinearProgressIndicator(
                   value: badge.progress,
                   backgroundColor: AppTheme.neutral200,
                   color: AppTheme.accentYellow,
                 ),
                 const SizedBox(height: 4),
                 Text(l10n.percentCompleted((badge.progress * 100).toInt())),
              ]
            ],
            const SizedBox(height: 24),
            if (badge.status == BadgeStatus.unlocked)
              ElevatedButton.icon(
                onPressed: () { 
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sharingBadge)));
                },
                icon: const Icon(Icons.share),
                label: Text(l10n.shareAchievement),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
    switch (category) {
      case 'Fitness': return AppTheme.primaryGreen;
      case 'Social': return AppTheme.secondaryBlue;
      case 'Milestone': return AppTheme.accentPurple;
      default: return AppTheme.accentOrange;
    }
  }

  IconData _getBadgeIcon(String title) {
    if (title.contains('Bird')) return Icons.wb_sunny;
    if (title.contains('Marathon')) return Icons.directions_run;
    if (title.contains('Social')) return Icons.people;
    if (title.contains('Streak')) return Icons.local_fire_department;
    if (title.contains('Weekend')) return Icons.weekend;
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
