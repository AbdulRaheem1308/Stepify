import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/challenges_provider.dart';
import '../widgets/challenge_card.dart';

/// Challenges Screen with Tabs
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  
  // Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  String _searchQuery = '';
  String? _selectedDifficulty; // null = all
  String? _selectedType; // null = all

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    
    // Fetch challenges
    Future.microtask(() {
      ref.read(challengesProvider.notifier).fetchAllChallenges();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  // Filter challenges based on search and filters
  List<Challenge> _filterChallenges(List<Challenge> challenges) {
    return challenges.where((c) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }
      // Difficulty filter
      if (_selectedDifficulty != null && c.difficulty != _selectedDifficulty) {
        return false;
      }
      // Type filter
      if (_selectedType != null && c.challengeType != _selectedType) {
        return false;
      }
      return true;
    }).toList();
  }
  
  List<UserChallenge> _filterUserChallenges(List<UserChallenge> challenges) {
    return challenges.where((uc) {
      final c = uc.challenge;
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }
      // Difficulty filter
      if (_selectedDifficulty != null && c.difficulty != _selectedDifficulty) {
        return false;
      }
      // Type filter
      if (_selectedType != null && c.challengeType != _selectedType) {
        return false;
      }
      return true;
    }).toList();
  }
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }
  
  Widget _buildFilterSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(AppLocalizations.of(context)?.filterChallenges ?? 'Filter Challenges', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Difficulty Filter
            Text(AppLocalizations.of(context)?.difficulty ?? 'Difficulty', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'EASY', 'MEDIUM', 'HARD'].map((d) {
                final isSelected = (d == 'All' && _selectedDifficulty == null) || 
                                   _selectedDifficulty == d;
                return ChoiceChip(
                  label: Text(d.toLowerCase()),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  onSelected: (_) {
                    setSheetState(() {});
                    setState(() => _selectedDifficulty = d == 'All' ? null : d);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

  // ... (omitted parts handled by context view, but I need to be careful with range)
  // I will split this into multiple replace calls to avoid context issues or being too large.
  // First, let's just fix the _buildFilterSheet and Scaffold bg.
  // Wait, I can't easily split _buildFilterSheet and Scaffold in one go if they are far apart.
  // Scaffold is at 448. _buildFilterSheet is at 104.
  // I'll fix Scaffold first as it's simple.

            
            // Type Filter
            Text(AppLocalizations.of(context)?.challengeTypeLabel ?? 'Challenge Type', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'SOLO', 'GROUP', 'TIMED'].map((t) {
                final isSelected = (t == 'All' && _selectedType == null) || 
                                   _selectedType == t;
                return ChoiceChip(
                  label: Text(t.toLowerCase()),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  onSelected: (_) {
                    setSheetState(() {});
                    setState(() => _selectedType = t == 'All' ? null : t);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Apply & Reset buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDifficulty = null;
                        _selectedType = null;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)?.resetBtn ?? 'Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)?.applyBtn ?? 'Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinChallenge(Challenge challenge) async {
    // Show confirmation dialog
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildJoinConfirmationSheet(ctx, challenge),
    );

    if (confirmed == true) {
      final success = await ref.read(challengesProvider.notifier).joinChallenge(challenge.id);
      if (success && mounted) {
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.joinedChallengeSuccess(challenge.title) ?? '🎉 Joined "${challenge.title}"!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  Widget _buildJoinConfirmationSheet(BuildContext context, Challenge challenge) {
    final acceptedTerms = ValueNotifier<bool>(false);
    final showTerms = ValueNotifier<bool>(false);
    
    return ValueListenableBuilder<bool>(
      valueListenable: acceptedTerms,
      builder: (context, accepted, _) => ValueListenableBuilder<bool>(
        valueListenable: showTerms,
        builder: (context, showingTerms, _) {        
          return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  AppLocalizations.of(context)?.joinChallengeTitle ?? 'Join Challenge?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Challenge Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.stepsInDays(challenge.stepTarget, challenge.durationDays) ?? '🎯 ${challenge.stepTarget} steps in ${challenge.durationDays} days',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars_rounded, color: AppTheme.accentYellow, size: 20),
                          const SizedBox(width: 4),
                          Text('+${challenge.rewardCoins}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Icon(Icons.stars, color: AppTheme.accentPurple, size: 20),
                          const SizedBox(width: 4),
                          Text('+${challenge.rewardXp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Terms & Conditions Section
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Header with expand/collapse
                      InkWell(
                        onTap: () => showTerms.value = !showTerms.value,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)?.termsAndConditions ?? 'Terms & Conditions',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              Icon(
                                showingTerms ? Icons.expand_less : Icons.expand_more,
                                color: AppTheme.neutral500,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expandable Terms Content
                      if (showingTerms)
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              _buildTermItem(context, '1. Complete the required steps within the challenge duration.'),
                              _buildTermItem(context, '2. Steps must be tracked through the Well Nex app.'),
                              _buildTermItem(context, '3. Rewards are credited upon successful completion.'),
                              _buildTermItem(context, '4. Cheating or manipulation will result in disqualification.'),
                              _buildTermItem(context, '5. Challenges cannot be paused once joined.'),
                              _buildTermItem(context, '6. Rewards may vary based on challenge difficulty.'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Checkbox for accepting terms
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: accepted,
                        onChanged: (v) => acceptedTerms.value = v ?? false,
                        activeColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => acceptedTerms.value = !acceptedTerms.value,
                        child: Text(
                          AppLocalizations.of(context)?.iAgreeToTerms ?? 'I agree to the challenge Terms & Conditions',
                          style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppTheme.neutral300),
                        ),
                        child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: accepted ? () => Navigator.pop(context, true) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.neutral200,
                          disabledForegroundColor: AppTheme.neutral400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(AppLocalizations.of(context)?.joinNowBtn ?? 'Join Now! 🚀', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
               const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ),
  ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
}

  Widget _buildTermItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.neutral200),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppTheme.neutral900, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.challenges ?? 'Challenges',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutral900,
                          ),
                        ),
                        Text(
                          'Join and compete to earn coins',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Button
                  GestureDetector(
                    onTap: () => setState(() => _showSearch = !_showSearch),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _showSearch ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _showSearch ? AppTheme.primaryGreen : AppTheme.neutral200),
                      ),
                      child: Icon(
                        _showSearch ? Icons.close : Icons.search,
                        color: _showSearch ? AppTheme.primaryGreen : AppTheme.neutral900,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Button
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (_selectedDifficulty != null || _selectedType != null) 
                                ? AppTheme.primaryGreen.withValues(alpha: 0.1) 
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (_selectedDifficulty != null || _selectedType != null)
                                  ? AppTheme.primaryGreen
                                  : AppTheme.neutral200,
                            ),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: (_selectedDifficulty != null || _selectedType != null)
                                ? AppTheme.primaryGreen
                                : AppTheme.neutral900,
                            size: 20,
                          ),
                        ),
                        // Active filter indicator
                        if (_selectedDifficulty != null || _selectedType != null)
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar (conditionally shown)
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)?.searchChallenges ?? 'Search challenges...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.neutral500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.neutral200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.neutral200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryGreen),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            
            if (_showSearch) const SizedBox(height: 12),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: AppTheme.neutral500,
                indicatorColor: AppTheme.primaryGreen,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'New (${challenges.newChallenges.length})'),
                  Tab(text: 'Ongoing (${challenges.ongoingChallenges.length})'),
                  Tab(text: 'Completed (${challenges.completedChallenges.length})'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Content
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNewChallengesTab(challenges),
                      _buildOngoingChallengesTab(challenges),
                      _buildCompletedChallengesTab(challenges),
                    ],
                  ),
                  
                  // Confetti stays on top
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        AppTheme.primaryGreen,
                        AppTheme.accentYellow,
                        AppTheme.accentPurple,
                        AppTheme.secondaryBlue,
                      ],
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

  Widget _buildNewChallengesTab(ChallengesState challenges) {
    if (challenges.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (challenges.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(challenges.error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filterChallenges(challenges.newChallenges);
    
    if (filtered.isEmpty) {
      if (challenges.newChallenges.isEmpty) {
        return _buildEmptyState(AppLocalizations.of(context)?.noNewChallenges ?? 'No new challenges', AppLocalizations.of(context)?.checkBackLater ?? 'Check back later for new challenges!');
      }
      return _buildEmptyState(AppLocalizations.of(context)?.noMatchingChallenges ?? 'No matching challenges', AppLocalizations.of(context)?.tryAdjustingFilters ?? 'Try adjusting your search or filters');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final challenge = filtered[index];
          return ChallengeCard(
            challenge: challenge,
            isJoined: false,
            onJoin: () => _joinChallenge(challenge),
          ).animate(delay: (index * 100).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildOngoingChallengesTab(ChallengesState challenges) {
    if (challenges.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (challenges.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(challenges.error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filterUserChallenges(challenges.ongoingChallenges);
    
    if (filtered.isEmpty) {
      if (challenges.ongoingChallenges.isEmpty) {
        return _buildEmptyState(AppLocalizations.of(context)?.noOngoingChallenges ?? 'No ongoing challenges', AppLocalizations.of(context)?.joinChallengeToStart ?? 'Join a challenge to get started!');
      }
      return _buildEmptyState(AppLocalizations.of(context)?.noMatchingChallenges ?? 'No matching challenges', AppLocalizations.of(context)?.tryAdjustingFilters ?? 'Try adjusting your search or filters');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final userChallenge = filtered[index];
          return ChallengeCard(
            challenge: userChallenge.challenge,
            isJoined: true,
            currentSteps: userChallenge.currentSteps,
            progress: userChallenge.progress,
          ).animate(delay: (index * 100).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildCompletedChallengesTab(ChallengesState challenges) {
    if (challenges.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (challenges.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(challenges.error!, style: const TextStyle(color: AppTheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filterUserChallenges(challenges.completedChallenges);
    
    if (filtered.isEmpty) {
      if (challenges.completedChallenges.isEmpty) {
        return _buildEmptyState(AppLocalizations.of(context)?.noCompletedChallenges ?? 'No completed challenges', AppLocalizations.of(context)?.completeChallengesToSee ?? 'Complete challenges to see them here!');
      }
      return _buildEmptyState(AppLocalizations.of(context)?.noMatchingChallenges ?? 'No matching challenges', AppLocalizations.of(context)?.tryAdjustingFilters ?? 'Try adjusting your search or filters');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(challengesProvider.notifier).fetchAllChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final userChallenge = filtered[index];
          return ChallengeCard(
            challenge: userChallenge.challenge,
            isJoined: true,
            currentSteps: userChallenge.currentSteps,
            progress: 100,
          ).animate(delay: (index * 100).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.neutral500),
          ),
        ],
      ),
    );
  }
}
