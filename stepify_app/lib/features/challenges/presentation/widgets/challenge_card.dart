import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
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
      onTap: () => _showChallengeDetails(context, accentColor, isCompleted),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                                color: accentColor.withValues(alpha: 0.12),
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
                            // Info icon hint
                            Icon(Icons.info_outline, size: 16, color: accentColor.withValues(alpha: 0.6)),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Stats Row: Steps + Coins + Days
                        Row(
                          children: [
                            _buildStatChip(Icons.directions_walk, _formatNumber(challenge.stepTarget), AppLocalizations.of(context)?.steps.toLowerCase() ?? 'steps', AppTheme.secondaryBlue),
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
                              child: Text(
                                AppLocalizations.of(context)?.joinChallengeBtn ?? 'Join Challenge',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                              Text(AppLocalizations.of(context)?.completedStatus ?? 'Completed!', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showChallengeDetails(BuildContext context, Color accentColor, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        maxChildSize: 0.95,
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
                      decoration: BoxDecoration(color: AppTheme.neutral300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getIconForType(challenge.challengeType), color: accentColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
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
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    challenge.description,
                    style: const TextStyle(color: AppTheme.neutral600, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Rewards row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        accentColor.withValues(alpha: 0.08),
                        accentColor.withValues(alpha: 0.03),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRewardItem(Icons.stars_rounded, '${challenge.rewardCoins}', 'Coins', const Color(0xFFD4A017)),
                        Container(width: 1, height: 40, color: AppTheme.neutral200),
                        _buildRewardItem(Icons.auto_awesome, '+${challenge.rewardXp}', 'XP', AppTheme.accentPurple),
                        Container(width: 1, height: 40, color: AppTheme.neutral200),
                        _buildRewardItem(Icons.event, '${challenge.durationDays}d', 'Duration', AppTheme.neutral600),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Progress (if joined)
                  if (isJoined && currentSteps != null) ...[
                    Row(
                      children: [
                        Icon(Icons.track_changes, color: accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text('Your Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accentColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (progress ?? 0) / 100,
                              backgroundColor: AppTheme.neutral200,
                              color: isCompleted ? AppTheme.success : accentColor,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_formatNumber(currentSteps!)} / ${_formatNumber(challenge.stepTarget)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.neutral600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${progress ?? 0}% complete', style: const TextStyle(color: AppTheme.neutral500, fontSize: 12)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  // How to Complete section
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.lightbulb_outline,
                        color: isCompleted ? AppTheme.success : AppTheme.accentYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isCompleted ? 'How You Completed It' : 'How to Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isCompleted ? AppTheme.success : AppTheme.neutral800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildHowToStep(context, '1', 'Join the challenge', 'Tap "Join Challenge" and accept the terms. You\'re enrolled immediately.', accentColor, isCompleted),
                  _buildHowToStep(context, '2', 'Walk every day', 'Open Stepify daily and let the pedometer count your steps automatically. Your steps accumulate over the ${challenge.durationDays}-day period.', accentColor, isCompleted),
                  _buildHowToStep(context, '3', 'Reach ${_formatNumber(challenge.stepTarget)} total steps', 'Walk a combined total of ${_formatNumber(challenge.stepTarget)} steps across all ${challenge.durationDays} days. Your steps are synced every 4 hours.', accentColor, isCompleted),
                  _buildHowToStep(context, '4', 'Collect your reward', 'Once your step total hits the target, the challenge is automatically marked complete and +${challenge.rewardCoins} coins & +${challenge.rewardXp} XP are credited to your wallet.', accentColor, isCompleted),

                  if (challenge.endsAt != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppTheme.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Challenge ends: ${_formatDate(challenge.endsAt!)}',
                              style: const TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Action button
                  if (!isJoined)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onJoin?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.rocket_launch),
                        label: Text(
                          AppLocalizations.of(context)?.joinChallengeBtn ?? 'Join Challenge',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    )
                  else if (isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.success),
                          SizedBox(width: 8),
                          Flexible(child: Text('Challenge Completed! 🎉', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 15))),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_walk, color: accentColor),
                          const SizedBox(width: 8),
                          Flexible(child: Text('Keep Walking! ${(progress ?? 0)}% done', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15))),
                        ],
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

  Widget _buildRewardItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.neutral500)),
      ],
    );
  }

  Widget _buildHowToStep(BuildContext context, String num, String title, String description, Color color, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.success.withValues(alpha: 0.15) : color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? AppTheme.success : color,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(color: AppTheme.neutral500, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }



  Widget _buildSmallTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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
          color: color.withValues(alpha: 0.08),
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
