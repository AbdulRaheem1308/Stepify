import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';
import 'package:wellnex_app/core/theme/app_theme.dart';
import '../providers/company_provider.dart';

class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companyProvider);
    final member = state.member;

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (member == null) {
      // Should redirect or show error, but for safety:
      return Scaffold(body: Center(child: Text(AppLocalizations.of(context)?.notACompanyMember ?? 'Not a member of any company')));
    }

    // Since we don't have the Company Name in CompanyMember directly (it is in userMetadata or we need to add it to model),
    // let's assume we fetch it or it's part of the response structure I defined earlier. 
    // Checking company_model.dart... CompanyMember doesn't strictly have 'companyName' field in my previous `write_to_file`.
    // But the `fromJson` in my previous step didn't explicitly map a nested company object. 
    // Let's rely on `companyId` or just "Corporate Wellness" for now to avoid errors, 
    // or better, I should have included `company` in the `CompanyMember` model if the API returns it. 
    // The Service `joinCompany` returns `CompanyMember`. 
    // Let's settle for a generic title for now.
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.corporateWellness ?? 'Corporate Wellness'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: AppTheme.primaryGreen,
              child: Column(
                children: [
                   const CircleAvatar(
                     radius: 40,
                     backgroundColor: Colors.white,
                     child: Icon(Icons.business, size: 40, color: AppTheme.primaryGreen),
                   ),
                   const SizedBox(height: 16),
                     Text(
                       AppLocalizations.of(context)?.employeeId(member.userId.substring(0, 5)) ?? 'Employee #${member.userId.substring(0, 5)}', // Mock name
                       style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                     ),
                   const SizedBox(height: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.white.withValues(alpha: 0.2),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       member.role.toString().split('.').last.toUpperCase(),
                       style: const TextStyle(color: Colors.white, fontSize: 12),
                     ),
                   ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Text(AppLocalizations.of(context)?.leaderboardTitle ?? 'Leaderboard', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final m = state.leaderboard[index];
                  final isMe = m.userId == member.userId;
                  return Card(
                    color: isMe ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.neutral200,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(m.userMetadata?['name'] ?? 'User ${m.userId.substring(0,4)}'),
                      subtitle: Text(isMe ? (AppLocalizations.of(context)?.you ?? 'You') : (AppLocalizations.of(context)?.colleague ?? 'Colleague')),
                      trailing: Text(
                        '${m.totalSteps} steps',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ),
                  );
                },
                childCount: state.leaderboard.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
