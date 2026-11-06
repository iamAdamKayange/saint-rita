import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Centralized AdMob Configuration Service
/// Manages all AdMob ad unit IDs and provides a clean interface for ad loading
class AdMobConfig {
  // Your AdMob Configuration
  static const String _androidAppId = 'ca-app-pub-3035208509093059~5153909237';
  static const String _androidBannerAdUnitId = 'ca-app-pub-3035208509093059/6502649921';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3035208509093059/5509132450';

  // Test Ad Unit IDs (for development)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  // Whether to use test ads (set to false for production)
  static const bool _useTestAds = false;

  /// Get the App ID for the current platform
  static String get appId {
    if (Platform.isAndroid) {
      return _androidAppId;
    } else if (Platform.isIOS) {
      throw UnsupportedError('iOS AdMob not configured yet');
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }

  /// Get the Banner Ad Unit ID for the current platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _useTestAds ? _testBannerAdUnitId : _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _testBannerAdUnitId; // iOS test ID
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }

  /// Get the Interstitial Ad Unit ID for the current platform
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _useTestAds ? _testInterstitialAdUnitId : _androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _testInterstitialAdUnitId; // iOS test ID
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }

  /// Check if ads are available for the current platform
  static bool get isSupported {
    return Platform.isAndroid || Platform.isIOS;
  }
}