// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'स्टेपिफाई';

  @override
  String get appTagline => 'चलें • ट्रैक करें • कमाएँ';

  @override
  String get home => 'होम';

  @override
  String get analytics => 'एनालिटिक्स';

  @override
  String get friends => 'दोस्त';

  @override
  String get rewards => 'इनाम';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name! 👋';
  }

  @override
  String get readyToStep => 'आज कदम बढ़ाने के लिए तैयार?';

  @override
  String get steps => 'कदम';

  @override
  String stepsToGo(int count) {
    return '$count कदम बाकी';
  }

  @override
  String get goalReached => 'लक्ष्य पूरा! 🎉';

  @override
  String get adjustGoal => 'लक्ष्य बदलें';

  @override
  String get calories => 'कैलोरी';

  @override
  String get distance => 'दूरी';

  @override
  String get activeMinutes => 'सक्रिय मिनट';

  @override
  String get streak => 'स्ट्रीक';

  @override
  String streakDays(int count) {
    return '$count दिन';
  }

  @override
  String get challenges => 'चैलेंज';

  @override
  String get viewActive => 'सक्रिय देखें';

  @override
  String get earnOffers => 'कमाओ और ऑफर';

  @override
  String get watchAdsDeals => 'विज्ञापन और डील देखें';

  @override
  String get community => 'समुदाय';

  @override
  String get feedMilestones => 'फ़ीड और उपलब्धियां';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get leaderboard => 'लीडरबोर्ड';

  @override
  String get badges => 'बैज';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'कुछ गलत हो गया';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'अगला';

  @override
  String get back => 'वापस';

  @override
  String get continue_ => 'जारी रखें';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get pullToRefresh => 'रीफ्रेश के लिए खींचें';

  @override
  String get today => 'आज';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get allTime => 'सभी समय';

  @override
  String get global => 'वैश्विक';

  @override
  String get referral => 'रेफरल';

  @override
  String level(int level) {
    return 'लेवल $level';
  }

  @override
  String xpPoints(int count) {
    return '$count XP';
  }

  @override
  String coins(int count) {
    return '$count सिक्के';
  }

  @override
  String get dailyGoal => 'दैनिक लक्ष्य';

  @override
  String get weeklyGoal => 'साप्ताहिक लक्ष्य';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get seeMore => 'और देखें';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get keepItUp => 'जारी रखो! 💪';

  @override
  String get almostThere => 'बस थोड़ा और!';

  @override
  String get greatProgress => 'शानदार प्रगति!';

  @override
  String get backgroundSync => 'बैकग्राउंड सिंक';

  @override
  String get backgroundSyncSubtitle => 'ऐप बंद होने पर भी सिंक करें';

  @override
  String get syncOverCellular => 'सेलुलर पर सिंक करें';

  @override
  String get syncOverCellularSubtitle =>
      'सिंकिंग के लिए मोबाइल डेटा का उपयोग करें';

  @override
  String get connectedDevices => 'कनेक्टेड डिवाइस';

  @override
  String get activityHistory => 'गतिविधि का इतिहास';

  @override
  String get noActivitiesYet => 'अभी कोई गतिविधि नहीं';

  @override
  String get logFirstWorkout =>
      'इसे यहाँ देखने के लिए अपना पहला वर्कआउट लॉग करें!';

  @override
  String get logWorkout => 'वर्कआउट लॉग करें';

  @override
  String get whatDidYouDoToday => 'आज आपने क्या किया?';

  @override
  String get activityType => 'गतिविधि का प्रकार';

  @override
  String get durationMinutes => 'अवधि (मिनट)';

  @override
  String get distanceKm => 'दूरी (किमी)';

  @override
  String earnPointsMultiplier(String multiplier) {
    return 'इस गतिविधि के लिए ${multiplier}x अंक अर्जित करें!';
  }

  @override
  String get logWorkoutAndEarn => 'वर्कआउट लॉग करें और अंक अर्जित करें';

  @override
  String get gpsRouteTracker => 'जीपीएस रूट ट्रैकर';

  @override
  String get endTracking => 'समाप्त';

  @override
  String get acquiringGps => 'जीपीएस सिग्नल प्राप्त कर रहा है...';

  @override
  String get tapStartToTrack =>
      'अपना मार्ग ट्रैक करना शुरू करने के लिए स्टार्ट पर टैप करें';

  @override
  String get saveWorkoutTitle => 'वर्कआउट सहेजें?';

  @override
  String saveWorkoutDesc(String distance, String duration) {
    return 'आपने $duration में $distance किमी की यात्रा की।\n\nअंक अर्जित करने के लिए इस मार्ग को सहेजें?';
  }

  @override
  String get discard => 'रद्द करें';

  @override
  String get saveRoute => 'मार्ग सहेजें';

  @override
  String get routeTooShort => 'सहेजने के लिए मार्ग बहुत छोटा है।';

  @override
  String durationMustBeAtLeast(int minutes) {
    return 'अवधि कम से कम $minutes मिनट होनी चाहिए।';
  }

  @override
  String durationExceedsMax(int minutes) {
    return 'अवधि $minutes मिनट से अधिक नहीं हो सकती।';
  }

  @override
  String distanceUnrealistic(
      String distance, int minutes, String activityName) {
    return 'दर्ज की गई दूरी ($distance किमी), $activityName के $minutes मिनट के लिए अवास्तविक है।';
  }

  @override
  String get aiInsights => 'एआई अंतर्दृष्टि';

  @override
  String get loginSubtitle =>
      'अधिक चलें। अधिक कमाएँ।\nसुरक्षित रूप से आंदोलन में शामिल हों।';

  @override
  String get continueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get continueWithApple => 'Apple के साथ जारी रखें';

  @override
  String get termsAndPrivacy =>
      'जारी रखकर, आप हमारी शर्तों और गोपनीयता नीति से सहमत हैं';

  @override
  String signInFailed(String providerName, String error) {
    return '$providerName के साथ साइन इन विफल: $error';
  }

  @override
  String get verifyOtpTitle => 'OTP सत्यापित करें';

  @override
  String enterOtpSentTo(String identifier) {
    return 'कृपया $identifier पर भेजा गया 6-अंकीय कोड दर्ज करें';
  }

  @override
  String get verifyButton => 'सत्यापित करें';

  @override
  String get didNotReceiveCode => 'कोड प्राप्त नहीं हुआ? ';

  @override
  String resendInSeconds(int seconds) {
    return '$seconds सेकंड में पुनः भेजें';
  }

  @override
  String get resendButton => 'पुनः भेजें';

  @override
  String get devModeOtp =>
      'डेव मोड: यदि ट्विलियो कॉन्फ़िगर नहीं है तो OTP के लिए कंसोल जांचें';

  @override
  String get enterCompleteOtp => 'कृपया पूरा OTP दर्ज करें';

  @override
  String get otpSentSuccess => 'OTP सफलतापूर्वक भेजा गया';

  @override
  String get completeProfileTitle => 'प्रोफ़ाइल पूरी करें';

  @override
  String get completeSetupButton => 'सेटअप पूरा करें';

  @override
  String get completeProfileSubtitle =>
      'अपने अनुभव को बेहतर बनाने के लिए अपने बारे में बताएं।';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get nameHint => 'जैसे: एलेक्स स्टेप';

  @override
  String get nameTooShort => 'नाम कम से कम 2 अक्षरों का होना चाहिए';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get invalidEmail => 'अमान्य ईमेल';

  @override
  String get phoneLabel => 'फ़ोन';

  @override
  String get ageLabel => 'आयु';

  @override
  String get weightLabel => 'वजन (किग्रा)';

  @override
  String get heightLabel => 'ऊंचाई (सेमी)';

  @override
  String get chooseAvatar => 'अवतार चुनें';

  @override
  String get dailyStepGoal => 'दैनिक कदम लक्ष्य';

  @override
  String stepsCount(int steps) {
    return '$steps कदम';
  }

  @override
  String get fieldRequired => 'आवश्यक';

  @override
  String errorSavingProfile(String error) {
    return 'प्रोफ़ाइल सहेजने में त्रुटि: $error';
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
  String get wellnexPremium => 'Well Nex Premium';

  @override
  String get adFreeExperience => 'Ad Free Experience';

  @override
  String get upgradeBtn => 'Upgrade';
}
