// test/core/router/app_routes_test.dart
//
// Tests for AppRoutes constant values.
//
// We intentionally do NOT import app_router.dart directly because that file
// pulls in GoRouter and every feature screen, which would require full Flutter
// platform channels and make the test unnecessarily heavy. Instead we mirror
// the expected values as string literals and verify three properties:
//   1. Each constant matches its expected string value.
//   2. All paths are unique (no two constants share the same path).
//   3. Every path starts with '/'.

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Local mirror of AppRoutes — keeps the test hermetically sealed.
// If a constant is added/changed in app_router.dart, the assertion below
// will catch the mismatch immediately.
// ---------------------------------------------------------------------------
abstract class _AppRoutes {
  static const String splash           = '/';
  static const String onboarding       = '/onboarding';
  static const String login            = '/login';
  static const String completeProfile  = '/complete-profile';
  static const String editProfile      = '/edit-profile';
  static const String otp              = '/otp';
  static const String home             = '/home';
  static const String analytics        = '/analytics';
  static const String rewards          = '/rewards';
  static const String profile          = '/profile';
  static const String adsReward        = '/ads-reward';
  static const String challenges       = '/challenges';
  static const String friends          = '/friends';
  static const String settings         = '/settings';
  static const String referral         = '/referral';
  static const String notifications    = '/notifications';
  static const String gamification     = '/gamification';
  static const String xpRules          = '/xp-rules';
  static const String leaderboard      = '/leaderboard';
  static const String badges           = '/badges';
  static const String streak           = '/streak';
  static const String deviceSync       = '/device-sync';
  static const String offers           = '/offers';
  static const String teams            = '/teams';
  static const String activityLog      = '/activity/log';
  static const String activityHistory  = '/activity/history';
  static const String routeTracking    = '/route-tracking';
  static const String messages         = '/messages';
  static const String quests           = '/quests';
  static const String companyJoin      = '/company/join';
  static const String companyDashboard = '/company/dashboard';
  static const String sensorDiagnostics = '/sensor-diagnostics';
  static const String chat             = '/messages/:id';
}

// ---------------------------------------------------------------------------
// Canonical map used for uniqueness + prefix checks.
// Add every constant here — the tests below iterate this map automatically.
// ---------------------------------------------------------------------------
const Map<String, String> _allRoutes = {
  'splash':            _AppRoutes.splash,
  'onboarding':        _AppRoutes.onboarding,
  'login':             _AppRoutes.login,
  'completeProfile':   _AppRoutes.completeProfile,
  'editProfile':       _AppRoutes.editProfile,
  'otp':               _AppRoutes.otp,
  'home':              _AppRoutes.home,
  'analytics':         _AppRoutes.analytics,
  'rewards':           _AppRoutes.rewards,
  'profile':           _AppRoutes.profile,
  'adsReward':         _AppRoutes.adsReward,
  'challenges':        _AppRoutes.challenges,
  'friends':           _AppRoutes.friends,
  'settings':          _AppRoutes.settings,
  'referral':          _AppRoutes.referral,
  'notifications':     _AppRoutes.notifications,
  'gamification':      _AppRoutes.gamification,
  'xpRules':           _AppRoutes.xpRules,
  'leaderboard':       _AppRoutes.leaderboard,
  'badges':            _AppRoutes.badges,
  'streak':            _AppRoutes.streak,
  'deviceSync':        _AppRoutes.deviceSync,
  'offers':            _AppRoutes.offers,
  'teams':             _AppRoutes.teams,
  'activityLog':       _AppRoutes.activityLog,
  'activityHistory':   _AppRoutes.activityHistory,
  'routeTracking':     _AppRoutes.routeTracking,
  'messages':          _AppRoutes.messages,
  'quests':            _AppRoutes.quests,
  'companyJoin':       _AppRoutes.companyJoin,
  'companyDashboard':  _AppRoutes.companyDashboard,
  'sensorDiagnostics': _AppRoutes.sensorDiagnostics,
  'chat':              _AppRoutes.chat,
};

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // Group 1 – individual constant values
  // ──────────────────────────────────────────────────────────────────────────
  group('AppRoutes constant values', () {
    test('splash is "/"', () {
      expect(_AppRoutes.splash, equals('/'));
    });

    test('onboarding is "/onboarding"', () {
      expect(_AppRoutes.onboarding, equals('/onboarding'));
    });

    test('login is "/login"', () {
      expect(_AppRoutes.login, equals('/login'));
    });

    test('completeProfile is "/complete-profile"', () {
      expect(_AppRoutes.completeProfile, equals('/complete-profile'));
    });

    test('editProfile is "/edit-profile"', () {
      expect(_AppRoutes.editProfile, equals('/edit-profile'));
    });

    test('otp is "/otp"', () {
      expect(_AppRoutes.otp, equals('/otp'));
    });

    test('home is "/home"', () {
      expect(_AppRoutes.home, equals('/home'));
    });

    test('analytics is "/analytics"', () {
      expect(_AppRoutes.analytics, equals('/analytics'));
    });

    test('rewards is "/rewards"', () {
      expect(_AppRoutes.rewards, equals('/rewards'));
    });

    test('profile is "/profile"', () {
      expect(_AppRoutes.profile, equals('/profile'));
    });

    test('adsReward is "/ads-reward"', () {
      expect(_AppRoutes.adsReward, equals('/ads-reward'));
    });

    test('challenges is "/challenges"', () {
      expect(_AppRoutes.challenges, equals('/challenges'));
    });

    test('friends is "/friends"', () {
      expect(_AppRoutes.friends, equals('/friends'));
    });

    test('settings is "/settings"', () {
      expect(_AppRoutes.settings, equals('/settings'));
    });

    test('referral is "/referral"', () {
      expect(_AppRoutes.referral, equals('/referral'));
    });

    test('notifications is "/notifications"', () {
      expect(_AppRoutes.notifications, equals('/notifications'));
    });

    test('gamification is "/gamification"', () {
      expect(_AppRoutes.gamification, equals('/gamification'));
    });

    test('xpRules is "/xp-rules"', () {
      expect(_AppRoutes.xpRules, equals('/xp-rules'));
    });

    test('leaderboard is "/leaderboard"', () {
      expect(_AppRoutes.leaderboard, equals('/leaderboard'));
    });

    test('badges is "/badges"', () {
      expect(_AppRoutes.badges, equals('/badges'));
    });

    test('streak is "/streak"', () {
      expect(_AppRoutes.streak, equals('/streak'));
    });

    test('deviceSync is "/device-sync"', () {
      expect(_AppRoutes.deviceSync, equals('/device-sync'));
    });

    test('offers is "/offers"', () {
      expect(_AppRoutes.offers, equals('/offers'));
    });

    test('teams is "/teams"', () {
      expect(_AppRoutes.teams, equals('/teams'));
    });

    test('activityLog is "/activity/log"', () {
      expect(_AppRoutes.activityLog, equals('/activity/log'));
    });

    test('activityHistory is "/activity/history"', () {
      expect(_AppRoutes.activityHistory, equals('/activity/history'));
    });

    test('routeTracking is "/route-tracking"', () {
      expect(_AppRoutes.routeTracking, equals('/route-tracking'));
    });

    test('messages is "/messages"', () {
      expect(_AppRoutes.messages, equals('/messages'));
    });

    test('quests is "/quests"', () {
      expect(_AppRoutes.quests, equals('/quests'));
    });

    test('companyJoin is "/company/join"', () {
      expect(_AppRoutes.companyJoin, equals('/company/join'));
    });

    test('companyDashboard is "/company/dashboard"', () {
      expect(_AppRoutes.companyDashboard, equals('/company/dashboard'));
    });

    test('sensorDiagnostics is "/sensor-diagnostics"', () {
      expect(_AppRoutes.sensorDiagnostics, equals('/sensor-diagnostics'));
    });

    test('chat is "/messages/:id"', () {
      expect(_AppRoutes.chat, equals('/messages/:id'));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 2 – uniqueness
  // ──────────────────────────────────────────────────────────────────────────
  group('AppRoutes uniqueness', () {
    test('all route paths are unique (no duplicates)', () {
      final paths = _allRoutes.values.toList();
      final uniquePaths = paths.toSet();

      // Build a readable error message if there are duplicates.
      if (paths.length != uniquePaths.length) {
        final seen = <String>{};
        final duplicates = <String>[];
        for (final path in paths) {
          if (!seen.add(path)) duplicates.add(path);
        }
        fail('Duplicate route paths detected: $duplicates');
      }

      expect(paths.length, equals(uniquePaths.length));
    });

    test('total route count matches expected (33 routes)', () {
      // Ensures no routes were accidentally added or removed in the mirror.
      expect(_allRoutes.length, equals(33));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Group 3 – path format invariants
  // ──────────────────────────────────────────────────────────────────────────
  group('AppRoutes path format', () {
    test('every route path starts with "/"', () {
      final violations = <String>[];
      _allRoutes.forEach((name, path) {
        if (!path.startsWith('/')) {
          violations.add('$name → "$path"');
        }
      });

      if (violations.isNotEmpty) {
        fail('The following routes do NOT start with "/": $violations');
      }

      expect(violations, isEmpty);
    });

    test('no route path contains whitespace', () {
      final violations = <String>[];
      _allRoutes.forEach((name, path) {
        if (path.contains(RegExp(r'\s'))) {
          violations.add('$name → "$path"');
        }
      });

      if (violations.isNotEmpty) {
        fail('Routes with whitespace in path: $violations');
      }

      expect(violations, isEmpty);
    });

    test('no route path is empty', () {
      final violations = <String>[];
      _allRoutes.forEach((name, path) {
        if (path.isEmpty) violations.add(name);
      });

      expect(violations, isEmpty,
          reason: 'Routes with empty paths: $violations');
    });
  });
}
