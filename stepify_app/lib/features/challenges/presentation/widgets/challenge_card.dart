import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/challenges_provider.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final int? currentSteps;
  final int? progress;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.currentSteps,
    this.progress,
    this.isJoined = false,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _getAccentColor(challenge.challengeType);
    final isCompleted = isJoined && (progress ?? 0) >= 100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left accent strip
                Container(
                  width: 5,
                  color: accentColor,
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: Title + Tags
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(challenge.challengeType),
                                color: accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Theme.of(context).textTheme.titleMedium?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      _buildSmallTag(challenge.difficulty, _getDifficultyColor(challenge.difficulty)),
                                      const SizedBox(width: 8),
                                      _buildSmallTag(challenge.challengeType, accentColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Stats Row: Steps + Coins + Days
                        Row(
                          children: [
                            _buildStatChip(Icons.directions_walk, '${_formatNumber(challenge.stepTarget)}', 'steps', AppTheme.secondaryBlue),
                            const SizedBox(width: 10),
                            _buildStatChip(Icons.stars_rounded, '${challenge.rewardCoins}', 'coins', const Color(0xFFD4A017)),
                            const SizedBox(width: 10),
                            _buildStatChip(Icons.event, '${challenge.durationDays}', 'days', AppTheme.neutral600),
                          ],
                        ),
                        
                        // Progress bar (only if joined)
                        if (isJoined) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: (progress ?? 0) / 100,
                                    backgroundColor: AppTheme.neutral100,
                                    color: isCompleted ? AppTheme.success : accentColor,
                                    minHeight: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$progress%',
                                style: TextStyle(
                                  color: isCompleted ? AppTheme.success : accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        // Footer: Action button
                        if (!isJoined) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onJoin ?? () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Join Challenge',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                        ] else if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                              const SizedBox(width: 4),
                              Text('Completed!', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSmallTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toLowerCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(num % 1000 == 0 ? 0 : 1)}k';
    }
    return num.toString();
  }
  
  Color _getAccentColor(String type) {
    switch (type) {
      case 'SOLO': return const Color(0xFF2979FF); // Blue
      case 'GROUP': return const Color(0xFF651FFF); // Purple
      case 'TIMED': return const Color(0xFFFF3D00); // Red/Orange
      default: return AppTheme.primaryGreen;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'GROUP': return Icons.groups;
      case 'TIMED': return Icons.timer;
      default: return Icons.person; // Solo or generic
    }
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'EASY': return AppTheme.success; // Green
      case 'HARD': return AppTheme.error; // Red
      case 'MEDIUM': return AppTheme.warning; // Orange
      default: return AppTheme.secondaryBlue;
    }
  }
}
