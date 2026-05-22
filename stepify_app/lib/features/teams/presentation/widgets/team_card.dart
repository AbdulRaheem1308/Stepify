import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/team_model.dart';

/// Team card widget for displaying team info in lists
class TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool showJoinButton;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onJoin,
    this.showJoinButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Team: ${team.name}. ${team.memberCount} of ${team.maxMembers} members. ${team.isPublic ? "Public" : "Private"}.',
      button: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Team avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: team.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(imageUrl: 
                                team.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              team.name.isNotEmpty ? team.name[0].toUpperCase() : 'T',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Team info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: AppTheme.neutral500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${team.memberCount}/${team.maxMembers} members',
                              style: TextStyle(
                                color: AppTheme.neutral500,
                                fontSize: 12,
                              ),
                            ),
                            if (!team.isPublic) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: AppTheme.neutral500,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Join button or arrow
                  if (showJoinButton && !team.isFull)
                    ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Join'),
                    )
                  else if (showJoinButton && team.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neutral200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Full',
                        style: TextStyle(
                          color: AppTheme.neutral500,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.neutral400,
                    ),
                ],
              ),

              // Description
              if (team.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  team.description,
                  style: TextStyle(
                    color: AppTheme.neutral600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Stats row
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    Icons.directions_walk,
                    _formatNumber(team.weeklySteps),
                    'this week',
                  ),
                  const SizedBox(width: 16),
                  if (team.rank > 0)
                    _buildStatChip(
                      Icons.leaderboard,
                      '#${team.rank}',
                      'rank',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.neutral500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
