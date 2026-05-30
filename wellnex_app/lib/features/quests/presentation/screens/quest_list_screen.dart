import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wellnex_app/core/theme/app_theme.dart';
import '../../domain/models/quest_model.dart';
import '../providers/quests_provider.dart';

class QuestListScreen extends ConsumerWidget {
  const QuestListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventure Quests'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true, 
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Your Journey Awaits',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete quests to earn XP and rewards.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
            
            // In Progress Section
            if (state.quests.any((q) => q.status == QuestStatus.inProgress)) ...[
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'In Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final quest = state.quests.where((q) => q.status == QuestStatus.inProgress).toList()[index];
                      return _QuestCard(quest: quest);
                    },
                    childCount: state.quests.where((q) => q.status == QuestStatus.inProgress).length,
                  ),
                ),
              ),
            ],

            // Available Section
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Available Quests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final quest = state.quests.where((q) => q.status == QuestStatus.available).toList()[index];
                    return _QuestCard(quest: quest);
                  },
                  childCount: state.quests.where((q) => q.status == QuestStatus.available).length,
                ),
              ),
            ),
            
            // Locked Section
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Locked',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
             SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final quest = state.quests.where((q) => q.status == QuestStatus.locked).toList()[index];
                    return _QuestCard(quest: quest, isLocked: true);
                  },
                  childCount: state.quests.where((q) => q.status == QuestStatus.locked).length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  final bool isLocked;

  const _QuestCard({required this.quest, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${quest.title}. Difficulty: ${quest.difficulty.name}. Reward: ${quest.rewardXp} XP. Status: ${isLocked ? 'Locked' : quest.status.name}.',
      button: !isLocked,
      child: GestureDetector(
      onTap: isLocked ? null : () => context.push('/quests/${quest.id}', extra: quest),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(quest.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: isLocked ? 0.7 : 0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                       Icon(Icons.lock, color: Colors.white, size: 16),
                       SizedBox(width: 4),
                       Text('Locked', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else if (quest.status == QuestStatus.inProgress)
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('In Progress', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              
              const Spacer(),
              Text(
                quest.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _DifficultyBadge(difficulty: quest.difficulty),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: AppTheme.accentYellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${quest.rewardXp} XP',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}

class _DifficultyBadge extends StatelessWidget {
  final QuestDifficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (difficulty) {
      case QuestDifficulty.easy:
        color = Colors.green;
        text = 'EASY';
        break;
      case QuestDifficulty.medium:
        color = Colors.orange;
        text = 'MEDIUM';
        break;
      case QuestDifficulty.hard:
        color = Colors.red;
        text = 'HARD';
        break;
      case QuestDifficulty.legendary:
        color = Colors.purple;
        text = 'LEGENDARY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
