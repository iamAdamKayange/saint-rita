import 'package:saint_rita/services/admob_config.dart';

/// Deprecated: Use AdMobConfig instead
/// This class is kept for backward compatibility
@Deprecated('Use AdMobConfig instead')
class AdHelper {
  static String get bannerAdUnitId => AdMobConfig.bannerAdUnitId;
  static String get interstitialAdUnitId => AdMobConfig.interstitialAdUnitId;
}
