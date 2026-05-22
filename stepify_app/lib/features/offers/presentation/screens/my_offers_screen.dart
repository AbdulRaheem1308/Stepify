import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/offers_provider.dart';

/// Screen 17: "My Offers" Subpage
class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offersProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.neutral500,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Used'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOfferList(context, state.activeOffers, status: 'active'),
                  _buildOfferList(context, state.completedOffers, status: 'used'),
                  _buildOfferList(context, state.expiredOffers, status: 'expired'),
                ],
              ),
      ),
    );
  }

  Widget _buildOfferList(BuildContext context, List<UserOffer> offers, {required String status}) {
    if (offers.isEmpty) {
      return _buildEmptyState(context, status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _buildMyOfferCard(context, offers[index], status);
      },
    );
  }

  Widget _buildMyOfferCard(BuildContext context, UserOffer userOffer, String status) {
    final offer = userOffer.offer;
    
    // Calculate expiration days based on startedAt, for example +7 days
    final expirationDate = userOffer.startedAt.add(const Duration(days: 7));
    final diff = expirationDate.difference(DateTime.now());
    final expiresText = diff.isNegative ? 'Expired' : 'Expires in ${diff.inDays} days';
    
    final semanticLabel = '${offer.title}, $expiresText. Status: $status';

    return Semantics(
      label: semanticLabel,
      button: status == 'active',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_offer, color: AppTheme.primaryGreen),
                ),
              ),
              title: Text(
                offer.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              subtitle: Text(
                expiresText,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
              trailing: Chip(
                label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: status == 'active' ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: status == 'active' ? AppTheme.primaryGreen : Theme.of(context).textTheme.bodyMedium?.color),
                side: BorderSide.none,
              ),
            ),
            if (status == 'active')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ExcludeSemantics(
                    child: ElevatedButton(
                      onPressed: () {
                        if (offer.actionUrl != null) {
                          context.push(offer.actionUrl!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Redeem Now'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildEmptyState(BuildContext context, String status) {
    String message = '';
    IconData icon = Icons.local_offer_outlined;

    switch (status) {
      case 'active':
        message = 'No active offers right now.\nCheck out the "Earn" tab!';
        break;
      case 'used':
        message = 'You haven\'t redeemed any offers yet.';
        icon = Icons.history;
        break;
      case 'expired':
        message = 'No expired offers.';
        icon = Icons.timer_off;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 64, color: Theme.of(context).dividerColor)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
