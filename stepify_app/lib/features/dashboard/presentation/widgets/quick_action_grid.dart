import 'package:flutter/material.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback onChallengesTap;
  final VoidCallback onOffersTap;
  final VoidCallback onCommunityTap;
  final VoidCallback? onTeamsTap;
  final VoidCallback? onActivitiesTap;
  final VoidCallback? onHistoryTap;

  const QuickActionGrid({
    super.key,
    required this.onChallengesTap,
    required this.onOffersTap,
    required this.onCommunityTap,
    this.onTeamsTap,
    this.onActivitiesTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildActionItem(
                context,
                l10n.challenges,
                l10n.viewActive,
                Icons.emoji_events,
                const Color(0xFFFF6F00), // Orange
                onChallengesTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionItem(
                context,
                'Teams',
                'Compete',
                Icons.groups,
                const Color(0xFF009688), // Teal
                onTeamsTap ?? () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionItem(
                context,
                l10n.earnOffers,
                l10n.watchAdsDeals, // Shortened
                Icons.local_offer,
                const Color(0xFFE91E63), // Pink
                onOffersTap,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 12),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       child: _buildActionItem(
        //         context,
        //         l10n.community,
        //         l10n.feedMilestones, // Shortened for 3-col
        //         Icons.public,
        //         const Color(0xFF3F51B5), // Indigo
        //         onCommunityTap,
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _buildActionItem(
        //         context,
        //         'Log',
        //         '+ Points',
        //         Icons.directions_run_rounded,
        //         const Color(0xFF9C27B0), // Purple
        //         onActivitiesTap ?? () {},
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: _buildActionItem(
        //         context,
        //         'History',
        //         'Past',
        //         Icons.history_rounded,
        //         const Color(0xFF607D8B), // Blue Grey
        //         onHistoryTap ?? () {},
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
