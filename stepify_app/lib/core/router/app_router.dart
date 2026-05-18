import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/steps/presentation/screens/step_analytics_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/ads/presentation/screens/ads_reward_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/challenges/presentation/screens/challenges_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/referral/presentation/screens/referral_screen.dart';
import '../../features/referral/presentation/screens/referral_leaderboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/gamification/presentation/screens/gamification_screen.dart';
import '../../features/gamification/presentation/screens/xp_rules_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../../features/gamification/presentation/screens/badges_screen.dart';
import '../../features/gamification/presentation/screens/streak_screen.dart';
import '../../features/devices/presentation/screens/device_sync_screen.dart';
import '../../features/offers/presentation/screens/offers_screen.dart';
import '../../features/offers/presentation/screens/my_offers_screen.dart';
import '../../features/rewards/presentation/screens/wallet_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/teams/presentation/screens/team_leaderboard_screen.dart';
import '../../features/activities/presentation/screens/activity_logging_screen.dart';
import '../../features/activities/presentation/screens/activity_history_screen.dart';
import '../../features/messaging/presentation/screens/conversations_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/quests/domain/models/quest_model.dart';
import '../../features/quests/presentation/screens/quest_list_screen.dart';
import '../../features/quests/presentation/screens/quest_detail_screen.dart';
import '../../features/companies/presentation/screens/join_company_screen.dart';
import '../../features/companies/presentation/screens/company_dashboard_screen.dart';

/// App Router Provider using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'];
          final email = state.uri.queryParameters['email'];
          return OtpScreen(phone: phone, email: email);
        },
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const StepAnalyticsScreen(),
          ),
          GoRoute(
            path: '/friends',
            name: 'friends',
            builder: (context, state) => const FriendsScreen(),
          ),
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      
      // Standalone Screens
      GoRoute(
        path: '/ads-reward',
        name: 'ads-reward',
        builder: (context, state) => const AdsRewardScreen(),
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      GoRoute(
        path: '/referral-leaderboard',
        name: 'referral-leaderboard',
        builder: (context, state) => const ReferralLeaderboardScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/gamification',
        name: 'gamification',
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: '/xp-rules',
        name: 'xp-rules',
        builder: (context, state) => const XpRulesScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/badges',
        name: 'badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/streak',
        name: 'streak',
        builder: (context, state) => const StreakScreen(),
      ),
      GoRoute(
        path: '/device-sync',
        name: 'device-sync',
        builder: (context, state) => const DeviceSyncScreen(),
      ),
      GoRoute(
        path: '/offers',
        name: 'offers',
        builder: (context, state) => const OffersScreen(),
      ),
      GoRoute(
        path: '/my-offers',
        name: 'my-offers',
        builder: (context, state) => const MyOffersScreen(),
      ),
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/teams',
        name: 'teams',
        builder: (context, state) => const TeamsScreen(),
      ),
      GoRoute(
        path: '/teams/leaderboard',
        name: 'teams-leaderboard',
        builder: (context, state) => const TeamLeaderboardScreen(),
      ),
      GoRoute(
        path: '/teams/:id',
        name: 'team-detail',
        builder: (context, state) {
          final teamId = state.pathParameters['id']!;
          return TeamDetailScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/activity/log',
        name: 'activity-log',
        builder: (context, state) => const ActivityLoggingScreen(),
      ),
      GoRoute(
        path: '/activity/history',
        name: 'activity-history',
        builder: (context, state) => const ActivityHistoryScreen(),
      ),
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/messages/:id',
        name: 'chat',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final userName = state.extra as String? ?? 'Chat';
          return ChatScreen(conversationId: id, userName: userName);
        },
      ),
      GoRoute(
        path: '/quests',
        name: 'quests',
        builder: (context, state) => const QuestListScreen(),
      ),
      GoRoute(
        path: '/quests/:id',
        name: 'quest-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final quest = state.extra as Quest?;
          return QuestDetailScreen(questId: id, initialQuest: quest);
        },
      ),
      GoRoute(
        path: '/company/join',
        name: 'company-join',
        builder: (context, state) => const JoinCompanyScreen(),
      ),
      GoRoute(
        path: '/company/dashboard',
        name: 'company-dashboard',
        builder: (context, state) => const CompanyDashboardScreen(),
      ),
    ],
  );
});

/// Route names for easy navigation
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String completeProfile = '/complete-profile';
  static const String editProfile = '/edit-profile';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String analytics = '/analytics';
  static const String rewards = '/rewards';
  static const String profile = '/profile';
  static const String adsReward = '/ads-reward';
  static const String challenges = '/challenges';
  static const String friends = '/friends';
  static const String settings = '/settings';
  static const String referral = '/referral';
  static const String notifications = '/notifications';
  static const String gamification = '/gamification';
  static const String xpRules = '/xp-rules';
  static const String leaderboard = '/leaderboard';
  static const String badges = '/badges';
  static const String streak = '/streak';
  static const String deviceSync = '/device-sync';
  static const String offers = '/offers';
  static const String teams = '/teams';
  static const String activityLog = '/activity/log';
  static const String activityHistory = '/activity/history';
  static const String messages = '/messages';
  static const String quests = '/quests';
  static const String companyJoin = '/company/join';
  static const String companyDashboard = '/company/dashboard';
}
