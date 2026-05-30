import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: May 20, 2026',
              style: TextStyle(color: AppTheme.neutral500),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Agreement to Terms',
              'By accessing or using Wellnex, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the service.',
            ),
            _buildSection(
              '2. Accounts',
              'When you create an account with us, you must provide us with information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms.',
            ),
            _buildSection(
              '3. Rewards and Coins',
              'Wellnex provides in-app rewards ("Coins") based on your physical activity. These Coins hold no real-world monetary value and cannot be exchanged for fiat currency outside of the platform’s official redemption mechanisms. Accounts found cheating or spoofing location data will be permanently banned.',
            ),
            _buildSection(
              '4. Inactivity & Expiration',
              'To maintain an active economy, Wellnex reserves the right to expire wallet balances for accounts that have been entirely inactive for a period of 180 consecutive days.',
            ),
            _buildSection(
              '5. Termination',
              'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5, color: AppTheme.neutral600)),
        ],
      ),
    );
  }
}
