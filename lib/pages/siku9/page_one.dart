import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saint_rita/models/litania_data.dart';
import 'package:saint_rita/models/litania_data_en.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/services/prayer_sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/ad_helper.dart';
import '../../models/siku_prayer_data.dart';
import '../../provider/notification_provider.dart';
import '../../provider/prayer_favorites_provider.dart';
import 'completion_siku_page.dart';

class PageOne extends StatefulWidget {
  final Novena day;

  final bool redo;

  const PageOne({super.key, required this.day, this.redo = false});

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  final double _sliderValue = 0.3;
  int _currentIndexPage = 0;
  double _fontValue = 16;
  // ignore: unused_field
  final bool _showAudioInstructions = false;
  // ignore: unused_field
  final Duration _currentPosition = Duration.zero;
  // ignore: unused_field
  final Duration _totalDuration = const Duration(minutes: 3, seconds: 45);
  bool _showFinishButton = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
    _scrollController.addListener(_checkScrollPosition);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {
          _bannerAd = ad as BannerAd;
        }),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint("Ad failed to load: $error");
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  void _updatePage() {
    final newIndex = _pageController.page?.round() ?? 0;
    if (newIndex != _currentIndexPage) {
      setState(() {
        _currentIndexPage = newIndex;
        _scrollController.jumpTo(0);
        _showFinishButton = false;
      });
    }
  }

  void _checkScrollPosition() {
    if (_currentIndexPage == 2) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.8;

      if (currentScroll >= threshold && !_showFinishButton) {
        setState(() => _showFinishButton = true);
      } else if (currentScroll < threshold && _showFinishButton) {
        setState(() => _showFinishButton = false);
      }
    }
  }

  Future<void> updatePrayerHistorySiku() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Soma historia iliyopo
    String? history = prefs.getString('prayerHistorySiku');
    Map<String, int> historyMap = {};

    // Chambua historia iliyopo
    if (history != null && history.isNotEmpty) {
      List<String> entries = history.split(';');
      for (String entry in entries) {
        if (entry.contains(':')) {
          List<String> parts = entry.split(':');
          if (parts.length == 2) {
            historyMap[parts[0]] = int.tryParse(parts[1]) ?? 0;
          }
        }
      }
    }

    // Ongeza count ya leo
    historyMap[today] = (historyMap[today] ?? 0) + 1;

    // Badilisha tena kuwa string
    String newHistory = "";
    historyMap.forEach((key, value) {
      if (newHistory.isNotEmpty) newHistory += ";";
      newHistory += "$key:$value";
    });

    await prefs.setString('prayerHistorySiku', newHistory);
    await prefs.setInt('lastPrayerDate', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _adjustFontSize(bool increase) {
    setState(() {
      if (increase && _fontValue < 30) _fontValue += 2;
      if (!increase && _fontValue > 10) _fontValue -= 2;
    });
  }

  List<String> get pages {
    final sw = context.read<LanguageProvider>().isSwahili;
    final n = widget.day;
    return [
      """${n.title}
${sw ? 'Kufungua' : 'Opening'}:
${n.opening}

${sw ? 'Maombi ya Mwanzo' : 'Invocation'}:
${n.invocation}

${sw ? 'Sala Kuu' : 'Main Prayer'}:
${n.mainPrayer.take(2).join("\n\n")}

${n.personalIntentionInstruction}""",
      """${sw ? 'Sala Kuu (mwendelezo)' : 'Main Prayer (continued)'}:
${n.mainPrayer.skip(2).join("\n\n")}

${sw ? 'Sifa' : 'Praises'}:
${n.praises.join("\n")}

${sw ? 'Marudio' : 'Repetitions'}:
- ${sw ? 'Baba Yetu' : 'Our Father'} × ${n.repetitions.babaYetu}
- ${sw ? 'Salamu Maria' : 'Hail Mary'} × ${n.repetitions.salamuMaria}
- ${sw ? 'Atukuzwe Baba' : 'Glory Be'} × ${n.repetitions.atukuzweBaba}""",
      """${sw ? 'Miujiza' : 'Miracles'}:
${n.miraclesList.join("\n")}

${sw ? 'Tamko la Sifa' : 'Acclamations'}:
${n.acclamations.join("\n")}

${sw ? 'Sifa za Mungu' : 'Doxology'}:
${n.doxology}

${sw ? 'Majibu ya Kiongozi' : 'Leader and People'}:
${sw ? 'Kiongozi' : 'Leader'}: ${n.leaderResponse.kiongozi}
${sw ? 'Wote' : 'All'}: ${n.leaderResponse.wote}

${sw ? 'Sala ya Mwisho' : 'Closing Prayer'}:
${n.closingPrayer}

${sw ? 'Kumbuka' : 'Note'}:
${n.extraNote}""",
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<LanguageProvider>().isSwahili;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${sw ? 'Siku' : 'Day'} ${widget.day.day} - ${widget.day.title}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: sw ? 'Hifadhi sala' : 'Save prayer',
            onPressed: () => context.read<PrayerFavoritesProvider>().toggle(
              SavedPrayer(
                id: 'siku-day-${widget.day.day}',
                title: widget.day.title,
                subtitle: '${sw ? 'Siku' : 'Day'} ${widget.day.day}',
                content: pages.join('\n\n'),
                journey: 'Novena ya siku tisa',
              ),
            ),
            icon: Icon(
              context.watch<PrayerFavoritesProvider>().contains(
                    'siku-day-${widget.day.day}',
                  )
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
            ),
          ),
          IconButton(
            tooltip: sw ? 'Shiriki sala' : 'Share prayer',
            onPressed: () =>
                Share.share('${widget.day.title}\n\n${pages.join('\n\n')}'),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          PopupMenuButton<int>(
            tooltip: sw ? 'Ukubwa wa maandishi' : 'Reading text size',
            icon: const Icon(Icons.text_fields_rounded),
            onSelected: (delta) => _adjustFontSize(delta > 0),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: -1,
                child: Text(sw ? 'Punguza maandishi' : 'Smaller text'),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(sw ? 'Ongeza maandishi' : 'Larger text'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // SmoothPageIndicator ya maombi + litania
          GlassCard(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            customOpacity: .38,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: GlassDesignSystem.emerald,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${sw ? 'SALA' : 'PRAYER'} ${_currentIndexPage + 1} / ${pages.length + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w700,
                      color: GlassDesignSystem.emerald,
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length + 1,
                  effect: const WormEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    spacing: 5,
                    activeDotColor: GlassDesignSystem.emerald,
                    dotColor: Color(0x55415B70),
                  ),
                  onDotClicked: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length + 1,
                  itemBuilder: (context, index) {
                    if (index < pages.length) {
                      return _buildPrayerPage(context, pages[index], index);
                    } else {
                      return _buildLitaniaPage(litaniaJson, sw);
                    }
                  },
                ),
                if (_showFinishButton)
                  Positioned(
                    right: 16,
                    bottom: 90,
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        await PrayerSoundService.instance.playPrayerCompleted();
                        final prefs = await SharedPreferences.getInstance();

                        // ================= STEP 2: Increase counter ya siku =================
                        int dayCount =
                            prefs.getInt('day${widget.day.day}Count') ?? 0;
                        await prefs.setInt(
                          'day${widget.day.day}Count',
                          dayCount + 1,
                        );

                        // ================= STEP 3: Update prayer history ya siku =================
                        final today = DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.now());
                        String? history = prefs.getString('prayerHistorySiku');
                        if (history == null || history.isEmpty) {
                          history = "$today:1";
                        } else {
                          final List<String> items = history.split(';');
                          bool foundToday = false;
                          for (int i = 0; i < items.length; i++) {
                            if (items[i].startsWith(today)) {
                              final parts = items[i].split(':');
                              final count = int.parse(parts[1]) + 1;
                              items[i] = "$today:$count";
                              foundToday = true;
                              break;
                            }
                          }
                          if (!foundToday) {
                            items.add("$today:1");
                          }
                          history = items.join(';');
                        }
                        await prefs.setString('prayerHistorySiku', history);

                        // ================= STEP 4: Update last prayer date =================
                        final nowMillis = DateTime.now().millisecondsSinceEpoch;
                        await prefs.setInt('lastPrayerDate', nowMillis);

                        // ================= STEP 1: Update novenaProgress =================
                        // ================= STEP 1: Update novenaProgress =================
                        int nextDay;
                        if (widget.day.day < 9) {
                          nextDay = widget.day.day + 1;
                          await prefs.setInt("novenaProgress", nextDay);
                        } else {
                          nextDay = 9;
                          // Weka alama ya kukamilika kwa novena nzima
                          await prefs.setInt("novenaProgress", 9);
                          await prefs.setBool("novenaCompleted", true);
                          await prefs.setString(
                            "lastCompletedDate",
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          );

                          // Ongeza idadi ya novena zilizokamilika
                          int totalNovenas =
                              prefs.getInt('totalNovenasCompleted') ?? 0;
                          await prefs.setInt(
                            'totalNovenasCompleted',
                            totalNovenas + 1,
                          );
                        }

                        // ================= SHOW SnackBar =================
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Umeikamilisha Siku ya ${widget.day.day}. "
                              "${widget.day.day < 9 ? "Kesho utakumbushwa kusali Siku ya $nextDay" : "Unaweza kurudia siku hii tena"}",
                            ),
                          ),
                        );

                        // ================= Schedule daily reminder =================
                        final notificationProvider =
                            Provider.of<NotificationProvider>(
                              context,
                              listen: false,
                            );
                        if (notificationProvider.dailyReminder) {
                          await notificationProvider.scheduleDailyPrayer();
                        }

                        // ================= Close current page =================
                        Navigator.pop(context, true);

                        // ================= Navigate to Completion Page =================
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompletionSikuPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "Maliza",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: GlassDesignSystem.emerald,
                      elevation: 6,
                    ),
                  ),
              ],
            ),
          ),
          if (_bannerAd != null)
            Container(
              color: Colors.transparent,
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          //_buildAudioControls(),
        ],
      ),
    );
  }

  Widget _buildPrayerPage(BuildContext context, String content, int pageIndex) {
    List<String> lines = content.split("\n");
    bool afterWote = false;
    bool afterKumbuka = false;

    return SingleChildScrollView(
      controller: _scrollController,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) return const SizedBox(height: 6);

            // Titles (zinaishia na :)
            if (trimmed.endsWith(":")) {
              afterWote = false;
              afterKumbuka = trimmed.startsWith("Kumbuka:");
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  trimmed,
                  style: TextStyle(
                    fontSize: _fontValue + 2,
                    fontWeight: FontWeight.bold,
                    color: GlassDesignSystem.emerald,
                  ),
                ),
              );
            }
            // Kiongozi: label bold, content normal
            if (trimmed.startsWith("Kiongozi:")) {
              afterWote = false;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Kiongozi: ",
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      TextSpan(
                        text: trimmed
                            .substring(9)
                            .trim(), // content baada ya "Kiongozi:"
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Wote: label bold, content italic
            if (trimmed.startsWith("Wote:")) {
              afterWote = true;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Wote: ",
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      TextSpan(
                        text: trimmed.substring(5),
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Lines baada ya Wote -> italics
            if (afterWote) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  trimmed,
                  style: TextStyle(
                    fontSize: _fontValue,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
              );
            }

            // Lines baada ya Kumbuka -> normal
            if (afterKumbuka) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  trimmed,
                  style: TextStyle(
                    fontSize: _fontValue,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
              );
            }

            // Default content
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                trimmed,
                style: TextStyle(
                  fontSize: _fontValue,
                  height: 1.6,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                textAlign: TextAlign.justify,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLitaniaPage(List<Map<String, String>> litania, bool sw) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.9 &&
            !_showFinishButton) {
          setState(() => _showFinishButton = true);
        } else if (scrollInfo.metrics.pixels <
                scrollInfo.metrics.maxScrollExtent * 0.9 &&
            _showFinishButton) {
          setState(() => _showFinishButton = false);
        }
        return false;
      },
      child: SingleChildScrollView(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(litania.length, (index) {
              final line = litania[index];
              final role = line['role']?.toLowerCase() ?? 'default';
              final text = sw ? line['text'] ?? '' : litaniaEnglish[index];

              // Kiitikio detection
              if (text.startsWith(sw ? 'Kiitikio:' : 'Response:')) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: _fontValue,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                );
              }

              switch (role) {
                case 'title':
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontValue + 4,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  );
                case 'kiongozi':
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontValue,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  );
                case 'wote':
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: _fontValue,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  );
                case 'tuombe':
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: _fontValue,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  );
                default:
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: _fontValue,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  );
              }
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Widget _buildAudioControls() {
  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.fromLTRB(10, 4, 10, 20),
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).colorScheme.tertiary,
  //       border: Border.all(color: Colors.yellow.shade700, width: 1),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Theme.of(context).shadowColor.withOpacity(
  //             Theme.of(context).brightness == Brightness.light ? 0.5 : 0.3,
  //           ),
  //           blurRadius: 5,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(right: 1),
  //               child: IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.play_circle_fill),
  //                 color: Colors.blue,
  //                 iconSize: 32,
  //                 padding: EdgeInsets.zero,
  //                 constraints: const BoxConstraints(),
  //               ),
  //             ),
  //             Expanded(
  //               child: Slider(
  //                 value: _sliderValue,
  //                 onChanged: (val) {
  //                   setState(() {
  //                     _sliderValue = val;
  //                     _currentPosition = Duration(
  //                       seconds: (_totalDuration.inSeconds * val).toInt(),
  //                     );
  //                   });
  //                 },
  //                 activeColor: Colors.blue,
  //                 inactiveColor: Colors.grey.shade400,
  //               ),
  //             ),
  //             Text(
  //               "${_totalDuration.inMinutes.toString().padLeft(2, '0')}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
  //               style: const TextStyle(fontSize: 12),
  //             ),
  //             const SizedBox(width: 4),
  //             IconButton(
  //               onPressed: () {
  //                 setState(() {
  //                   _showAudioInstructions = !_showAudioInstructions;
  //                 });
  //               },
  //               icon: Icon(
  //                 _showAudioInstructions
  //                     ? Icons.expand_less
  //                     : Icons.expand_more,
  //               ),
  //               color: Colors.blue,
  //               iconSize: 22,
  //               padding: EdgeInsets.zero,
  //               constraints: const BoxConstraints(),
  //             ),
  //           ],
  //         ),
  //         if (_showAudioInstructions)
  //           const Padding(
  //             padding: EdgeInsets.only(top: 8.0),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.hearing, size: 16),
  //                 SizedBox(width: 4),
  //                 Expanded(
  //                   child: Text(
  //                     "Maelekezo ya Kicheza Sauti: Bonyeza kitufe cha play kusikiliza sauti. "
  //                     "Unaweza kudhibiti sauti kwa kutumia slider hapo juu.",
  //                     style: TextStyle(
  //                       fontSize: 13,
  //                       fontStyle: FontStyle.italic,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }
}
