// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stepify';

  @override
  String get appTagline => 'Walk, Track, Earn Rewards';

  @override
  String get home => 'Home';

  @override
  String get analytics => 'Analytics';

  @override
  String get friends => 'Friends';

  @override
  String get rewards => 'Rewards';

  @override
  String get profile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hey, $name! 👋';
  }

  @override
  String get readyToStep => 'Ready to step up today?';

  @override
  String get steps => 'Steps';

  @override
  String stepsToGo(int count) {
    return '$count steps to go';
  }

  @override
  String get goalReached => 'Goal Reached! 🎉';

  @override
  String get adjustGoal => 'Adjust Goal';

  @override
  String get calories => 'Calories';

  @override
  String get distance => 'Distance';

  @override
  String get activeMinutes => 'Active Min';

  @override
  String get streak => 'Streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get challenges => 'Challenges';

  @override
  String get viewActive => 'View active';

  @override
  String get earnOffers => 'Earn & Offers';

  @override
  String get watchAdsDeals => 'Watch ads & deals';

  @override
  String get community => 'Community';

  @override
  String get feedMilestones => 'Feed & Milestones';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get badges => 'Badges';

  @override
  String get wallet => 'Wallet';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continue_ => 'Continue';

  @override
  String get noData => 'No data available';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get global => 'Global';

  @override
  String get referral => 'Referral';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String xpPoints(int count) {
    return '$count XP';
  }

  @override
  String coins(int count) {
    return '$count coins';
  }

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get keepItUp => 'Keep it up! 💪';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get greatProgress => 'Great progress!';

  @override
  String get backgroundSync => 'Background Sync';

  @override
  String get backgroundSyncSubtitle => 'Sync steps when app is closed';

  @override
  String get syncOverCellular => 'Sync Over Cellular';

  @override
  String get syncOverCellularSubtitle => 'Use mobile data for syncing';

  @override
  String get connectedDevices => 'Connected Devices';
}
