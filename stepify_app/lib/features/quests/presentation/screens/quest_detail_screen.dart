import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import '../../domain/models/quest_model.dart';
import '../providers/quests_provider.dart';

class QuestDetailScreen extends ConsumerWidget {
  final String questId;
  final Quest? initialQuest; // From extra for smooth transition

  const QuestDetailScreen({super.key, required this.questId, this.initialQuest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find quest in state to ensure fresh data
    final state = ref.watch(questsProvider);
    
    ref.listen<QuestsState>(questsProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.error,
          ),
        );
        ref.read(questsProvider.notifier).clearError();
      }
    });

    final quest = state.quests.firstWhere(
      (q) => q.id == questId,
      orElse: () => initialQuest!, // Fallback to passed object if not found (or crash if neither)
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: AppTheme.neutral900,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                quest.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: 
                    quest.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6), // Protection for top back button/status bar
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7), // Protection for title
                        ],
                        stops: const [0.0, 0.25, 0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    _InfoChip(icon: Icons.speed, label: quest.difficulty.name.toUpperCase(), color: Colors.blue),
                    const SizedBox(width: 12),
                    _InfoChip(icon: Icons.star, label: '${quest.rewardXp} XP', color: AppTheme.accentYellow),
                     const SizedBox(width: 12),
                    _InfoChip(icon: Icons.monetization_on, label: '${quest.rewardCoins} Coins', color: Colors.amber),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'About this Quest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  quest.description,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), height: 1.5),
                ),
                const SizedBox(height: 32),
                 const Text(
                  'Stages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...List.generate(quest.stages.length, (index) {
                  final stage = quest.stages[index];
                  final isLocked = index > quest.currentStageIndex;
                  final isCompleted = index < quest.currentStageIndex || (index == quest.currentStageIndex && stage.isCompleted);
                  final isCurrent = index == quest.currentStageIndex && !stage.isCompleted && quest.status == QuestStatus.inProgress;

                  return _StageTimelineTile(
                    stage: stage,
                    isFirst: index == 0,
                    isLast: index == quest.stages.length - 1,
                    status: isCompleted ? _StageStatus.completed : (isCurrent ? _StageStatus.current : _StageStatus.locked),
                  );
                }),
                
                const SizedBox(height: 40),
                if (quest.status == QuestStatus.available)
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await ref.read(questsProvider.notifier).joinQuest(quest.id);
                            
                            // Check if the quest enrollment was successful (no error in final state)
                            if (ref.read(questsProvider).error == null) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Quest Joined! Good luck!')),
                              );
                            }
                          },
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Start Quest'),
                  )
                else if (quest.status == QuestStatus.inProgress)
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Continue Journey'),
                  ),
                  
                  const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StageStatus { locked, current, completed }

class _StageTimelineTile extends StatelessWidget {
  final QuestStage stage;
  final bool isFirst;
  final bool isLast;
  final _StageStatus status;

  const _StageTimelineTile({
    required this.stage,
    required this.isFirst,
    required this.isLast,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (status) {
      case _StageStatus.completed:
        color = AppTheme.success;
        icon = Icons.check;
        break;
      case _StageStatus.current:
        color = AppTheme.primaryGreen;
        icon = Icons.directions_walk;
        break;
      case _StageStatus.locked:
        color = AppTheme.neutral300;
        icon = Icons.lock;
        break;
    }

    return Semantics(
      label: '${stage.title}. ${status == _StageStatus.completed ? "Completed" : status == _StageStatus.current ? "Current" : "Locked"}. Target: ${stage.targetSteps} steps.',
      child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst) Expanded(child: Container(width: 2, color: status == _StageStatus.completed ? AppTheme.success : AppTheme.neutral200)),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: status == _StageStatus.completed || status == _StageStatus.current ? AppTheme.success : AppTheme.neutral200)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Card(
                elevation: status == _StageStatus.current ? 4 : 0,
                color: status == _StageStatus.current ? Theme.of(context).colorScheme.surface : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: status == _StageStatus.current 
                      ? const BorderSide(color: AppTheme.primaryGreen, width: 1.5)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: status == _StageStatus.locked ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5) : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.description,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${stage.targetSteps} Steps',
                         style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status == _StageStatus.locked ? AppTheme.neutral400 : AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
