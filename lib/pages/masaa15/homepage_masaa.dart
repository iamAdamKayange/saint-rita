import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/models/masaa_prayer_data.dart';
import 'package:saint_rita/pages/masaa15/pagemasaa_one.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageMasaa extends StatefulWidget {
  const HomePageMasaa({super.key});

  @override
  State<HomePageMasaa> createState() => _HomePageMasaaState();
}

class _HomePageMasaaState extends State<HomePageMasaa> {
  static const _totalHours = 15;
  final PageController _heroController = PageController();
  final List<String> _heroImages = const [
    'images/ritabanner3.jpeg',
    'images/ritabanner4.jpeg',
    'images/ritabanner5.jpeg',
    'images/ritabanner6.jpg',
  ];

  int _currentHourProgress = 0;
  int _heroIndex = 0;
  Timer? _heroTimer;
  Future<List<Novena>>? _prayersFuture;
  bool? _prayersAreSwahili;

  @override
  void initState() {
    super.initState();
    _loadHourProgress();
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_heroController.hasClients || !mounted) return;
      _heroIndex = (_heroIndex + 1) % _heroImages.length;
      _heroController.animateToPage(
        _heroIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sw = context.watch<LanguageProvider>().isSwahili;
    if (_prayersFuture == null || _prayersAreSwahili != sw) {
      _prayersAreSwahili = sw;
      _prayersFuture = _loadPrayers();
    }
  }

  Future<List<Novena>> _loadPrayers() async {
    final sw = context.read<LanguageProvider>().isSwahili;
    final json = await DefaultAssetBundle.of(context).loadString(
      sw
          ? 'assets/data/prayer-masaa-15.json'
          : 'assets/data/prayer-masaa-15-en.json',
    );
    return novenaHourPrayerFromMap(json).novena;
  }

  Future<void> _loadHourProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _currentHourProgress = (prefs.getInt('novenaHourProgress') ?? 0)
          .clamp(0, _totalHours)
          .toInt(),
    );
  }

  Future<void> _recordCompletedHour() async {
    final next = _currentHourProgress >= _totalHours
        ? 0
        : _currentHourProgress + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('novenaHourProgress', next);
    if (mounted) setState(() => _currentHourProgress = next);
    final reminders = context.read<NotificationProvider>();
    if (reminders.hourlyReminder) await reminders.scheduleHourlyPrayer();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.watch<LanguageProvider>().isSwahili;
    final progress = _currentHourProgress / _totalHours;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHero(sw),
              const SizedBox(height: 22),
              _SectionHeading(
                eyebrow: sw ? 'SAFARI YAKO' : 'YOUR DEVOTION',
                title: sw ? 'Maendeleo ya novena' : 'Your prayer journey',
                trailing:
                    '${_currentHourProgress.clamp(0, _totalHours)} / $_totalHours',
              ),
              const SizedBox(height: 12),
              _buildProgressCard(sw, progress),
              const SizedBox(height: 24),
              _SectionHeading(
                eyebrow: sw
                    ? 'ENDELEA ULIPOISHIA'
                    : 'PICK UP WHERE YOU LEFT OFF',
                title: sw ? 'Sala ya saa inayofuata' : 'Next hour of prayer',
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Novena>>(
                future: _prayersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _PrayerLoadingCard();
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return _PrayerMessageCard(
                      message: sw
                          ? 'Sala haikuweza kupakiwa. Jaribu tena baadae.'
                          : 'The prayer could not be loaded. Please try again.',
                    );
                  }

                  final prayers = snapshot.data!;
                  final index = _currentHourProgress
                      .clamp(0, prayers.length - 1)
                      .toInt();
                  final prayer = prayers[index];
                  final completed = _currentHourProgress >= _totalHours;
                  return _buildTodayCard(prayer, sw, completed);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(bool sw) {
    return SizedBox(
      height: 224,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: PageView.builder(
              controller: _heroController,
              itemCount: _heroImages.length,
              onPageChanged: (index) => _heroIndex = index,
              itemBuilder: (context, index) => Image.asset(
                _heroImages[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF245475),
                  child: Icon(
                    Icons.church_rounded,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF102C48).withValues(alpha: .12),
                  const Color(0xFF102C48).withValues(alpha: .88),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: .45)),
              boxShadow: GlassShadows.glassShadowMedium,
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 20,
            child: Row(
              children: [
                _HeroPill(label: sw ? 'SALA YA KILA SAA' : 'HOURLY DEVOTION'),
                const Spacer(),
                Icon(
                  Icons.auto_awesome_rounded,
                  color: GlassDesignSystem.emeraldLight.withValues(alpha: .95),
                  size: 21,
                ),
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sw
                      ? 'Saa 15 pamoja na\nMtakatifu Rita'
                      : '15 hours with\nSt. Rita',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.08,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    SmoothPageIndicator(
                      controller: _heroController,
                      count: _heroImages.length,
                      effect: const WormEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        spacing: 5,
                        activeDotColor: GlassDesignSystem.emeraldLight,
                        dotColor: Colors.white54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      sw
                          ? 'Safari ya imani, hatua kwa hatua'
                          : 'A prayer at a time',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool sw, double progress) {
    final percent = (progress * 100).round();
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      customOpacity: .42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GlassDesignSystem.emerald.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: GlassDesignSystem.emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sw ? 'Safari ya saa 15' : '15 hour journey',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sw
                          ? 'Umefika $_currentHourProgress kati ya 15'
                          : '$_currentHourProgress of 15 hours complete',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: GlassDesignSystem.emerald,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: GlassDesignSystem.divineBlue.withValues(
                alpha: .13,
              ),
              valueColor: const AlwaysStoppedAnimation(
                GlassDesignSystem.emerald,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: List.generate(_totalHours, (index) {
              final hour = index + 1;
              final done = hour <= _currentHourProgress;
              final current =
                  hour == _currentHourProgress + 1 &&
                  _currentHourProgress < _totalHours;
              return Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? GlassDesignSystem.emerald.withValues(alpha: .92)
                      : current
                      ? GlassDesignSystem.divineBlue.withValues(alpha: .8)
                      : Colors.white.withValues(alpha: .4),
                  border: Border.all(
                    color: current
                        ? Colors.white.withValues(alpha: .9)
                        : GlassDesignSystem.divineBlue.withValues(alpha: .12),
                  ),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        '$hour',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: current
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: .58),
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(Novena prayer, bool sw, bool completed) {
    final hour = prayer.hour;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      customOpacity: .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: GlassDesignSystem.emerald,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                sw ? 'SALA INAYOFUATA' : 'UP NEXT',
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.05,
                  color: GlassDesignSystem.emerald,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _HeroPill(label: '${sw ? 'SAA' : 'HOUR'} $hour'),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            prayer.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          if (prayer.opening.trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              prayer.opening.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
          const SizedBox(height: 19),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final completedPrayer = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (_) => PageMasaaOne(masaa: prayer),
                  ),
                );
                if (completedPrayer == true) await _recordCompletedHour();
              },
              icon: Icon(
                completed
                    ? Icons.replay_rounded
                    : Icons.self_improvement_rounded,
              ),
              label: Text(
                completed
                    ? (sw ? 'Sali tena' : 'Pray again')
                    : (sw ? 'Endelea na sala' : 'Continue prayer'),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: GlassDesignSystem.emerald,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: GlassDesignSystem.emerald,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: GlassDesignSystem.emerald),
        ),
    ],
  );
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .17),
      border: Border.all(color: Colors.white.withValues(alpha: .3)),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        letterSpacing: .8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _PrayerLoadingCard extends StatelessWidget {
  const _PrayerLoadingCard();

  @override
  Widget build(BuildContext context) => const GlassCard(
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

class _PrayerMessageCard extends StatelessWidget {
  const _PrayerMessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => GlassCard(
    child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
  );
}
