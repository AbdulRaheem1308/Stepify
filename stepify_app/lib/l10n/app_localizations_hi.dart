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
  String get appTagline => 'चलो, ट्रैक करो, इनाम पाओ';

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
  String get syncOverCellular => 'सेलुलर पर सिंक';

  @override
  String get syncOverCellularSubtitle => 'सिंक करने के लिए मोबाइल डेटा का उपयोग करें';

  @override
  String get connectedDevices => 'कनेक्टेड डिवाइस';
}
