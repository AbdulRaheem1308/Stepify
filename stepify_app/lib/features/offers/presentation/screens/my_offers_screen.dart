import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/offers_provider.dart';

/// Screen 17: "My Offers" Subpage
class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We'll use the same offersProvider but filter for user's history
    // In a real app, we'd have a specific `myOffersProvider` or fetch different data
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
                  _buildOfferList(context, state.allOffers, status: 'active'), // Mock filtering
                  _buildOfferList(context, [], status: 'used'),
                  _buildOfferList(context, [], status: 'expired'),
                ],
              ),
      ),
    );
  }

  Widget _buildOfferList(BuildContext context, List<Offer> offers, {required String status}) {
    if (offers.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _buildMyOfferCard(context, offers[index], status);
      },
    );
  }

  Widget _buildMyOfferCard(BuildContext context, Offer offer, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_offer, color: AppTheme.primaryGreen),
            ),
            title: Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Expires in 2 days', style: TextStyle(color: AppTheme.neutral500, fontSize: 12)),
            trailing: Chip(
              label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
              backgroundColor: status == 'active' ? AppTheme.primaryGreen.withOpacity(0.1) : AppTheme.neutral100,
              labelStyle: TextStyle(color: status == 'active' ? AppTheme.primaryGreen : AppTheme.neutral500),
            ),
          ),
          if (status == 'active')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Redeem Now'),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState(String status) {
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
          Icon(icon, size: 64, color: AppTheme.neutral300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.neutral500),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
