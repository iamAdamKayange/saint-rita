import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

class GlassPrayerGuideScreen extends StatelessWidget {
  const GlassPrayerGuideScreen({
    super.key,
    required this.isSwahili,
    required this.isHourly,
  });
  final bool isSwahili;
  final bool isHourly;

  @override
  Widget build(BuildContext context) {
    final sw = isSwahili;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final steps = sw
        ? <(String, String)>[
            (
              'Tulia mbele za Mungu',
              'Tafuta sehemu tulivu, tuliza mawazo na uanze kwa ishara ya msalaba.',
            ),
            (
              'Weka nia yako',
              'Mkabidhi Mungu ombi lako kwa unyenyekevu na uombe mapenzi yake yatimizwe.',
            ),
            (
              'Sali sala ya siku au saa',
              'Fuata mpangilio wa sala unaoonyeshwa na usome polepole kwa tafakari.',
            ),
            (
              'Omba maombezi ya Mt. Rita',
              'Taja hitaji lako moyoni, kisha endelea na sifa, litania na majibu.',
            ),
            (
              isHourly ? 'Dumu kwa saa zote 15' : 'Dumu kwa siku zote 9',
              isHourly
                  ? 'Rudia sala ya saa husika kwa kila saa ya novena.'
                  : 'Rudia sala ya siku husika kila siku bila kuharakisha safari yako ya imani.',
            ),
            (
              'Hitimisha kwa shukrani',
              'Malizia sala na umshukuru Mungu kwa kusikiliza ombi lako.',
            ),
          ]
        : <(String, String)>[
            (
              'Become still before God',
              'Choose a quiet place, settle your thoughts, and begin with the Sign of the Cross.',
            ),
            (
              'Offer your intention',
              'Entrust your petition to God with humility and ask that His will be done.',
            ),
            (
              'Pray the day or hour',
              'Follow the order shown in the prayer and read slowly with reflection.',
            ),
            (
              'Ask for St Rita’s intercession',
              'Hold your intention in your heart, then continue with the praises, litany, and responses.',
            ),
            (
              isHourly
                  ? 'Remain faithful for all 15 hours'
                  : 'Remain faithful for all 9 days',
              isHourly
                  ? 'Repeat the assigned prayer at each hour of the novena.'
                  : 'Return to the prayer for the appropriate day and take this journey one day at a time.',
            ),
            (
              'Close with gratitude',
              'Finish the prayer and thank God for hearing your petition.',
            ),
          ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [Color(0xFF102940), Color(0xFF0B1D30)]
                      : const [Color(0xFFEAF6FC), Color(0xFFF5FAFD)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          _GuidePill(
                            text: isHourly
                                ? (sw ? 'SAA 15' : '15 HOURS')
                                : (sw ? 'SIKU 9' : '9 DAYS'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.self_improvement_rounded,
                              color: GlassDesignSystem.emerald,
                              size: 38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              sw ? 'MWONGOZO WA SALA' : 'A GUIDE TO PRAYER',
                              style: const TextStyle(
                                color: GlassDesignSystem.emerald,
                                letterSpacing: 1.2,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sw
                                  ? 'Sali kwa utulivu\nna kwa moyo'
                                  : 'Pray with stillness\nand an open heart',
                              style: TextStyle(
                                color: ink,
                                fontSize: 29,
                                height: 1.13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isHourly
                                  ? (sw
                                        ? 'Novena ya saa 15'
                                        : 'The 15-hour devotion')
                                  : (sw
                                        ? 'Novena ya siku 9'
                                        : 'The 9-day devotion'),
                              style: TextStyle(
                                color: ink.withValues(alpha: .65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 23),
                      Text(
                        sw ? 'HATUA ZA SALA' : 'PRAYER RHYTHM',
                        style: const TextStyle(
                          color: GlassDesignSystem.emerald,
                          letterSpacing: 1.2,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < steps.length; i++) ...[
                        _GuideStep(
                          number: i + 1,
                          title: steps[i].$1,
                          body: steps[i].$2,
                          ink: ink,
                        ),
                        if (i != steps.length - 1) const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 14),
                      _GlassPanel(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.spa_rounded,
                              color: GlassDesignSystem.softGold,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                sw
                                    ? 'Novena ni safari ya imani na uvumilivu. Sala hutusaidia kumkaribia Mungu kwa tumaini.'
                                    : 'A novena is a journey of faith and perseverance. Prayer helps us draw closer to God in hope.',
                                style: TextStyle(
                                  color: ink.withValues(alpha: .72),
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.favorite_rounded),
                        label: Text(
                          sw ? 'Niko tayari kusali' : 'I’m ready to pray',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: GlassDesignSystem.emerald,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
    required this.ink,
  });
  final int number;
  final String title;
  final String body;
  final Color ink;
  @override
  Widget build(BuildContext context) => _GlassPanel(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 33,
          height: 33,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GlassDesignSystem.emerald.withValues(alpha: .14),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: GlassDesignSystem.emerald,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                body,
                style: TextStyle(
                  color: ink.withValues(alpha: .68),
                  height: 1.45,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? .09 : .58,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .7)),
          boxShadow: [
            BoxShadow(
              color: GlassDesignSystem.divineBlue.withValues(alpha: .08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class _GuidePill extends StatelessWidget {
  const _GuidePill({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: GlassDesignSystem.emerald.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: GlassDesignSystem.emerald.withValues(alpha: .2),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: GlassDesignSystem.emerald,
        fontWeight: FontWeight.w800,
        fontSize: 10,
        letterSpacing: .8,
      ),
    ),
  );
}
