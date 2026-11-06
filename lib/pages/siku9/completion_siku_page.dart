import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/pages/siku9/screen/jinsi_ya_kusali_novena.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/screen/bridge_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../models/ad_helper.dart';
import '../../models/siku_prayer_data.dart';
import 'package:saint_rita/pages/siku9/page_one.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/provider/language_provider.dart';

class CompletionSikuPage extends StatefulWidget {
  const CompletionSikuPage({super.key, this.showAdOnStart = true});

  final bool showAdOnStart;

  @override
  State<CompletionSikuPage> createState() => _CompletionSikuPageState();
}

class _CompletionSikuPageState extends State<CompletionSikuPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<Color?> _textColor;

  int _currentDay = 1;

  final List<Widget> actionButtons = [];

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  // ignore: unused_field
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentDay();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconScale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticInOut));
    _textColor = ColorTween(
      begin: GlassDesignSystem.emerald,
      end: GlassDesignSystem.softGold,
    ).animate(_controller);

    _initActionButtons();

    // Load and show interstitial ad on page start
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _interstitialAd = null;
                  _isInterstitialAdReady = false;
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _interstitialAd = null;
                  _isInterstitialAdReady = false;
                },
              );

          // Onyesha mara moja tu page ikifunguliwa
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load interstitial ad: $err');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _initActionButtons() {
    actionButtons.clear();
    actionButtons.addAll([
      ElevatedButton.icon(
        onPressed: _saliTena,
        icon: const Icon(Icons.refresh),
        label: const Text("Sali Tena", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.emerald,
        ),
      ),
      ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Anzisha Novena Upya"),
                content: const Text(
                  "Kama kweli unataka uanzishe novena upya, bonyeza kitufe cha Ruhusu",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Zuhia"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Funga dialog ya kwanza

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          final ValueNotifier<bool> isLoading = ValueNotifier(
                            true,
                          );

                          // Processing: reset progress
                          Future.delayed(const Duration(seconds: 2), () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt("novenaProgress", 0);
                            await prefs.setBool("novenaCompleted", false);
                            final notifications = context
                                .read<NotificationProvider>();
                            if (notifications.dailyReminder)
                              await notifications.scheduleDailyPrayer();
                            isLoading.value = false;
                          });

                          return ValueListenableBuilder<bool>(
                            valueListenable: isLoading,
                            builder: (context, loading, child) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 250,
                                  child: Center(
                                    child: loading
                                        ? const CircularProgressIndicator()
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Animation
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 72,
                                                color:
                                                    GlassDesignSystem.emerald,
                                              ),
                                              const SizedBox(height: 12),
                                              // Maneno chini ya animation
                                              const Text(
                                                "Novena imesha anzishwa upya",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      GlassDesignSystem.emerald,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                actions: loading
                                    ? null
                                    : [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Sawa"),
                                        ),
                                      ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: const Text("Ruhusu"),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text(
          "Anza Novena Upya ya Mt. Rita",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.divineBlue,
        ),
      ),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => JinsiYaKusaliSikuPage()),
          );
        },
        icon: const Icon(Icons.menu_book),
        label: const Text(
          "Namna Bora ya Kusali",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.divineBlue,
        ),
      ),
    ]);
  }

  Future<void> _loadCurrentDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDay = prefs.getInt("novenaProgress") ?? 1;
    });
  }

  Future<void> _saliTena() async {
    final prefs = await SharedPreferences.getInstance();
    final novenaData = await fetchPrayer(context);
    final totalDays = novenaData.novena.length;
    final todayIndex = (_currentDay <= totalDays)
        ? _currentDay - 1
        : totalDays - 1;
    final todayDay = novenaData.novena[todayIndex];

    final completed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageOne(day: todayDay)),
    );

    if (completed == true) {
      if (_currentDay < 9) {
        setState(() {
          _currentDay += 1;
        });
        await prefs.setInt("novenaProgress", _currentDay);
      } else if (_currentDay == 9) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageOne(day: todayDay)),
        );
      }
    }

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    if (notificationProvider.dailyReminder) {
      await notificationProvider.scheduleDailyPrayer();
    }
  }

  Future<NovenaDailyPrayer> fetchPrayer(BuildContext context) async {
    final sw = context.read<LanguageProvider>().isSwahili;
    final jsonString = await DefaultAssetBundle.of(context).loadString(
      sw
          ? 'assets/data/prayer-siku-tisa.json'
          : 'assets/data/prayer-siku-tisa-en.json',
    );
    return novenaDailyPrayerFromMap(jsonString);
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<LanguageProvider>().isSwahili;
    final nextDay = _currentDay < 9 ? _currentDay + 1 : 1;
    final ink = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(sw ? 'Hongera!' : 'Well done'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [Color(0xFF102940), Color(0xFF0B1D30)]
                      : const [Color(0xFFEAF6FC), Color(0xFFF5FAFD)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => Transform.scale(
                            scale: _iconScale.value,
                            child: child,
                          ),
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GlassDesignSystem.emerald.withValues(
                                alpha: .12,
                              ),
                              border: Border.all(
                                color: GlassDesignSystem.emerald.withValues(
                                  alpha: .28,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GlassDesignSystem.emerald.withValues(
                                    alpha: .14,
                                  ),
                                  blurRadius: 25,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              size: 52,
                              color: GlassDesignSystem.emerald,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          sw
                              ? 'Umemaliza siku ya $_currentDay'
                              : 'Day $_currentDay complete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: _textColor.value,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sw
                              ? 'Hongera kwa kuendelea na novena ya Mt. Rita. Utakumbushwa kesho siku ya $nextDay, dakika 5 kabla.'
                              : 'Thank you for continuing your St Rita novena. You’ll be reminded five minutes before day $nextDay tomorrow.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: ink.withValues(alpha: .72),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sw
                              ? 'Endelea kumkaribia Mungu kwa sala na tumaini.'
                              : 'Continue drawing closer to God through prayer and hope.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                            color: ink.withValues(alpha: .64),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: actionButtons,
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BridgeScreen()),
                          ),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(sw ? 'Rudi nyumbani' : 'Return home'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(
                              color: GlassDesignSystem.emerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
