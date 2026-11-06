import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/models/ad_helper.dart';
import 'package:saint_rita/pages/masaa15/homepage_masaa.dart';
import 'package:saint_rita/glassmorphism/screens/glass_history_screen.dart';
import 'package:saint_rita/pages/masaa15/screen/setting_masaa_screen.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/glassmorphism/screens/glass_notification_screen.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/widgets/glassmorphism/novena_glass_navigation.dart';

class NovenaOne extends StatefulWidget {
  const NovenaOne({super.key});

  @override
  State<NovenaOne> createState() => _NovenaOneState();
}

class _NovenaOneState extends State<NovenaOne> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;

  final List<Widget> _pages = [
    HomePageMasaa(),
    GlassHistoryScreen(),
    SettingMasaaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint("Ad failed to load: $error");
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSwahili = context.watch<LanguageProvider>().isSwahili;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Text(
            isSwahili ? "MT Rita Wa Kashia" : "St. Rita of Cascia",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              int totalUnread = provider.notifications
                  .where((n) => !n.isRead)
                  .length;

              return Stack(
                children: [
                  IconButton(
                    color: Theme.of(context).colorScheme.onSurface,
                    iconSize: 30,
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      int index = 0;
                      if (provider.unreadDaily > 0) {
                        index = 1;
                      } else if (provider.unreadHourly > 0) {
                        index = 2;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GlassNotificationScreen(initialIndex: index),
                        ),
                      );
                    },
                  ),
                  if (totalUnread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Container(
                          key: ValueKey<int>(totalUnread),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: GlassDesignSystem.emerald,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            totalUnread > 9 ? '9+' : '$totalUnread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF102940), Color(0xFF0B1D30)]
                : const [
                    GlassDesignSystem.warmCream,
                    GlassDesignSystem.lightGlass,
                  ],
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _pages[_selectedIndex]),
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NovenaGlassNavigation(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        isSwahili: isSwahili,
      ),
    );
  }
}
