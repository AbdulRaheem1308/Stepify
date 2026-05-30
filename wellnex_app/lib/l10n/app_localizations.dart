import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('en', 'IN'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Well Nex'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Walk • Track • Earn'**
  String get appTagline;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hey, {name}! 👋'**
  String greeting(String name);

  /// No description provided for @readyToStep.
  ///
  /// In en, this message translates to:
  /// **'Ready to step up today?'**
  String get readyToStep;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get steps;

  /// No description provided for @stepsToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} steps to go'**
  String stepsToGo(int count);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal Reached! 🎉'**
  String get goalReached;

  /// No description provided for @adjustGoal.
  ///
  /// In en, this message translates to:
  /// **'Adjust Goal'**
  String get adjustGoal;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @activeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Active Min'**
  String get activeMinutes;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @viewActive.
  ///
  /// In en, this message translates to:
  /// **'View active'**
  String get viewActive;

  /// No description provided for @earnOffers.
  ///
  /// In en, this message translates to:
  /// **'Earn & Offers'**
  String get earnOffers;

  /// No description provided for @watchAdsDeals.
  ///
  /// In en, this message translates to:
  /// **'Watch ads & deals'**
  String get watchAdsDeals;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @feedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Feed & Milestones'**
  String get feedMilestones;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// No description provided for @xpPoints.
  ///
  /// In en, this message translates to:
  /// **'{count} XP'**
  String xpPoints(int count);

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String coins(int count);

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! 💪'**
  String get keepItUp;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @greatProgress.
  ///
  /// In en, this message translates to:
  /// **'Great progress!'**
  String get greatProgress;

  /// No description provided for @backgroundSync.
  ///
  /// In en, this message translates to:
  /// **'Background Sync'**
  String get backgroundSync;

  /// No description provided for @backgroundSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync steps when app is closed'**
  String get backgroundSyncSubtitle;

  /// No description provided for @syncOverCellular.
  ///
  /// In en, this message translates to:
  /// **'Sync Over Cellular'**
  String get syncOverCellular;

  /// No description provided for @syncOverCellularSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use mobile data for syncing'**
  String get syncOverCellularSubtitle;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @noActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivitiesYet;

  /// No description provided for @logFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log your first workout to see it here!'**
  String get logFirstWorkout;

  /// No description provided for @logWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log Workout'**
  String get logWorkout;

  /// No description provided for @whatDidYouDoToday.
  ///
  /// In en, this message translates to:
  /// **'What did you do today?'**
  String get whatDidYouDoToday;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get activityType;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get distanceKm;

  /// No description provided for @earnPointsMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Earn {multiplier}x points for this activity!'**
  String earnPointsMultiplier(String multiplier);

  /// No description provided for @logWorkoutAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Log Workout & Earn Points'**
  String get logWorkoutAndEarn;

  /// No description provided for @gpsRouteTracker.
  ///
  /// In en, this message translates to:
  /// **'GPS Route Tracker'**
  String get gpsRouteTracker;

  /// No description provided for @endTracking.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTracking;

  /// No description provided for @acquiringGps.
  ///
  /// In en, this message translates to:
  /// **'Acquiring GPS signal...'**
  String get acquiringGps;

  /// No description provided for @tapStartToTrack.
  ///
  /// In en, this message translates to:
  /// **'Tap Start to begin tracking your route'**
  String get tapStartToTrack;

  /// No description provided for @saveWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Workout?'**
  String get saveWorkoutTitle;

  /// No description provided for @saveWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'You travelled {distance} km in {duration}.\n\nSave this route to earn points?'**
  String saveWorkoutDesc(String distance, String duration);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveRoute.
  ///
  /// In en, this message translates to:
  /// **'Save Route'**
  String get saveRoute;

  /// No description provided for @routeTooShort.
  ///
  /// In en, this message translates to:
  /// **'Route too short to save.'**
  String get routeTooShort;

  /// No description provided for @durationMustBeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Duration must be at least {minutes} minute.'**
  String durationMustBeAtLeast(int minutes);

  /// No description provided for @durationExceedsMax.
  ///
  /// In en, this message translates to:
  /// **'Duration cannot exceed {minutes} minutes.'**
  String durationExceedsMax(int minutes);

  /// No description provided for @distanceUnrealistic.
  ///
  /// In en, this message translates to:
  /// **'Distance entered ({distance} km) is unrealistic for {minutes} minutes of {activityName}.'**
  String distanceUnrealistic(String distance, int minutes, String activityName);

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Walk more. Earn more.\nJoin the movement safely.'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms & Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with {providerName}: {error}'**
  String signInFailed(String providerName, String error);

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to\n{identifier}'**
  String enterOtpSentTo(String identifier);

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get didNotReceiveCode;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @resendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendButton;

  /// No description provided for @devModeOtp.
  ///
  /// In en, this message translates to:
  /// **'Dev Mode: Check console for OTP if Twilio is not configured'**
  String get devModeOtp;

  /// No description provided for @enterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete OTP'**
  String get enterCompleteOtp;

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccess;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfileTitle;

  /// No description provided for @completeSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetupButton;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself to personalize your experience.'**
  String get completeProfileSubtitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex Step'**
  String get nameHint;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 chars'**
  String get nameTooShort;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @dailyStepGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Step Goal'**
  String get dailyStepGoal;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps'**
  String stepsCount(int steps);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile: {error}'**
  String errorSavingProfile(String error);

  /// No description provided for @joinChallengeBtn.
  ///
  /// In en, this message translates to:
  /// **'Join Challenge'**
  String get joinChallengeBtn;

  /// No description provided for @joinNowBtn.
  ///
  /// In en, this message translates to:
  /// **'Join Now! 🚀'**
  String get joinNowBtn;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completedStatus;

  /// No description provided for @filterChallenges.
  ///
  /// In en, this message translates to:
  /// **'Filter Challenges'**
  String get filterChallenges;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @challengeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Challenge Type'**
  String get challengeTypeLabel;

  /// No description provided for @applyBtn.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyBtn;

  /// No description provided for @resetBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetBtn;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @iAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the challenge Terms & Conditions'**
  String get iAgreeToTerms;

  /// No description provided for @searchChallenges.
  ///
  /// In en, this message translates to:
  /// **'Search challenges...'**
  String get searchChallenges;

  /// No description provided for @noNewChallenges.
  ///
  /// In en, this message translates to:
  /// **'No new challenges'**
  String get noNewChallenges;

  /// No description provided for @noOngoingChallenges.
  ///
  /// In en, this message translates to:
  /// **'No ongoing challenges'**
  String get noOngoingChallenges;

  /// No description provided for @noCompletedChallenges.
  ///
  /// In en, this message translates to:
  /// **'No completed challenges'**
  String get noCompletedChallenges;

  /// No description provided for @noMatchingChallenges.
  ///
  /// In en, this message translates to:
  /// **'No matching challenges'**
  String get noMatchingChallenges;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new challenges!'**
  String get checkBackLater;

  /// No description provided for @joinChallengeToStart.
  ///
  /// In en, this message translates to:
  /// **'Join a challenge to get started!'**
  String get joinChallengeToStart;

  /// No description provided for @completeChallengesToSee.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to see them here!'**
  String get completeChallengesToSee;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// No description provided for @joinedChallengeSuccess.
  ///
  /// In en, this message translates to:
  /// **'🎉 Joined \"{challengeTitle}\"!'**
  String joinedChallengeSuccess(String challengeTitle);

  /// No description provided for @joinChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Challenge?'**
  String get joinChallengeTitle;

  /// No description provided for @stepsInDays.
  ///
  /// In en, this message translates to:
  /// **'🎯 {steps} steps in {days} days'**
  String stepsInDays(int steps, int days);

  /// No description provided for @shareMilestone.
  ///
  /// In en, this message translates to:
  /// **'Share Milestone'**
  String get shareMilestone;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @beFirstToShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share!'**
  String get beFirstToShare;

  /// No description provided for @shareWithCommunity.
  ///
  /// In en, this message translates to:
  /// **'Share with Community'**
  String get shareWithCommunity;

  /// No description provided for @whatToShare.
  ///
  /// In en, this message translates to:
  /// **'What would you like to share?'**
  String get whatToShare;

  /// No description provided for @postBtn.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postBtn;

  /// No description provided for @likePostSemantics.
  ///
  /// In en, this message translates to:
  /// **'Like post'**
  String get likePostSemantics;

  /// No description provided for @commentPostSemantics.
  ///
  /// In en, this message translates to:
  /// **'Comment on post'**
  String get commentPostSemantics;

  /// No description provided for @sharePostSemantics.
  ///
  /// In en, this message translates to:
  /// **'Share post'**
  String get sharePostSemantics;

  /// No description provided for @corporateWellness.
  ///
  /// In en, this message translates to:
  /// **'Corporate Wellness'**
  String get corporateWellness;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee #{id}'**
  String employeeId(String id);

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @colleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get colleague;

  /// No description provided for @notACompanyMember.
  ///
  /// In en, this message translates to:
  /// **'Not a member of any company'**
  String get notACompanyMember;

  /// No description provided for @joinCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Company'**
  String get joinCompanyTitle;

  /// No description provided for @enterCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Company Code'**
  String get enterCompanyCode;

  /// No description provided for @companyCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get your unique code from your HR or wellness administrator to join your colleagues.'**
  String get companyCodeSubtitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite Code'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. CORP2024'**
  String get inviteCodeHint;

  /// No description provided for @failedToJoin.
  ///
  /// In en, this message translates to:
  /// **'Failed to join'**
  String get failedToJoin;

  /// No description provided for @invalidCodeOrJoined.
  ///
  /// In en, this message translates to:
  /// **'Invalid code or already joined'**
  String get invalidCodeOrJoined;

  /// No description provided for @dashboardError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your internet connection and try again.'**
  String get dashboardError;

  /// No description provided for @setDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Goal'**
  String get setDailyGoal;

  /// No description provided for @enterNewTarget.
  ///
  /// In en, this message translates to:
  /// **'Enter your new target for daily steps:'**
  String get enterNewTarget;

  /// No description provided for @stepsGoal.
  ///
  /// In en, this message translates to:
  /// **'Steps Goal'**
  String get stepsGoal;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated to {newGoal} steps!'**
  String goalUpdated(int newGoal);

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get saveGoal;

  /// No description provided for @pressBackToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackToExit;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @noDevicesConnected.
  ///
  /// In en, this message translates to:
  /// **'No devices connected'**
  String get noDevicesConnected;

  /// No description provided for @connectWearablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Connect your wearable to sync steps'**
  String get connectWearablePrompt;

  /// No description provided for @connectHealthApp.
  ///
  /// In en, this message translates to:
  /// **'Connect Health App'**
  String get connectHealthApp;

  /// No description provided for @syncSteps.
  ///
  /// In en, this message translates to:
  /// **'Sync steps'**
  String get syncSteps;

  /// No description provided for @disconnectDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Device?'**
  String get disconnectDeviceTitle;

  /// No description provided for @disconnectDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disconnect \"{deviceName}\"?'**
  String disconnectDeviceConfirm(String deviceName);

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @deviceDisconnectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{deviceName}\" disconnected successfully'**
  String deviceDisconnectedSuccess(String deviceName);

  /// No description provided for @disconnectDeviceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Disconnect device'**
  String get disconnectDeviceTooltip;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @lastSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSyncLabel;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get statusSyncing;

  /// No description provided for @statusSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get statusSyncError;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnected;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @friendLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'🏆 Friend Leaderboard'**
  String get friendLeaderboard;

  /// No description provided for @top5Today.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Today'**
  String get top5Today;

  /// No description provided for @allFriends.
  ///
  /// In en, this message translates to:
  /// **'All Friends'**
  String get allFriends;

  /// No description provided for @friendsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend} other{{count} friends}}'**
  String friendsCount(int count);

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @searchOrInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Search for users or invite friends to join!'**
  String get searchOrInviteFriends;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to {name}'**
  String friendRequestSent(String name);

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addFriend;

  /// No description provided for @statusFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get statusFriends;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @boostSent.
  ///
  /// In en, this message translates to:
  /// **'⚡ Boost sent to {name}!'**
  String boostSent(String name);

  /// No description provided for @searchFriendsOrUsers.
  ///
  /// In en, this message translates to:
  /// **'Search friends or users...'**
  String get searchFriendsOrUsers;

  /// No description provided for @stepsToday.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps today'**
  String stepsToday(String steps);

  /// No description provided for @boostSentStatus.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get boostSentStatus;

  /// No description provided for @boostAction.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get boostAction;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get filterUnlocked;

  /// No description provided for @filterLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get filterLocked;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @categorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get categorySocial;

  /// No description provided for @unlockCriteria.
  ///
  /// In en, this message translates to:
  /// **'Unlock Criteria:'**
  String get unlockCriteria;

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{progress}% completed'**
  String percentCompleted(int progress);

  /// No description provided for @shareAchievement.
  ///
  /// In en, this message translates to:
  /// **'Share Achievement'**
  String get shareAchievement;

  /// No description provided for @sharingBadge.
  ///
  /// In en, this message translates to:
  /// **'Sharing badge...'**
  String get sharingBadge;

  /// No description provided for @noBadgesFound.
  ///
  /// In en, this message translates to:
  /// **'No badges found'**
  String get noBadgesFound;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'LEVEL'**
  String get levelTitle;

  /// No description provided for @xpText.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xpText;

  /// No description provided for @globalRank.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get globalRank;

  /// No description provided for @adventureQuests.
  ///
  /// In en, this message translates to:
  /// **'Adventure Quests'**
  String get adventureQuests;

  /// No description provided for @adventureQuestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Embark on story-driven journeys'**
  String get adventureQuestsDesc;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @startWalkingXp.
  ///
  /// In en, this message translates to:
  /// **'Start walking to earn XP and see your progress!'**
  String get startWalkingXp;

  /// No description provided for @corporate.
  ///
  /// In en, this message translates to:
  /// **'Corporate'**
  String get corporate;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard is empty'**
  String get leaderboardEmpty;

  /// No description provided for @startWalkingLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Start walking to appear here!'**
  String get startWalkingLeaderboard;

  /// No description provided for @timeDaily.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeDaily;

  /// No description provided for @timeWeekly.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get timeWeekly;

  /// No description provided for @timeMonthly.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get timeMonthly;

  /// No description provided for @timeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get timeAllTime;

  /// No description provided for @onFire.
  ///
  /// In en, this message translates to:
  /// **'On Fire!'**
  String get onFire;

  /// No description provided for @yourRank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get yourRank;

  /// No description provided for @streakHistory.
  ///
  /// In en, this message translates to:
  /// **'Streak History'**
  String get streakHistory;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {longest} days'**
  String bestStreak(int longest);

  /// No description provided for @thisWeeksActivity.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Activity'**
  String get thisWeeksActivity;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @streakAchievements.
  ///
  /// In en, this message translates to:
  /// **'Streak Achievements'**
  String get streakAchievements;

  /// No description provided for @noStreakAchievements.
  ///
  /// In en, this message translates to:
  /// **'No streak achievements yet'**
  String get noStreakAchievements;

  /// No description provided for @keepWalkingStreak.
  ///
  /// In en, this message translates to:
  /// **'Keep walking daily to unlock streak badges!'**
  String get keepWalkingStreak;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeDays(int count);

  /// No description provided for @gamificationRules.
  ///
  /// In en, this message translates to:
  /// **'Gamification Rules'**
  String get gamificationRules;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it Works'**
  String get howItWorks;

  /// No description provided for @howItWorksDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn XP by staying active and engaging with the community. Level up to unlock exclusive badges, avatar frames, and multipliers for step coins!'**
  String get howItWorksDesc;

  /// No description provided for @howToEarnXp.
  ///
  /// In en, this message translates to:
  /// **'How to Earn XP'**
  String get howToEarnXp;

  /// No description provided for @levelLadder.
  ///
  /// In en, this message translates to:
  /// **'Level Ladder'**
  String get levelLadder;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @youSaid.
  ///
  /// In en, this message translates to:
  /// **'You said: {message}'**
  String youSaid(String message);

  /// No description provided for @userSaid.
  ///
  /// In en, this message translates to:
  /// **'{userName} said: {message}'**
  String userSaid(String userName, String message);

  /// No description provided for @watchAndEarn.
  ///
  /// In en, this message translates to:
  /// **'Watch & Earn'**
  String get watchAndEarn;

  /// No description provided for @watchAdsToEarn.
  ///
  /// In en, this message translates to:
  /// **'Watch ads to earn points!'**
  String get watchAdsToEarn;

  /// No description provided for @earnPointsPerAd.
  ///
  /// In en, this message translates to:
  /// **'Earn {points} points per ad'**
  String earnPointsPerAd(int points);

  /// No description provided for @todayViews.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayViews;

  /// No description provided for @remainingViews.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingViews;

  /// No description provided for @watchAdNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad Now'**
  String get watchAdNow;

  /// No description provided for @nextAdAvailableIn.
  ///
  /// In en, this message translates to:
  /// **'Next ad available in'**
  String get nextAdAvailableIn;

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached!'**
  String get dailyLimitReached;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get comeBackTomorrow;

  /// No description provided for @rewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Reward Earned!'**
  String get rewardEarned;

  /// No description provided for @pointsAdded.
  ///
  /// In en, this message translates to:
  /// **'+{points} points'**
  String pointsAdded(int points);

  /// No description provided for @awesomeBtn.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesomeBtn;

  /// No description provided for @failedToClaimReward.
  ///
  /// In en, this message translates to:
  /// **'Failed to claim reward: {error}'**
  String failedToClaimReward(String error);

  /// No description provided for @wellnexPremium.
  ///
  /// In en, this message translates to:
  /// **'Well Nex Premium'**
  String get wellnexPremium;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad Free Experience'**
  String get adFreeExperience;

  /// No description provided for @upgradeBtn.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
          case 'IN':
            return AppLocalizationsEnIn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
