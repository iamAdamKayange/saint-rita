import 'package:flutter/material.dart';
import 'package:saint_rita/localization/translations_en.dart';
import 'package:saint_rita/localization/translations_sw.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();
  
  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'sw':
        return TranslationsSw.strings;
      case 'en':
      default:
        return TranslationsEn.strings;
    }
  }
  
  // General
  String get appName => _strings['appName'] ?? 'Rita Wa Kashia';
  String get loading => _strings['loading'] ?? 'Loading...';
  String get error => _strings['error'] ?? 'Error';
  String get success => _strings['success'] ?? 'Success';
  String get cancel => _strings['cancel'] ?? 'Cancel';
  String get confirm => _strings['confirm'] ?? 'Confirm';
  String get save => _strings['save'] ?? 'Save';
  String get delete => _strings['delete'] ?? 'Delete';
  String get edit => _strings['edit'] ?? 'Edit';
  String get close => _strings['close'] ?? 'Close';
  String get back => _strings['back'] ?? 'Back';
  String get next => _strings['next'] ?? 'Next';
  String get skip => _strings['skip'] ?? 'Skip';
  String get done => _strings['done'] ?? 'Done';
  
  // Auth
  String get signIn => _strings['signIn'] ?? 'Sign In';
  String get signUp => _strings['signUp'] ?? 'Sign Up';
  String get signOut => _strings['signOut'] ?? 'Sign Out';
  String get email => _strings['email'] ?? 'Email';
  String get password => _strings['password'] ?? 'Password';
  String get confirmPassword => _strings['confirmPassword'] ?? 'Confirm Password';
  String get forgotPassword => _strings['forgotPassword'] ?? 'Forgot Password?';
  String get signInWithGoogle => _strings['signInWithGoogle'] ?? 'Sign in with Google';
  String get dontHaveAccount => _strings['dontHaveAccount'] ?? "Don't have an account?";
  String get alreadyHaveAccount => _strings['alreadyHaveAccount'] ?? 'Already have an account?';
  String get welcome => _strings['welcome'] ?? 'Welcome';
  String get hello => _strings['hello'] ?? 'Hello!';
  
  // Navigation
  String get home => _strings['home'] ?? 'Home';
  String get prayers => _strings['prayers'] ?? 'Prayers';
  String get history => _strings['history'] ?? 'History';
  String get settings => _strings['settings'] ?? 'Settings';
  String get premium => _strings['premium'] ?? 'Premium';
  String get nyumbani => _strings['nyumbani'] ?? 'Nyumbani';
  String get maombi => _strings['maombi'] ?? 'Maombi';
  String get historia => _strings['historia'] ?? 'Historia';
  String get mipangilio => _strings['mipangilio'] ?? 'Mipangilio';
  
  // Prayers
  String get novena => _strings['novena'] ?? 'Novena';
  String get dailyPrayer => _strings['dailyPrayer'] ?? 'Daily Prayer';
  String get prayerProgress => _strings['prayerProgress'] ?? 'Prayer Progress';
  String get daysCompleted => _strings['daysCompleted'] ?? 'Days Completed';
  String get startPrayer => _strings['startPrayer'] ?? 'Start Prayer';
  String get continuePrayer => _strings['continuePrayer'] ?? 'Continue Prayer';
  String get completePrayer => _strings['completePrayer'] ?? 'Complete Prayer';
  String get prayerOfDay => _strings['prayerOfDay'] ?? 'Prayer of the Day';
  String get novena9Days => _strings['novena9Days'] ?? '9-Day Novena';
  String get novena15Hours => _strings['novena15Hours'] ?? '15-Hour Novena';
  
  // St. Rita
  String get stRita => _strings['stRita'] ?? 'St. Rita';
  String get stRitaTitle => _strings['stRitaTitle'] ?? 'Saint of Impossible Causes';
  String get aboutStRita => _strings['aboutStRita'] ?? 'About St. Rita';
  String get stRitaDescription => _strings['stRitaDescription'] ?? 
      'St. Rita of Cascia is the patron saint of impossible causes, difficult marriages, and abused women.';
  
  // Premium
  String get premiumFeatures => _strings['premiumFeatures'] ?? 'Premium Features';
  String get premiumUnlocked => _strings['premiumUnlocked'] ?? 'Premium Unlocked';
  String get premiumFree => _strings['premiumFree'] ?? 'All features available for free';
  String get unlimitedAccess => _strings['unlimitedAccess'] ?? 'Unlimited Access - Free Forever';
  String get exclusiveThemes => _strings['exclusiveThemes'] ?? 'Exclusive Themes';
  String get exclusiveThemesDesc => _strings['exclusiveThemesDesc'] ?? 
      'Access to premium nature themes and backgrounds';
  String get advancedCustomization => _strings['advancedCustomization'] ?? 'Advanced Customization';
  String get advancedCustomizationDesc => _strings['advancedCustomizationDesc'] ?? 
      'Control glass intensity, blur, and transparency';
  String get adFree => _strings['adFree'] ?? 'Ad-Free Experience';
  String get adFreeDesc => _strings['adFreeDesc'] ?? 'Remove all advertisements';
  String get prayerAnalytics => _strings['prayerAnalytics'] ?? 'Prayer Analytics';
  String get prayerAnalyticsDesc => _strings['prayerAnalyticsDesc'] ?? 
      'Detailed statistics and progress tracking';
  String get customBackgrounds => _strings['customBackgrounds'] ?? 'Custom Backgrounds';
  String get customBackgroundsDesc => _strings['customBackgroundsDesc'] ?? 
      'Upload and use your own background images';
  String get glassCustomization => _strings['glassCustomization'] ?? 'Glass Customization';
  String get glassBlur => _strings['glassBlur'] ?? 'Glass Blur';
  String get glassOpacity => _strings['glassOpacity'] ?? 'Glass Opacity';
  String get selectTheme => _strings['selectTheme'] ?? 'Select Theme';
  String get natureTheme => _strings['natureTheme'] ?? 'Nature';
  String get forestTheme => _strings['forestTheme'] ?? 'Forest';
  String get oceanTheme => _strings['oceanTheme'] ?? 'Ocean';
  String get sunsetTheme => _strings['sunsetTheme'] ?? 'Sunset';
  
  // Settings
  String get darkMode => _strings['darkMode'] ?? 'Dark Mode';
  String get lightMode => _strings['lightMode'] ?? 'Light Mode';
  String get language => _strings['language'] ?? 'Language';
  String get english => _strings['english'] ?? 'English';
  String get swahili => _strings['swahili'] ?? 'Swahili';
  String get notifications => _strings['notifications'] ?? 'Notifications';
  String get enableNotifications => _strings['enableNotifications'] ?? 'Enable Notifications';
  String get prayerReminders => _strings['prayerReminders'] ?? 'Prayer Reminders';
  String get about => _strings['about'] ?? 'About';
  String get version => _strings['version'] ?? 'Version';
  String get rateApp => _strings['rateApp'] ?? 'Rate App';
  String get shareApp => _strings['shareApp'] ?? 'Share App';
  
  // Notifications
  String get notificationTitle => _strings['notificationTitle'] ?? 'Notifications';
  String get noNotifications => _strings['noNotifications'] ?? 'No notifications';
  String get markAllRead => _strings['markAllRead'] ?? 'Mark all as read';
  String get prayerReminder => _strings['prayerReminder'] ?? 'Prayer Reminder';
  String get progressUpdate => _strings['progressUpdate'] ?? 'Progress Update';
  String get generalNotification => _strings['generalNotification'] ?? 'General';
  
  // Toast Messages
  String get settingsSaved => _strings['settingsSaved'] ?? 'Settings saved successfully';
  String get prayerCompleted => _strings['prayerCompleted'] ?? 'Prayer completed successfully';
  String get pleaseFillAllFields => _strings['pleaseFillAllFields'] ?? 'Please fill all fields';
  String get invalidEmail => _strings['invalidEmail'] ?? 'Invalid email address';
  String get passwordMismatch => _strings['passwordMismatch'] ?? 'Passwords do not match';
  String get loginSuccess => _strings['loginSuccess'] ?? 'Login successful';
  String get loginFailed => _strings['loginFailed'] ?? 'Login failed';
  String get signupSuccess => _strings['signupSuccess'] ?? 'Account created successfully';
  String get signupFailed => _strings['signupFailed'] ?? 'Account creation failed';
  String get themeChanged => _strings['themeChanged'] ?? 'Theme changed successfully';
  String get languageChanged => _strings['languageChanged'] ?? 'Language changed successfully';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'sw'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}