import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/friends_provider.dart';

/// Friend Card Widget
class FriendCard extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onTap;
  final VoidCallback? onBoost;

  const FriendCard({
    super.key,
    required this.friend,
    this.onTap,
    this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: friend.isTopFriend
                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                        : AppTheme.primaryGradient,
                  ),
                  child: Center(
                    child: friend.avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(imageUrl: 
                              friend.avatarUrl!,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),
                
                // Top Friend Badge
                if (friend.isTopFriend)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 12),
                    ),
                  ),
                  
                // Rank Badge
                if (friend.rank != null)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _getRankColor(friend.rank!),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${friend.rank}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name and Steps
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.directions_walk, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        l10n.stepsToday(_formatNumber(friend.dailyStepCount)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Boost Button
            GestureDetector(
              onTap: friend.boostSentToday ? null : onBoost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: friend.boostSentToday
                      ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
                      : AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      friend.boostSentToday ? Icons.check : Icons.bolt,
                      color: friend.boostSentToday ? Theme.of(context).disabledColor : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                      Text(
                        friend.boostSentToday ? l10n.boostSentStatus : l10n.boostAction,
                        style: TextStyle(
                          color: friend.boostSentToday ? Theme.of(context).disabledColor : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.neutral500;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
