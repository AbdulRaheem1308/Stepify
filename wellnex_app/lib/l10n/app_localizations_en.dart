// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wellnex';

  @override
  String get appTagline => 'Walk • Track • Earn';

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
  String get steps => 'steps';

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

  @override
  String get activityHistory => 'Activity History';

  @override
  String get noActivitiesYet => 'No activities yet';

  @override
  String get logFirstWorkout => 'Log your first workout to see it here!';

  @override
  String get logWorkout => 'Log Workout';

  @override
  String get whatDidYouDoToday => 'What did you do today?';

  @override
  String get activityType => 'Activity Type';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String earnPointsMultiplier(String multiplier) {
    return 'Earn ${multiplier}x points for this activity!';
  }

  @override
  String get logWorkoutAndEarn => 'Log Workout & Earn Points';

  @override
  String get gpsRouteTracker => 'GPS Route Tracker';

  @override
  String get endTracking => 'End';

  @override
  String get acquiringGps => 'Acquiring GPS signal...';

  @override
  String get tapStartToTrack => 'Tap Start to begin tracking your route';

  @override
  String get saveWorkoutTitle => 'Save Workout?';

  @override
  String saveWorkoutDesc(String distance, String duration) {
    return 'You travelled $distance km in $duration.\n\nSave this route to earn points?';
  }

  @override
  String get discard => 'Discard';

  @override
  String get saveRoute => 'Save Route';

  @override
  String get routeTooShort => 'Route too short to save.';

  @override
  String durationMustBeAtLeast(int minutes) {
    return 'Duration must be at least $minutes minute.';
  }

  @override
  String durationExceedsMax(int minutes) {
    return 'Duration cannot exceed $minutes minutes.';
  }

  @override
  String distanceUnrealistic(
      String distance, int minutes, String activityName) {
    return 'Distance entered ($distance km) is unrealistic for $minutes minutes of $activityName.';
  }

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get loginSubtitle =>
      'Walk more. Earn more.\nJoin the movement safely.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get termsAndPrivacy =>
      'By continuing, you agree to our Terms & Privacy Policy';

  @override
  String signInFailed(String providerName, String error) {
    return 'Failed to sign in with $providerName: $error';
  }

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String enterOtpSentTo(String identifier) {
    return 'Enter the 6-digit code sent to\n$identifier';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendButton => 'Resend';

  @override
  String get devModeOtp =>
      'Dev Mode: Check console for OTP if Twilio is not configured';

  @override
  String get enterCompleteOtp => 'Please enter the complete OTP';

  @override
  String get otpSentSuccess => 'OTP sent successfully';

  @override
  String get completeProfileTitle => 'Complete Profile';

  @override
  String get completeSetupButton => 'Complete Setup';

  @override
  String get completeProfileSubtitle =>
      'Tell us about yourself to personalize your experience.';

  @override
  String get yourName => 'Your Name';

  @override
  String get nameHint => 'e.g. Alex Step';

  @override
  String get nameTooShort => 'Name must be at least 2 chars';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get ageLabel => 'Age';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get dailyStepGoal => 'Daily Step Goal';

  @override
  String stepsCount(int steps) {
    return '$steps steps';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String errorSavingProfile(String error) {
    return 'Error saving profile: $error';
  }

  @override
  String get joinChallengeBtn => 'Join Challenge';

  @override
  String get joinNowBtn => 'Join Now! 🚀';

  @override
  String get completedStatus => 'Completed!';

  @override
  String get filterChallenges => 'Filter Challenges';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get challengeTypeLabel => 'Challenge Type';

  @override
  String get applyBtn => 'Apply';

  @override
  String get resetBtn => 'Reset';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get iAgreeToTerms => 'I agree to the challenge Terms & Conditions';

  @override
  String get searchChallenges => 'Search challenges...';

  @override
  String get noNewChallenges => 'No new challenges';

  @override
  String get noOngoingChallenges => 'No ongoing challenges';

  @override
  String get noCompletedChallenges => 'No completed challenges';

  @override
  String get noMatchingChallenges => 'No matching challenges';

  @override
  String get checkBackLater => 'Check back later for new challenges!';

  @override
  String get joinChallengeToStart => 'Join a challenge to get started!';

  @override
  String get completeChallengesToSee => 'Complete challenges to see them here!';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String joinedChallengeSuccess(String challengeTitle) {
    return '🎉 Joined \"$challengeTitle\"!';
  }

  @override
  String get joinChallengeTitle => 'Join Challenge?';

  @override
  String stepsInDays(int steps, int days) {
    return '🎯 $steps steps in $days days';
  }

  @override
  String get shareMilestone => 'Share Milestone';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get beFirstToShare => 'Be the first to share!';

  @override
  String get shareWithCommunity => 'Share with Community';

  @override
  String get whatToShare => 'What would you like to share?';

  @override
  String get postBtn => 'Post';

  @override
  String get likePostSemantics => 'Like post';

  @override
  String get commentPostSemantics => 'Comment on post';

  @override
  String get sharePostSemantics => 'Share post';

  @override
  String get corporateWellness => 'Corporate Wellness';

  @override
  String employeeId(String id) {
    return 'Employee #$id';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get you => 'You';

  @override
  String get colleague => 'Colleague';

  @override
  String get notACompanyMember => 'Not a member of any company';

  @override
  String get joinCompanyTitle => 'Join Company';

  @override
  String get enterCompanyCode => 'Enter Company Code';

  @override
  String get companyCodeSubtitle =>
      'Get your unique code from your HR or wellness administrator to join your colleagues.';

  @override
  String get inviteCodeLabel => 'Invite Code';

  @override
  String get inviteCodeHint => 'e.g. CORP2024';

  @override
  String get failedToJoin => 'Failed to join';

  @override
  String get invalidCodeOrJoined => 'Invalid code or already joined';

  @override
  String get dashboardError =>
      'Something went wrong. Please check your internet connection and try again.';

  @override
  String get setDailyGoal => 'Set Daily Goal';

  @override
  String get enterNewTarget => 'Enter your new target for daily steps:';

  @override
  String get stepsGoal => 'Steps Goal';

  @override
  String goalUpdated(int newGoal) {
    return 'Goal updated to $newGoal steps!';
  }

  @override
  String get saveGoal => 'Save Goal';

  @override
  String get pressBackToExit => 'Press back again to exit';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get noDevicesConnected => 'No devices connected';

  @override
  String get connectWearablePrompt => 'Connect your wearable to sync steps';

  @override
  String get connectHealthApp => 'Connect Health App';

  @override
  String get syncSteps => 'Sync steps';

  @override
  String get disconnectDeviceTitle => 'Disconnect Device?';

  @override
  String disconnectDeviceConfirm(String deviceName) {
    return 'Are you sure you want to disconnect \"$deviceName\"?';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String deviceDisconnectedSuccess(String deviceName) {
    return '\"$deviceName\" disconnected successfully';
  }

  @override
  String get disconnectDeviceTooltip => 'Disconnect device';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get lastSyncLabel => 'Last Sync';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusSyncing => 'Syncing...';

  @override
  String get statusSyncError => 'Sync Error';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get never => 'Never';

  @override
  String get friendLeaderboard => '🏆 Friend Leaderboard';

  @override
  String get top5Today => 'Top 5 Today';

  @override
  String get allFriends => 'All Friends';

  @override
  String friendsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get searchOrInviteFriends =>
      'Search for users or invite friends to join!';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to $name';
  }

  @override
  String get addFriend => 'Add';

  @override
  String get statusFriends => 'Friends';

  @override
  String get statusPending => 'Pending';

  @override
  String boostSent(String name) {
    return '⚡ Boost sent to $name!';
  }

  @override
  String get searchFriendsOrUsers => 'Search friends or users...';

  @override
  String stepsToday(String steps) {
    return '$steps steps today';
  }

  @override
  String get boostSentStatus => 'Sent';

  @override
  String get boostAction => 'Boost';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnlocked => 'Unlocked';

  @override
  String get filterLocked => 'Locked';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categorySocial => 'Social';

  @override
  String get unlockCriteria => 'Unlock Criteria:';

  @override
  String percentCompleted(int progress) {
    return '$progress% completed';
  }

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get sharingBadge => 'Sharing badge...';

  @override
  String get noBadgesFound => 'No badges found';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get levelTitle => 'LEVEL';

  @override
  String get xpText => 'XP';

  @override
  String get globalRank => 'Global Rank';

  @override
  String get adventureQuests => 'Adventure Quests';

  @override
  String get adventureQuestsDesc => 'Embark on story-driven journeys';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get startWalkingXp =>
      'Start walking to earn XP and see your progress!';

  @override
  String get corporate => 'Corporate';

  @override
  String get leaderboardEmpty => 'Leaderboard is empty';

  @override
  String get startWalkingLeaderboard => 'Start walking to appear here!';

  @override
  String get timeDaily => 'Today';

  @override
  String get timeWeekly => 'This Week';

  @override
  String get timeMonthly => 'This Month';

  @override
  String get timeAllTime => 'All Time';

  @override
  String get onFire => 'On Fire!';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get streakHistory => 'Streak History';

  @override
  String bestStreak(int longest) {
    return 'Best: $longest days';
  }

  @override
  String get thisWeeksActivity => 'This Week\'s Activity';

  @override
  String get activity => 'Activity';

  @override
  String get streakAchievements => 'Streak Achievements';

  @override
  String get noStreakAchievements => 'No streak achievements yet';

  @override
  String get keepWalkingStreak => 'Keep walking daily to unlock streak badges!';

  @override
  String activeDays(int count) {
    return '$count active';
  }

  @override
  String get gamificationRules => 'Gamification Rules';

  @override
  String get howItWorks => 'How it Works';

  @override
  String get howItWorksDesc =>
      'Earn XP by staying active and engaging with the community. Level up to unlock exclusive badges, avatar frames, and multipliers for step coins!';

  @override
  String get howToEarnXp => 'How to Earn XP';

  @override
  String get levelLadder => 'Level Ladder';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String youSaid(String message) {
    return 'You said: $message';
  }

  @override
  String userSaid(String userName, String message) {
    return '$userName said: $message';
  }

  @override
  String get watchAndEarn => 'Watch & Earn';

  @override
  String get watchAdsToEarn => 'Watch ads to earn points!';

  @override
  String earnPointsPerAd(int points) {
    return 'Earn $points points per ad';
  }

  @override
  String get todayViews => 'Today';

  @override
  String get remainingViews => 'Remaining';

  @override
  String get watchAdNow => 'Watch Ad Now';

  @override
  String get nextAdAvailableIn => 'Next ad available in';

  @override
  String get dailyLimitReached => 'Daily limit reached!';

  @override
  String get comeBackTomorrow => 'Come back tomorrow';

  @override
  String get rewardEarned => 'Reward Earned!';

  @override
  String pointsAdded(int points) {
    return '+$points points';
  }

  @override
  String get awesomeBtn => 'Awesome!';

  @override
  String failedToClaimReward(String error) {
    return 'Failed to claim reward: $error';
  }

  @override
  String get wellnexPremium => 'Wellnex Premium';

  @override
  String get adFreeExperience => 'Ad Free Experience';

  @override
  String get upgradeBtn => 'Upgrade';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appName => 'Wellnex';

  @override
  String get appTagline => 'Walk • Track • Earn';

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
  String get watchAdsDeals => 'Watch adverts & deals';

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

  @override
  String get activityHistory => 'Activity History';

  @override
  String get noActivitiesYet => 'No activities yet';

  @override
  String get logFirstWorkout => 'Log your first workout to see it here!';

  @override
  String get logWorkout => 'Log Workout';

  @override
  String get whatDidYouDoToday => 'What did you do today?';

  @override
  String get activityType => 'Activity Type';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String earnPointsMultiplier(String multiplier) {
    return 'Earn ${multiplier}x points for this activity!';
  }

  @override
  String get logWorkoutAndEarn => 'Log Workout & Earn Points';

  @override
  String get gpsRouteTracker => 'GPS Route Tracker';

  @override
  String get endTracking => 'End';

  @override
  String get acquiringGps => 'Acquiring GPS signal...';

  @override
  String get tapStartToTrack => 'Tap Start to begin tracking your route';

  @override
  String get saveWorkoutTitle => 'Save Workout?';

  @override
  String saveWorkoutDesc(String distance, String duration) {
    return 'You travelled $distance km in $duration.\n\nSave this route to earn points?';
  }

  @override
  String get discard => 'Discard';

  @override
  String get saveRoute => 'Save Route';

  @override
  String get routeTooShort => 'Route too short to save.';

  @override
  String durationMustBeAtLeast(int minutes) {
    return 'Duration must be at least $minutes minute.';
  }

  @override
  String durationExceedsMax(int minutes) {
    return 'Duration cannot exceed $minutes minutes.';
  }

  @override
  String distanceUnrealistic(
      String distance, int minutes, String activityName) {
    return 'Distance entered ($distance km) is unrealistic for $minutes minutes of $activityName.';
  }

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get loginSubtitle =>
      'Walk more. Earn more.\nJoin the movement safely.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get termsAndPrivacy =>
      'By continuing, you agree to our Terms & Privacy Policy';

  @override
  String signInFailed(String providerName, String error) {
    return 'Failed to sign in with $providerName: $error';
  }

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String enterOtpSentTo(String identifier) {
    return 'Enter the 6-digit code sent to\n$identifier';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendButton => 'Resend';

  @override
  String get devModeOtp =>
      'Dev Mode: Check console for OTP if Twilio is not configured';

  @override
  String get enterCompleteOtp => 'Please enter the complete OTP';

  @override
  String get otpSentSuccess => 'OTP sent successfully';

  @override
  String get completeProfileTitle => 'Complete Profile';

  @override
  String get completeSetupButton => 'Complete Setup';

  @override
  String get completeProfileSubtitle =>
      'Tell us about yourself to personalise your experience.';

  @override
  String get yourName => 'Your Name';

  @override
  String get nameHint => 'e.g. Alex Step';

  @override
  String get nameTooShort => 'Name must be at least 2 chars';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get ageLabel => 'Age';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get dailyStepGoal => 'Daily Step Goal';

  @override
  String stepsCount(int steps) {
    return '$steps steps';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String errorSavingProfile(String error) {
    return 'Error saving profile: $error';
  }

  @override
  String get joinChallengeBtn => 'Join Challenge';

  @override
  String get joinNowBtn => 'Join Now! 🚀';

  @override
  String get completedStatus => 'Completed!';

  @override
  String get filterChallenges => 'Filter Challenges';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get challengeTypeLabel => 'Challenge Type';

  @override
  String get applyBtn => 'Apply';

  @override
  String get resetBtn => 'Reset';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get iAgreeToTerms => 'I agree to the challenge Terms & Conditions';

  @override
  String get searchChallenges => 'Search challenges...';

  @override
  String get noNewChallenges => 'No new challenges';

  @override
  String get noOngoingChallenges => 'No ongoing challenges';

  @override
  String get noCompletedChallenges => 'No completed challenges';

  @override
  String get noMatchingChallenges => 'No matching challenges';

  @override
  String get checkBackLater => 'Check back later for new challenges!';

  @override
  String get joinChallengeToStart => 'Join a challenge to get started!';

  @override
  String get completeChallengesToSee => 'Complete challenges to see them here!';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String joinedChallengeSuccess(String challengeTitle) {
    return '🎉 Joined \"$challengeTitle\"!';
  }

  @override
  String get joinChallengeTitle => 'Join Challenge?';

  @override
  String stepsInDays(int steps, int days) {
    return '🎯 $steps steps in $days days';
  }

  @override
  String get shareMilestone => 'Share Milestone';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get beFirstToShare => 'Be the first to share!';

  @override
  String get shareWithCommunity => 'Share with Community';

  @override
  String get whatToShare => 'What would you like to share?';

  @override
  String get postBtn => 'Post';

  @override
  String get likePostSemantics => 'Like post';

  @override
  String get commentPostSemantics => 'Comment on post';

  @override
  String get sharePostSemantics => 'Share post';

  @override
  String get corporateWellness => 'Corporate Wellness';

  @override
  String employeeId(String id) {
    return 'Employee #$id';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get you => 'You';

  @override
  String get colleague => 'Colleague';

  @override
  String get notACompanyMember => 'Not a member of any company';

  @override
  String get joinCompanyTitle => 'Join Company';

  @override
  String get enterCompanyCode => 'Enter Company Code';

  @override
  String get companyCodeSubtitle =>
      'Get your unique code from your HR or wellness administrator to join your colleagues.';

  @override
  String get inviteCodeLabel => 'Invite Code';

  @override
  String get inviteCodeHint => 'e.g. CORP2024';

  @override
  String get failedToJoin => 'Failed to join';

  @override
  String get invalidCodeOrJoined => 'Invalid code or already joined';

  @override
  String get dashboardError =>
      'Something went wrong. Please check your internet connection and try again.';

  @override
  String get setDailyGoal => 'Set Daily Goal';

  @override
  String get enterNewTarget => 'Enter your new target for daily steps:';

  @override
  String get stepsGoal => 'Steps Goal';

  @override
  String goalUpdated(int newGoal) {
    return 'Goal updated to $newGoal steps!';
  }

  @override
  String get saveGoal => 'Save Goal';

  @override
  String get pressBackToExit => 'Press back again to exit';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get noDevicesConnected => 'No devices connected';

  @override
  String get connectWearablePrompt => 'Connect your wearable to sync steps';

  @override
  String get connectHealthApp => 'Connect Health App';

  @override
  String get syncSteps => 'Sync steps';

  @override
  String get disconnectDeviceTitle => 'Disconnect Device?';

  @override
  String disconnectDeviceConfirm(String deviceName) {
    return 'Are you sure you want to disconnect \"$deviceName\"?';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String deviceDisconnectedSuccess(String deviceName) {
    return '\"$deviceName\" disconnected successfully';
  }

  @override
  String get disconnectDeviceTooltip => 'Disconnect device';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get lastSyncLabel => 'Last Sync';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusSyncing => 'Syncing...';

  @override
  String get statusSyncError => 'Sync Error';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get never => 'Never';

  @override
  String get friendLeaderboard => '🏆 Friend Leaderboard';

  @override
  String get top5Today => 'Top 5 Today';

  @override
  String get allFriends => 'All Friends';

  @override
  String friendsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get searchOrInviteFriends =>
      'Search for users or invite friends to join!';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to $name';
  }

  @override
  String get addFriend => 'Add';

  @override
  String get statusFriends => 'Friends';

  @override
  String get statusPending => 'Pending';

  @override
  String boostSent(String name) {
    return '⚡ Boost sent to $name!';
  }

  @override
  String get searchFriendsOrUsers => 'Search friends or users...';

  @override
  String stepsToday(String steps) {
    return '$steps steps today';
  }

  @override
  String get boostSentStatus => 'Sent';

  @override
  String get boostAction => 'Boost';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnlocked => 'Unlocked';

  @override
  String get filterLocked => 'Locked';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categorySocial => 'Social';

  @override
  String get unlockCriteria => 'Unlock Criteria:';

  @override
  String percentCompleted(int progress) {
    return '$progress% completed';
  }

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get sharingBadge => 'Sharing badge...';

  @override
  String get noBadgesFound => 'No badges found';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get levelTitle => 'LEVEL';

  @override
  String get xpText => 'XP';

  @override
  String get globalRank => 'Global Rank';

  @override
  String get adventureQuests => 'Adventure Quests';

  @override
  String get adventureQuestsDesc => 'Embark on story-driven journeys';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get startWalkingXp =>
      'Start walking to earn XP and see your progress!';

  @override
  String get corporate => 'Corporate';

  @override
  String get leaderboardEmpty => 'Leaderboard is empty';

  @override
  String get startWalkingLeaderboard => 'Start walking to appear here!';

  @override
  String get timeDaily => 'Today';

  @override
  String get timeWeekly => 'This Week';

  @override
  String get timeMonthly => 'This Month';

  @override
  String get timeAllTime => 'All Time';

  @override
  String get onFire => 'On Fire!';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get streakHistory => 'Streak History';

  @override
  String bestStreak(int longest) {
    return 'Best: $longest days';
  }

  @override
  String get thisWeeksActivity => 'This Week\'s Activity';

  @override
  String get activity => 'Activity';

  @override
  String get streakAchievements => 'Streak Achievements';

  @override
  String get noStreakAchievements => 'No streak achievements yet';

  @override
  String get keepWalkingStreak => 'Keep walking daily to unlock streak badges!';

  @override
  String activeDays(int count) {
    return '$count active';
  }

  @override
  String get gamificationRules => 'Gamification Rules';

  @override
  String get howItWorks => 'How it Works';

  @override
  String get howItWorksDesc =>
      'Earn XP by staying active and engaging with the community. Level up to unlock exclusive badges, avatar frames, and multipliers for step coins!';

  @override
  String get howToEarnXp => 'How to Earn XP';

  @override
  String get levelLadder => 'Level Ladder';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String youSaid(String message) {
    return 'You said: $message';
  }

  @override
  String userSaid(String userName, String message) {
    return '$userName said: $message';
  }

  @override
  String get watchAndEarn => 'Watch & Earn';

  @override
  String get watchAdsToEarn => 'Watch ads to earn points!';

  @override
  String earnPointsPerAd(int points) {
    return 'Earn $points points per ad';
  }

  @override
  String get todayViews => 'Today';

  @override
  String get remainingViews => 'Remaining';

  @override
  String get watchAdNow => 'Watch Ad Now';

  @override
  String get nextAdAvailableIn => 'Next ad available in';

  @override
  String get dailyLimitReached => 'Daily limit reached!';

  @override
  String get comeBackTomorrow => 'Come back tomorrow';

  @override
  String get rewardEarned => 'Reward Earned!';

  @override
  String pointsAdded(int points) {
    return '+$points points';
  }

  @override
  String get awesomeBtn => 'Awesome!';

  @override
  String failedToClaimReward(String error) {
    return 'Failed to claim reward: $error';
  }

  @override
  String get wellnexPremium => 'Wellnex Premium';

  @override
  String get adFreeExperience => 'Ad Free Experience';

  @override
  String get upgradeBtn => 'Upgrade';
}

/// The translations for English, as used in India (`en_IN`).
class AppLocalizationsEnIn extends AppLocalizationsEn {
  AppLocalizationsEnIn() : super('en_IN');

  @override
  String get appName => 'Wellnex';

  @override
  String get appTagline => 'Walk • Track • Earn';

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

  @override
  String get activityHistory => 'Activity History';

  @override
  String get noActivitiesYet => 'No activities yet';

  @override
  String get logFirstWorkout => 'Log your first workout to see it here!';

  @override
  String get logWorkout => 'Log Workout';

  @override
  String get whatDidYouDoToday => 'What did you do today?';

  @override
  String get activityType => 'Activity Type';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get distanceKm => 'Distance (km)';

  @override
  String earnPointsMultiplier(String multiplier) {
    return 'Earn ${multiplier}x points for this activity!';
  }

  @override
  String get logWorkoutAndEarn => 'Log Workout & Earn Points';

  @override
  String get gpsRouteTracker => 'GPS Route Tracker';

  @override
  String get endTracking => 'End';

  @override
  String get acquiringGps => 'Acquiring GPS signal...';

  @override
  String get tapStartToTrack => 'Tap Start to begin tracking your route';

  @override
  String get saveWorkoutTitle => 'Save Workout?';

  @override
  String saveWorkoutDesc(String distance, String duration) {
    return 'You travelled $distance km in $duration.\n\nSave this route to earn points?';
  }

  @override
  String get discard => 'Discard';

  @override
  String get saveRoute => 'Save Route';

  @override
  String get routeTooShort => 'Route too short to save.';

  @override
  String durationMustBeAtLeast(int minutes) {
    return 'Duration must be at least $minutes minute.';
  }

  @override
  String durationExceedsMax(int minutes) {
    return 'Duration cannot exceed $minutes minutes.';
  }

  @override
  String distanceUnrealistic(
      String distance, int minutes, String activityName) {
    return 'Distance entered ($distance km) is unrealistic for $minutes minutes of $activityName.';
  }

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get loginSubtitle =>
      'Walk more. Earn more.\nJoin the movement safely.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get termsAndPrivacy =>
      'By continuing, you agree to our Terms & Privacy Policy';

  @override
  String signInFailed(String providerName, String error) {
    return 'Failed to sign in with $providerName: $error';
  }

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String enterOtpSentTo(String identifier) {
    return 'Enter the 6-digit code sent to\n$identifier';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code? ';

  @override
  String resendInSeconds(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendButton => 'Resend';

  @override
  String get devModeOtp =>
      'Dev Mode: Check console for OTP if Twilio is not configured';

  @override
  String get enterCompleteOtp => 'Please enter the complete OTP';

  @override
  String get otpSentSuccess => 'OTP sent successfully';

  @override
  String get completeProfileTitle => 'Complete Profile';

  @override
  String get completeSetupButton => 'Complete Setup';

  @override
  String get completeProfileSubtitle =>
      'Tell us about yourself to personalise your experience.';

  @override
  String get yourName => 'Your Name';

  @override
  String get nameHint => 'e.g. Alex Step';

  @override
  String get nameTooShort => 'Name must be at least 2 chars';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get ageLabel => 'Age';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get dailyStepGoal => 'Daily Step Goal';

  @override
  String stepsCount(int steps) {
    return '$steps steps';
  }

  @override
  String get fieldRequired => 'Required';

  @override
  String errorSavingProfile(String error) {
    return 'Error saving profile: $error';
  }

  @override
  String get joinChallengeBtn => 'Join Challenge';

  @override
  String get joinNowBtn => 'Join Now! 🚀';

  @override
  String get completedStatus => 'Completed!';

  @override
  String get filterChallenges => 'Filter Challenges';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get challengeTypeLabel => 'Challenge Type';

  @override
  String get applyBtn => 'Apply';

  @override
  String get resetBtn => 'Reset';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get iAgreeToTerms => 'I agree to the challenge Terms & Conditions';

  @override
  String get searchChallenges => 'Search challenges...';

  @override
  String get noNewChallenges => 'No new challenges';

  @override
  String get noOngoingChallenges => 'No ongoing challenges';

  @override
  String get noCompletedChallenges => 'No completed challenges';

  @override
  String get noMatchingChallenges => 'No matching challenges';

  @override
  String get checkBackLater => 'Check back later for new challenges!';

  @override
  String get joinChallengeToStart => 'Join a challenge to get started!';

  @override
  String get completeChallengesToSee => 'Complete challenges to see them here!';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search or filters';

  @override
  String joinedChallengeSuccess(String challengeTitle) {
    return '🎉 Joined \"$challengeTitle\"!';
  }

  @override
  String get joinChallengeTitle => 'Join Challenge?';

  @override
  String stepsInDays(int steps, int days) {
    return '🎯 $steps steps in $days days';
  }

  @override
  String get shareMilestone => 'Share Milestone';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get beFirstToShare => 'Be the first to share!';

  @override
  String get shareWithCommunity => 'Share with Community';

  @override
  String get whatToShare => 'What would you like to share?';

  @override
  String get postBtn => 'Post';

  @override
  String get likePostSemantics => 'Like post';

  @override
  String get commentPostSemantics => 'Comment on post';

  @override
  String get sharePostSemantics => 'Share post';

  @override
  String get corporateWellness => 'Corporate Wellness';

  @override
  String employeeId(String id) {
    return 'Employee #$id';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get you => 'You';

  @override
  String get colleague => 'Colleague';

  @override
  String get notACompanyMember => 'Not a member of any company';

  @override
  String get joinCompanyTitle => 'Join Company';

  @override
  String get enterCompanyCode => 'Enter Company Code';

  @override
  String get companyCodeSubtitle =>
      'Get your unique code from your HR or wellness administrator to join your colleagues.';

  @override
  String get inviteCodeLabel => 'Invite Code';

  @override
  String get inviteCodeHint => 'e.g. CORP2024';

  @override
  String get failedToJoin => 'Failed to join';

  @override
  String get invalidCodeOrJoined => 'Invalid code or already joined';

  @override
  String get dashboardError =>
      'Something went wrong. Please check your internet connection and try again.';

  @override
  String get setDailyGoal => 'Set Daily Goal';

  @override
  String get enterNewTarget => 'Enter your new target for daily steps:';

  @override
  String get stepsGoal => 'Steps Goal';

  @override
  String goalUpdated(int newGoal) {
    return 'Goal updated to $newGoal steps!';
  }

  @override
  String get saveGoal => 'Save Goal';

  @override
  String get pressBackToExit => 'Press back again to exit';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get noDevicesConnected => 'No devices connected';

  @override
  String get connectWearablePrompt => 'Connect your wearable to sync steps';

  @override
  String get connectHealthApp => 'Connect Health App';

  @override
  String get syncSteps => 'Sync steps';

  @override
  String get disconnectDeviceTitle => 'Disconnect Device?';

  @override
  String disconnectDeviceConfirm(String deviceName) {
    return 'Are you sure you want to disconnect \"$deviceName\"?';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String deviceDisconnectedSuccess(String deviceName) {
    return '\"$deviceName\" disconnected successfully';
  }

  @override
  String get disconnectDeviceTooltip => 'Disconnect device';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get lastSyncLabel => 'Last Sync';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusSyncing => 'Syncing...';

  @override
  String get statusSyncError => 'Sync Error';

  @override
  String get statusDisconnected => 'Disconnected';

  @override
  String get never => 'Never';

  @override
  String get friendLeaderboard => '🏆 Friend Leaderboard';

  @override
  String get top5Today => 'Top 5 Today';

  @override
  String get allFriends => 'All Friends';

  @override
  String friendsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count friends',
      one: '1 friend',
    );
    return '$_temp0';
  }

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get searchOrInviteFriends =>
      'Search for users or invite friends to join!';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String friendRequestSent(String name) {
    return 'Friend request sent to $name';
  }

  @override
  String get addFriend => 'Add';

  @override
  String get statusFriends => 'Friends';

  @override
  String get statusPending => 'Pending';

  @override
  String boostSent(String name) {
    return '⚡ Boost sent to $name!';
  }

  @override
  String get searchFriendsOrUsers => 'Search friends or users...';

  @override
  String stepsToday(String steps) {
    return '$steps steps today';
  }

  @override
  String get boostSentStatus => 'Sent';

  @override
  String get boostAction => 'Boost';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnlocked => 'Unlocked';

  @override
  String get filterLocked => 'Locked';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get categorySocial => 'Social';

  @override
  String get unlockCriteria => 'Unlock Criteria:';

  @override
  String percentCompleted(int progress) {
    return '$progress% completed';
  }

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get sharingBadge => 'Sharing badge...';

  @override
  String get noBadgesFound => 'No badges found';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String get levelTitle => 'LEVEL';

  @override
  String get xpText => 'XP';

  @override
  String get globalRank => 'Global Rank';

  @override
  String get adventureQuests => 'Adventure Quests';

  @override
  String get adventureQuestsDesc => 'Embark on story-driven journeys';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get startWalkingXp =>
      'Start walking to earn XP and see your progress!';

  @override
  String get corporate => 'Corporate';

  @override
  String get leaderboardEmpty => 'Leaderboard is empty';

  @override
  String get startWalkingLeaderboard => 'Start walking to appear here!';

  @override
  String get timeDaily => 'Today';

  @override
  String get timeWeekly => 'This Week';

  @override
  String get timeMonthly => 'This Month';

  @override
  String get timeAllTime => 'All Time';

  @override
  String get onFire => 'On Fire!';

  @override
  String get yourRank => 'Your Rank';

  @override
  String get streakHistory => 'Streak History';

  @override
  String bestStreak(int longest) {
    return 'Best: $longest days';
  }

  @override
  String get thisWeeksActivity => 'This Week\'s Activity';

  @override
  String get activity => 'Activity';

  @override
  String get streakAchievements => 'Streak Achievements';

  @override
  String get noStreakAchievements => 'No streak achievements yet';

  @override
  String get keepWalkingStreak => 'Keep walking daily to unlock streak badges!';

  @override
  String activeDays(int count) {
    return '$count active';
  }

  @override
  String get gamificationRules => 'Gamification Rules';

  @override
  String get howItWorks => 'How it Works';

  @override
  String get howItWorksDesc =>
      'Earn XP by staying active and engaging with the community. Level up to unlock exclusive badges, avatar frames, and multipliers for step coins!';

  @override
  String get howToEarnXp => 'How to Earn XP';

  @override
  String get levelLadder => 'Level Ladder';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String youSaid(String message) {
    return 'You said: $message';
  }

  @override
  String userSaid(String userName, String message) {
    return '$userName said: $message';
  }

  @override
  String get watchAndEarn => 'Watch & Earn';

  @override
  String get watchAdsToEarn => 'Watch ads to earn points!';

  @override
  String earnPointsPerAd(int points) {
    return 'Earn $points points per ad';
  }

  @override
  String get todayViews => 'Today';

  @override
  String get remainingViews => 'Remaining';

  @override
  String get watchAdNow => 'Watch Ad Now';

  @override
  String get nextAdAvailableIn => 'Next ad available in';

  @override
  String get dailyLimitReached => 'Daily limit reached!';

  @override
  String get comeBackTomorrow => 'Come back tomorrow';

  @override
  String get rewardEarned => 'Reward Earned!';

  @override
  String pointsAdded(int points) {
    return '+$points points';
  }

  @override
  String get awesomeBtn => 'Awesome!';

  @override
  String failedToClaimReward(String error) {
    return 'Failed to claim reward: $error';
  }

  @override
  String get wellnexPremium => 'Wellnex Premium';

  @override
  String get adFreeExperience => 'Ad Free Experience';

  @override
  String get upgradeBtn => 'Upgrade';
}
