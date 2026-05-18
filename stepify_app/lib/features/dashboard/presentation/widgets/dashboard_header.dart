import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../messaging/presentation/screens/conversations_screen.dart';

class DashboardHeader extends StatelessWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;
  final VoidCallback onRefreshTap;
  final int unreadCount;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onProfileTap,
    required this.onRefreshTap,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = user?['name']?.split(' ')?.first ?? 'Stepper';
    final avatarUrl = user?['avatarUrl'];

    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.neutral200,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person, color: AppTheme.neutral600) : null,
          ),
        ),
        const SizedBox(width: 12),
        
        // Greetings
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.greeting(name),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                l10n.readyToStep,
                style: const TextStyle(color: AppTheme.neutral500, fontSize: 13),
              ),
            ],
          ),
        ),
        
        // Actions
        _buildActionButton(
          context,
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationTap,
          badgeCount: unreadCount,
        ),
        // const SizedBox(width: 8),
        // _buildActionButton(
        //   context,
        //   icon: Icons.chat_bubble_outline_rounded,
        //   onTap: () => Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => const ConversationsScreen()),
        //   ),
        // ),
        // const SizedBox(width: 8),
        // _buildActionButton(
        //   context,
        //   icon: Icons.refresh_rounded,
        //   onTap: onRefreshTap,
        // ),
        const SizedBox(width: 8),
        _buildActionButton(
          context,
          icon: Icons.settings_outlined,
          onTap: onSettingsTap,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required VoidCallback onTap, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neutral200),
            ),
            child: Icon(icon, color: AppTheme.neutral600, size: 20),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 12, height: 12,
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
