import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class XpRulesScreen extends StatelessWidget {
  const XpRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification Rules'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Banner
          SliverToBoxAdapter(
            child: _buildInfoBanner(context),
          ),
          
          // Section: How to Earn
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                'How to Earn XP',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildXpRuleRow(context, 'Walking', '1 XP per 200 steps', Icons.directions_walk, AppTheme.primaryGreen),
                _buildXpRuleRow(context, 'Daily Streak', '20 XP per day maintained', Icons.local_fire_department, AppTheme.accentOrange),
                _buildXpRuleRow(context, 'Referral', '200 XP per friend invited', Icons.person_add, AppTheme.secondaryBlue),
                _buildXpRuleRow(context, 'Challenges', '50-300 XP per challenge', Icons.emoji_events, AppTheme.accentPurple),
                _buildXpRuleRow(context, 'Badges', '100 XP per badge unlocked', Icons.star, AppTheme.accentYellow),
              ]),
            ),
          ),

          // Section: Level Ladder
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Level Ladder',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildLevelItem(context, index + 1);
                },
                childCount: 10, // Show first 10 levels as example
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'How it Works',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Earn XP by staying active and engaging with the community. Level up to unlock exclusive badges, avatar frames, and multipliers for step coins!',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildXpRuleRow(BuildContext context, String action, String reward, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  reward,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLevelItem(BuildContext context, int level) {
    // Generate deterministic mock data
    final title = _getLevelTitle(level);
    final xpReq = _getXpRequirement(level);
    final perks = _getLevelPerks(level);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          child: Text('$level', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$xpReq XP Required', style: Theme.of(context).textTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perks:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 8),
                ...perks.map((perk) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Text(perk, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    const titles = [
      'Beginner',           // 1
      'Starter',            // 2
      'Newcomer',           // 3
      'Apprentice',         // 4
      'Rookie Walker',      // 5
      'Trail Finder',       // 6
      'Path Seeker',        // 7
      'Urban Explorer',     // 8
      'Street Strider',     // 9
      'City Walker',        // 10
    ];
    if (level <= titles.length) return titles[level - 1];
    if (level <= 15) return 'Trail Blazer Lv.$level';
    if (level <= 20) return 'Distance Runner Lv.$level';
    if (level <= 30) return 'Marathon Master Lv.$level';
    return 'Step Legend Lv.$level';
  }

  int _getXpRequirement(int level) {
    if (level == 1) return 0;
    return (level - 1) * 1000 + (level * 500); 
  }

  List<String> _getLevelPerks(int level) {
    if (level == 1) return ['Basic App Access'];
    if (level == 5) return ['Bronze Badge', '5% Coin Boost'];
    if (level == 10) return ['Silver Badge', 'Avatar Frame'];
    if (level == 20) return ['Gold Badge', '10% Coin Boost'];
    return ['Coin Multiplier +${level}%'];
  }
}
