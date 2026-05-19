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
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
