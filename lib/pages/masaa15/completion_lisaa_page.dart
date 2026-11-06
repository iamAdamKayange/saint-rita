import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/pages/masaa15/pagemasaa_one.dart';
import 'package:saint_rita/pages/masaa15/screen/jinsi_ya_kusali_screen.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/screen/bridge_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../models/ad_helper.dart';
import '../../models/masaa_prayer_data.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/provider/language_provider.dart';

class CompletionLisaaPage extends StatefulWidget {
  const CompletionLisaaPage({
    super.key,
    this.showAdOnStart = true,
    this.completedHour,
  });

  final bool showAdOnStart;
  final int? completedHour;

  @override
  State<CompletionLisaaPage> createState() => _CompletionLisaaPageState();
}

class _CompletionLisaaPageState extends State<CompletionLisaaPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconScale;
  late final Animation<Color?> _textColor;
  late final ScrollController _scrollController;

  int _currentHour = 1;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  late final List<Widget> actionButtons;

  @override
  void initState() {
    super.initState();

    _loadCurrentHour();

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

    _scrollController = ScrollController();

    _loadInterstitialAd();

    final sw = context.read<LanguageProvider>().isSwahili;
    actionButtons = [
      ElevatedButton.icon(
        onPressed: () {
          _openMasaaPage(redo: true);
        },
        icon: const Icon(Icons.refresh),
        label: Text(
          sw ? 'Sali tena saa hii' : 'Pray this hour again',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.emerald,
        ),
      ),
      ElevatedButton.icon(
        onPressed: _chooseHour,
        icon: const Icon(Icons.grid_view_rounded),
        label: Text(
          sw ? 'Chagua saa yoyote' : 'Choose any hour',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.softGold,
        ),
      ),
      ElevatedButton.icon(
        onPressed: _restartNovena,
        icon: const Icon(Icons.restart_alt_rounded),
        label: Text(
          sw ? 'Anza upya saa 1' : 'Restart from hour 1',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.divineBlue,
        ),
      ),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => JinsiYaKusaliMasaaPage()),
          );
        },
        icon: const Icon(Icons.menu_book),
        label: Text(
          sw ? 'Mwongozo wa sala' : 'Prayer guide',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassDesignSystem.divineBlue,
        ),
      ),
    ];
  }

  // Load current hour from prefs (kept same)
  Future<void> _loadCurrentHour() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final progress = prefs.getInt("novenaHourProgress") ?? 0;
      _currentHour = widget.completedHour ?? (progress == 0 ? 15 : progress);
    });
  }

  Future<NovenaHourPrayer> fetchMasaaPrayer() async {
    final sw = context.read<LanguageProvider>().isSwahili;
    final response = await rootBundle.loadString(
      sw
          ? 'assets/data/prayer-masaa-15.json'
          : 'assets/data/prayer-masaa-15-en.json',
    );
    final data = json.decode(response);
    return NovenaHourPrayer.fromJson(data);
  }

  Future<void> _openMasaaPage({bool redo = false, int? selectedHour}) async {
    final masaaData = await fetchMasaaPrayer();

    final totalHours = masaaData.novena.length;
    final prayerHour = (selectedHour ?? _currentHour).clamp(1, totalHours);
    final todayNovena = masaaData.novena[prayerHour - 1];

    // Fungua PageMasaaOne
    final completed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageMasaaOne(masaa: todayNovena)),
    );

    if (completed == true) {
      if (!redo) {
        // âœ… Only update progress once, through updatePrayerHistory
        await updatePrayerHistory(currentHour: _currentHour, redo: redo);

        // Schedule notification
        final notificationProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        if (notificationProvider.hourlyReminder) {
          await notificationProvider.scheduleHourlyPrayer();
        }
      } else {
        debugPrint("Redo prayer at hour $_currentHour, no progress increment.");
      }
    }
  }

  Future<void> updatePrayerHistory({
    required int currentHour,
    bool redo = false, // âœ… redo = true means don't increment progress
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // ðŸ”‘ Kama ni redo, tunatoka mapema â€” hakuna increment yoyote
    if (redo) {
      debugPrint("Redo prayer detected â†’ skipping progress increment.");
      return;
    }

    // âœ… Update total hours prayed
    int totalHoursPrayed = prefs.getInt('totalHoursPrayed') ?? 0;
    totalHoursPrayed += 1;
    await prefs.setInt('totalHoursPrayed', totalHoursPrayed);

    // âœ… Update hour frequency
    int hourCount = prefs.getInt('hour${currentHour}Count') ?? 0;
    hourCount += 1;
    await prefs.setInt('hour${currentHour}Count', hourCount);

    // âœ… Update last prayer date
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastPrayerDateMasaa', nowMillis);

    // âœ… Update prayer history string
    String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String historyString = prefs.getString('prayerHistoryMasaa') ?? "";
    historyString += "$todayString:$currentHour;";
    await prefs.setString('prayerHistoryMasaa', historyString);

    // âœ… Increment novenaHourProgress
    int currentHourProgress = prefs.getInt('novenaHourProgress') ?? 0;
    int medalCount = prefs.getInt('medalCount') ?? 0;

    currentHourProgress++;

    if (currentHourProgress >= 15) {
      // completed one novena
      medalCount++;
      currentHourProgress = 0;
      await prefs.setBool('novenaHourCycleCompleted', true);
      await prefs.remove('novenaHourScheduleStart');
      await prefs.setInt('medalCount', medalCount);
    }

    await prefs.setInt('novenaHourProgress', currentHourProgress);

    // âœ… Update local _currentHour for UI
    if (!mounted) return;
    setState(() {
      _currentHour = currentHourProgress == 0 ? 15 : currentHourProgress;
    });

    debugPrint("Novena progress updated. Current hour: $_currentHour");
  }

  Future<void> _restartNovena() async {
    final sw = context.read<LanguageProvider>().isSwahili;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(sw ? 'Anza novena upya?' : 'Restart this novena?'),
        content: Text(
          sw
              ? 'Maendeleo yataanzia saa ya kwanza. Rekodi za sala ulizokamilisha hazitafutwa.'
              : 'Progress will return to hour one. Your completed prayer history will remain saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(sw ? 'Ghairi' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(sw ? 'Anza upya' : 'Restart'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('novenaHourProgress', 0);
    await prefs.setBool('novenaHourCycleCompleted', false);
    await prefs.remove('novenaHourScheduleStart');
    if (!mounted) return;
    setState(() => _currentHour = 1);
    final notifications = context.read<NotificationProvider>();
    if (notifications.hourlyReminder) {
      await notifications.scheduleHourlyPrayer();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sw
              ? 'Novena imeanza tena saa ya kwanza.'
              : 'The novena has restarted at hour one.',
        ),
      ),
    );
  }

  Future<void> _chooseHour() async {
    final sw = context.read<LanguageProvider>().isSwahili;
    final selectedHour = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sw ? 'Chagua saa ya kusali' : 'Choose an hour to pray',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: List.generate(15, (index) {
                  final hour = index + 1;
                  return ActionChip(
                    label: Text('${sw ? 'Saa' : 'Hour'} $hour'),
                    onPressed: () => Navigator.pop(sheetContext, hour),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
    if (selectedHour != null && mounted) {
      await _openMasaaPage(redo: true, selectedHour: selectedHour);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<LanguageProvider>().isSwahili;
    final nextHour = _currentHour < 15 ? _currentHour + 1 : 1;
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
                              ? 'Umemaliza sala ya saa $_currentHour'
                              : 'Hour $_currentHour complete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 23,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: _textColor.value,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          sw
                              ? 'Hongera kwa kudumu katika novena ya Mt. Rita. Utakumbushwa tena saa $nextHour, dakika 5 kabla.'
                              : 'Thank you for persevering in your St Rita novena. You’ll be reminded five minutes before hour $nextHour.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            color: ink.withValues(alpha: .72),
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
          if (widget.showAdOnStart && _isInterstitialAdReady) {
            _interstitialAd!.show();
          }
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load interstitial ad: $err');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
}
