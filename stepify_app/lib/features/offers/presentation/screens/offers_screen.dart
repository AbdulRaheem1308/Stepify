import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/ad_service.dart';
import '../providers/offers_provider.dart';

/// Screen 16: In-App Ads & Sponsor Offers
class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.earnOffers),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/my-offers'),
            icon: const Icon(Icons.history, color: AppTheme.neutral600),
            tooltip: 'My Offers',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured / Watch-to-Earn Section
            if (state.featuredOffers.isNotEmpty) ...[
               _buildSectionTitle('Watch & Earn'),
               SizedBox(
                 height: 220,
                 child: PageView.builder(
                   controller: PageController(viewportFraction: 0.9),
                   padEnds: false,
                   itemCount: state.featuredOffers.length,
                   itemBuilder: (context, index) {
                     return Padding(
                       padding: const EdgeInsets.only(right: 8, left: 16),
                       child: _buildFeaturedCard(context, ref, state.featuredOffers[index]),
                     );
                   },
                 ),
               ),
               const SizedBox(height: 24),
            ],

            // All Offers List
            _buildSectionTitle('Sponsor Deals'),
            if (state.allOffers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined, size: 60, color: AppTheme.neutral300),
                      const SizedBox(height: 12),
                      Text('No offers available', style: TextStyle(color: AppTheme.neutral500, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Check back later for new deals!', style: TextStyle(color: AppTheme.neutral400, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.allOffers.length,
                itemBuilder: (context, index) {
                  return _buildOfferItem(context, state.allOffers[index], index);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, WidgetRef ref, Offer offer) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decor
          Positioned(
             right: -20, top: -20,
             child: Icon(Icons.play_circle_fill, size: 150, color: Colors.white.withOpacity(0.1)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.providerName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  offer.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.accentYellow, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '+${offer.rewardCoins} Coins',
                      style: const TextStyle(color: AppTheme.accentYellow, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Start the offer
                    await ref.read(offersProvider.notifier).startOffer(offer.id);
                    
                    if (!context.mounted) return;
                    
                    final adService = ref.read(adServiceProvider);
                    adService.showRewardedAd(
                      onUserEarnedReward: (reward) async {
                        final coinsEarned = await ref.read(offersProvider.notifier).completeOffer(offer.id);
                        if (context.mounted) {
                          _showRewardDialog(context, coinsEarned > 0 ? coinsEarned : offer.rewardCoins);
                        }
                      },
                      onAdFailedToShow: () async {
                        // Fall back to simulation dialog
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => _AdSimulationDialog(onComplete: () async {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                            final coinsEarned = await ref.read(offersProvider.notifier).completeOffer(offer.id);
                            if (context.mounted) {
                              _showRewardDialog(context, coinsEarned > 0 ? coinsEarned : offer.rewardCoins);
                            }
                          }),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Watch Video'),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildOfferItem(BuildContext context, Offer offer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppTheme.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer, color: AppTheme.neutral500, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offer.providerName, style: const TextStyle(color: AppTheme.neutral500, fontSize: 12)),
                Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  offer.description,
                  style: const TextStyle(color: AppTheme.neutral600, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
             decoration: BoxDecoration(
               color: AppTheme.accentYellow.withOpacity(0.1),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Column(
               children: [
                 const Icon(Icons.stars_rounded, size: 16, color: AppTheme.accentYellow),
                 Text('+${offer.rewardCoins}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentYellow)),
               ],
             ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.05, end: 0);
  }
  
  void _showRewardDialog(BuildContext context, int coins) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.rewardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Offer Completed!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('+$coins coins',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.accentOrange),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdSimulationDialog extends StatefulWidget {
  final VoidCallback onComplete;
  const _AdSimulationDialog({required this.onComplete});

  @override
  State<_AdSimulationDialog> createState() => _AdSimulationDialogState();
}

class _AdSimulationDialogState extends State<_AdSimulationDialog> {
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (mounted) {
        setState(() => _progress += 0.02);
      }
      if (_progress >= 1) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            widget.onComplete();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_circle_filled, size: 80, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text('Watching Ad...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('${(5 - _progress * 5).ceil()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _progress, backgroundColor: AppTheme.neutral200, valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen), minHeight: 10)),
        ]),
      ),
    );
  }
}
