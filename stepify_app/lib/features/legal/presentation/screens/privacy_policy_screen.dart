import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: May 20, 2026',
              style: TextStyle(color: AppTheme.neutral500),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Stepify respects your privacy and is committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights.',
            ),
            _buildSection(
              '2. Data We Collect',
              'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:\n'
                  '• Identity Data: First name, last name, username.\n'
                  '• Contact Data: Email address, telephone numbers.\n'
                  '• Health & Fitness Data: Steps, physical activities, height, weight, age (which are processed with your explicit consent).',
            ),
            _buildSection(
              '3. How We Use Your Data',
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data to provide our step-tracking and reward services, manage your account, and deliver community features.',
            ),
            _buildSection(
              '4. Data Security',
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way, altered, or disclosed.',
            ),
            _buildSection(
              '5. Your Legal Rights (GDPR)',
              'Under certain circumstances, you have rights under data protection laws in relation to your personal data. This includes the right to request access to your personal data and the right to request erasure of your personal data ("Right to be Forgotten"). You can exercise these rights directly within the app Settings.',
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
