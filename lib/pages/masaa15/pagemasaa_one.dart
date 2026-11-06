//import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:saint_rita/pages/masaa15/completion_lisaa_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/services/prayer_sound_service.dart';
import '../../models/ad_helper.dart';
import '../../models/masaa_prayer_data.dart';
import '../../provider/prayer_favorites_provider.dart';

class PageMasaaOne extends StatefulWidget {
  final Novena masaa;

  const PageMasaaOne({super.key, required this.masaa});

  @override
  State<PageMasaaOne> createState() => _PageMasaaOneState();
}

class _PageMasaaOneState extends State<PageMasaaOne> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  double _fontValue = 16;
  bool _showFinishButton = false;
  // ignore: unused_field
  final bool _showAudioInstructions = false;
  // ignore: unused_field
  double _sliderValue = 0.0;
  // ignore: unused_field
  Duration _currentPosition = Duration.zero;
  // ignore: unused_field
  final Duration _totalDuration = const Duration(minutes: 3, seconds: 45);
  int _currentPage = 0;
  BannerAd? _bannerAd;
  //bool _hasInternet = false;

  late List<String> _pages;
  bool? _pagesAreSwahili;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_updatePage);
    _scrollController.addListener(_checkScrollPosition);
    _loadBannerAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sw = context.watch<LanguageProvider>().isSwahili;
    if (_pagesAreSwahili != sw) {
      _pagesAreSwahili = sw;
      _pages = _buildPages(widget.masaa, sw);
    }
  }

  // Future<void> _checkInternetAndLoadAd() async {
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     setState(() {
  //       _hasInternet = true;
  //     });
  //     _loadBannerAd();
  //   } else {
  //     setState(() {
  //       _hasInternet = false;
  //     });
  //   }
  // }

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
    if (newIndex != _currentPage) {
      setState(() {
        _currentPage = newIndex;
        _scrollController.jumpTo(0);
        _showFinishButton = false;
      });
    }
  }

  void _checkScrollPosition() {
    if (_currentPage == _pages.length - 1) {
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

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _adjustFontSize(bool increase) {
    setState(() {
      if (increase && _fontValue < 30) {
        _fontValue += 2;
      } else if (!increase && _fontValue > 10)
        // ignore: curly_braces_in_flow_control_structures
        _fontValue -= 2;
    });
  }

  List<String> _buildPages(Novena n, bool sw) {
    return [
      // ===== PAGE 1 =====
      """
🕐 Saa: ${n.hour}
Kichwa: ${n.title}

MAELEZO MAALUM:
${n.specialNote}

${sw ? 'Kufungua' : 'Opening'}:
${n.opening}

${sw ? 'Maombi ya Mwanzo' : 'Invocation'}:
${n.invocation}

${sw ? 'Sala Kuu' : 'Main Prayer'}:
${n.mainPrayer.join("\n\n")}

${sw ? 'Maelekezo ya Shida Yako' : 'Personal Intention'}:
${n.personalIntentionInstruction}

${sw ? 'Sifa' : 'Praises'}:
${n.praises.join(", ")}
""",
      // ===== PAGE 2 =====
      """
${sw ? 'Litania' : 'Litany'}:

${sw ? 'Mwitikio wa mwanzo' : 'Opening acclamations'}: ${n.litania.introAcclamation.join("\n")}
${sw ? 'Kiitikio' : 'Response'}: "${n.litania.response}"

${sw ? 'Maombi ya maombezi' : 'Intercessions'}:
${n.litania.invocations.join("\n")}
${sw ? 'Kiitikio' : 'Response'}: "${n.litania.responseUtuombee}"

${sw ? 'Sifa za Bikira Maria' : 'Titles of the Blessed Virgin Mary'}:
${n.litania.maryTitles.join("\n")}

${sw ? 'Sifa za Mt Rita' : 'Titles of St Rita'}:
${n.litania.mtRitaTitles.join("\n")}

${sw ? 'Mwanakondoo wa Mungu' : 'Lamb of God'}:
${n.lambOfGod.join("\n")}

${sw ? 'Majibu ya Kiongozi' : 'Leader and People'}:
${sw ? 'Kiongozi' : 'Leader'}: ${n.leaderResponse.kiongozi}
${sw ? 'Wote' : 'All'}: ${n.leaderResponse.wote}

${sw ? 'Sala ya Mwisho' : 'Closing Prayer'}:
${n.closingPrayer}

${sw ? 'Kumbuka' : 'Note'}:
${n.extraNote}
""",
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<LanguageProvider>().isSwahili;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${sw ? 'Saa' : 'Hour'} ${widget.masaa.hour} - ${widget.masaa.title}",
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: sw ? 'Hifadhi sala' : 'Save prayer',
            onPressed: () => context.read<PrayerFavoritesProvider>().toggle(
              SavedPrayer(
                id: 'masaa-hour-${widget.masaa.hour}',
                title: widget.masaa.title,
                subtitle: '${sw ? 'Saa' : 'Hour'} ${widget.masaa.hour}',
                content: _pages.join('\n\n'),
                journey: 'Novena ya masaa kumi na tano',
              ),
            ),
            icon: Icon(
              context.watch<PrayerFavoritesProvider>().contains(
                    'masaa-hour-${widget.masaa.hour}',
                  )
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
            ),
          ),
          IconButton(
            tooltip: sw ? 'Shiriki sala' : 'Share prayer',
            onPressed: () =>
                Share.share('${widget.masaa.title}\n\n${_pages.join('\n\n')}'),
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
                    '${sw ? 'SALA' : 'PRAYER'} ${_currentPage + 1} / ${_pages.length}',
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
                  count: _pages.length,
                  effect: const WormEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    spacing: 5,
                    dotColor: Color(0x55415B70),
                    activeDotColor: GlassDesignSystem.emerald,
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
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPrayerPage(_pages[index]);
                  },
                ),
                if (_showFinishButton)
                  Positioned(
                    right: 16,
                    bottom: 90,
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        await PrayerSoundService.instance.playPrayerCompleted();
                        final navigator = Navigator.of(context);
                        navigator.pop(true);
                        navigator.push(
                          MaterialPageRoute(
                            builder: (_) => CompletionLisaaPage(
                              completedHour: widget.masaa.hour,
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "Maliza",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: GlassDesignSystem.emerald,
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
          // _buildAudioControls(),
        ],
      ),
    );
  }

  Widget _buildPrayerPage(String content) {
    final lines = content.split("\n");
    bool afterWote = false; // kufuatilia kama tuko baada ya Wote

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            final text = line.trim();
            if (text.isEmpty) return const SizedBox(height: 6);

            //  Kiongozi
            if (text.startsWith("Kiongozi:")) {
              final parts = text.split(":");
              final label = parts[0];
              final rest = parts.length > 1 ? parts.sublist(1).join(":") : "";

              afterWote = false; // reset

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$label:",
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      TextSpan(
                        text: rest,
                        style: TextStyle(
                          fontSize: _fontValue,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            //  Wote
            if (text.startsWith("Wote:")) {
              final parts = text.split(":");
              final label = parts[0];
              final rest = parts.length > 1 ? parts.sublist(1).join(":") : "";

              afterWote = true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$label:",
                        style: TextStyle(
                          fontSize: _fontValue,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      TextSpan(
                        text: rest,
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

            //  Kumbuka
            if (text.startsWith("Kumbuka:")) {
              final parts = text.split(":");
              final label = parts[0];
              final rest = parts.length > 1 ? parts.sublist(1).join(":") : "";

              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$label:",
                        style: TextStyle(
                          fontSize: _fontValue + 2,
                          fontWeight: FontWeight.bold,
                          color: GlassDesignSystem.emerald,
                        ),
                      ),
                      TextSpan(
                        text: rest,
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

            //  Mistari baada ya Wote → italic
            if (afterWote) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: _fontValue,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  textAlign: TextAlign.justify,
                ),
              );
            }

            //  Vichwa vyote vinavyoishia na ":" (isipokuwa Kiongozi/Wote/Kumbuka)
            if (text.endsWith(":")) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: _fontValue + 2,
                    fontWeight: FontWeight.bold,
                    color: GlassDesignSystem.emerald,
                  ),
                ),
              );
            }

            // Content ya kawaida
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
          }).toList(),
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
  //             // Play button (karibu na slider)
  //             Padding(
  //               padding: const EdgeInsets.only(right: 1), // nafasi ndogo tu
  //               child: IconButton(
  //                 onPressed: () {},
  //                 icon: const Icon(Icons.play_circle_fill),
  //                 color: Colors.blue,
  //                 iconSize: 32,
  //                 padding: EdgeInsets.zero,
  //                 constraints: const BoxConstraints(), // haina nafasi kubwa
  //               ),
  //             ),

  //             // Slider
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

  //             // Total duration
  //             Text(
  //               "${_totalDuration.inMinutes.toString().padLeft(2, '0')}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
  //               style: const TextStyle(fontSize: 12),
  //             ),

  //             const SizedBox(width: 4),

  //             // Expand/collapse button
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

  //         // Instructions
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
