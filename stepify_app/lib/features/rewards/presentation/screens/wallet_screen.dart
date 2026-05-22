import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

enum TransactionType { earn, spend }

class WalletTransaction {
  final String id;
  final String title;
  final String description;
  final int amount;
  final TransactionType type;
  final DateTime date;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });
}

/// Screen 21: My Wallet (Ledger)
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock Data
    final transactions = [
      WalletTransaction(
        id: '1', title: 'Daily Steps', description: 'Goal achieved (10k steps)',
        amount: 50, type: TransactionType.earn, date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WalletTransaction(
        id: '2', title: 'Ad Reward', description: 'Watched "Stepify Premium"',
        amount: 10, type: TransactionType.earn, date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      WalletTransaction(
        id: '3', title: 'Starbucks Gift Card', description: '\$5 Coffee Voucher',
        amount: 2500, type: TransactionType.spend, date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: '4', title: 'Referral Bonus', description: 'Invited "Sarah J."',
        amount: 100, type: TransactionType.earn, date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    final balance = 1250; // Mock

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Balance Card
          _buildBalanceCard(context, balance),
          
          const SizedBox(height: 24),
          
          // Ledger Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Semantics(
                  label: 'Export Transaction History',
                  button: true,
                  child: TextButton(onPressed: () {}, child: const Text('Export')),
                ),
              ],
            ),
          ),
          
          // Ledger List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(context, transactions[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, int balance) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: AppTheme.accentYellow, size: 32), // Using stars_rounded as coin
              const SizedBox(width: 8),
              Text(
                NumberFormat.decimalPattern().format(balance),
                style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               _buildBalanceStat('Earned', '+3,240'),
               Container(width: 1, height: 30, color: Colors.white24),
               _buildBalanceStat('Spent', '-1,990'),
             ],
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBalanceStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, WalletTransaction txn, int index) {
    final isEarn = txn.type == TransactionType.earn;
    return Semantics(
      label: '${txn.title}. ${txn.description}. ${isEarn ? 'Earned' : 'Spent'} ${txn.amount} coins on ${DateFormat.yMMMd().format(txn.date)}.',
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEarn ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn ? Icons.arrow_downward : Icons.arrow_upward,
              color: isEarn ? AppTheme.success : AppTheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(txn.description, style: const TextStyle(color: AppTheme.neutral500, fontSize: 12)),
              ],
            ),
          ),
          Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Text(
                 '${isEarn ? '+' : '-'}${txn.amount}',
                 style: TextStyle(
                   color: isEarn ? AppTheme.success : AppTheme.error,
                   fontWeight: FontWeight.bold, 
                   fontSize: 16
                 ),
               ),
               Text(
                 DateFormat('MMM d').format(txn.date),
                 style: const TextStyle(color: AppTheme.neutral400, fontSize: 12),
               ),
             ],
          ),
        ],
      ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX();
  }
}
