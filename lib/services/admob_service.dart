import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:saint_rita/services/admob_config.dart';

/// Centralized AdMob Service
/// Handles Banner and Interstitial ads with proper lifecycle management
class AdMobService {
  // Singleton pattern
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  /// Load a Banner Ad
  void loadBannerAd({
    required AdSize adSize,
    void Function()? onAdLoaded,
    void Function(String error)? onAdFailedToLoad,
  }) {
    if (!AdMobConfig.isSupported) {
      debugPrint('AdMob not supported on this platform');
      return;
    }

    // Dispose existing banner ad if any
    disposeBannerAd();

    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: AdMobConfig.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner Ad loaded successfully');
          _isBannerAdLoaded = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner Ad failed to load: $error');
          ad.dispose();
          _isBannerAdLoaded = false;
          onAdFailedToLoad?.call(error.message);
        },
        onAdOpened: (ad) {
          debugPrint('Banner Ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('Banner Ad closed');
        },
      ),
      request: const AdRequest(),
    );

    _bannerAd?.load();
  }

  /// Load an Interstitial Ad
  void loadInterstitialAd({
    void Function()? onAdLoaded,
    void Function(String error)? onAdFailedToLoad,
  }) {
    if (!AdMobConfig.isSupported) {
      debugPrint('AdMob not supported on this platform');
      return;
    }

    // Dispose existing interstitial ad if any
    disposeInterstitialAd();

    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial Ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: $error');
          _isInterstitialAdLoaded = false;
          onAdFailedToLoad?.call(error.message);
        },
      ),
    );
  }

  /// Show an Interstitial Ad
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
  }) async {
    if (_interstitialAd == null || !_isInterstitialAdLoaded) {
      debugPrint('Interstitial Ad not loaded, showing ad was requested');
      // Try to load a new one
      loadInterstitialAd();
      return false;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad dismissed full screen content');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          onAdDismissed?.call();
          // Preload next interstitial ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial Ad failed to show full screen content: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          onAdFailedToShow?.call();
        },
      );

      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('Error showing Interstitial Ad: $e');
      return false;
    }
  }

  /// Dispose Banner Ad
  void disposeBannerAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
      debugPrint('Banner Ad disposed');
    }
  }

  /// Dispose Interstitial Ad
  void disposeInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      debugPrint('Interstitial Ad disposed');
    }
  }

  /// Dispose all ads
  void disposeAll() {
    disposeBannerAd();
    disposeInterstitialAd();
    debugPrint('All AdMob ads disposed');
  }
}

/// Widget to display Banner Ad
class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final void Function()? onAdLoaded;
  final void Function(String error)? onAdFailedToLoad;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.onAdLoaded,
    this.onAdFailedToLoad,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _adMobService.loadBannerAd(
      adSize: widget.adSize,
      onAdLoaded: () {
        if (mounted) {
          setState(() {});
          widget.onAdLoaded?.call();
        }
      },
      onAdFailedToLoad: widget.onAdFailedToLoad,
    );
  }

  @override
  void dispose() {
    _adMobService.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adMobService.isBannerAdLoaded && _adMobService.bannerAd != null) {
      return SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: AdWidget(ad: _adMobService.bannerAd!),
      );
    } else {
      // Return empty container when ad is not loaded
      return const SizedBox.shrink();
    }
  }
}