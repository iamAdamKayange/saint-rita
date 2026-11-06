import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/provider/language_provider.dart';

class GlassHistoryScreen extends StatefulWidget {
  const GlassHistoryScreen({super.key});

  @override
  State<GlassHistoryScreen> createState() => _GlassHistoryScreenState();
}

class _GlassHistoryScreenState extends State<GlassHistoryScreen> {
  late Future<_PrayerHistory> _history;

  @override
  void initState() {
    super.initState();
    _history = _loadHistory();
  }

  Future<_PrayerHistory> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final events = <_PrayerEvent>[];
    final days = (prefs.getInt('novenaProgress') ?? 0).clamp(0, 9).toInt();
    final hours = (prefs.getInt('novenaHourProgress') ?? 0)
        .clamp(0, 15)
        .toInt();
    final completedNovenas = prefs.getInt('totalNovenasCompleted') ?? 0;
    final totalHours = prefs.getInt('totalHoursPrayed') ?? 0;

    for (final entry in (prefs.getString('prayerHistorySiku') ?? '').split(
      ';',
    )) {
      final parts = entry.split(':');
      if (parts.length < 2) continue;
      final date = DateTime.tryParse(parts.first);
      final count = int.tryParse(parts[1]) ?? 0;
      if (date != null && count > 0) {
        events.add(
          _PrayerEvent(
            date,
            '$count',
            '$count',
            Icons.calendar_month_rounded,
            1,
          ),
        );
      }
    }

    for (final entry in (prefs.getString('prayerHistoryMasaa') ?? '').split(
      ';',
    )) {
      final parts = entry.split(':');
      if (parts.length < 2) continue;
      final date = DateTime.tryParse(parts.first);
      final hour = int.tryParse(parts[1]) ?? 0;
      if (date != null && hour > 0) {
        events.add(
          _PrayerEvent(date, '$hour', '$hour', Icons.schedule_rounded, 2),
        );
      }
    }

    events.sort((a, b) => b.date.compareTo(a.date));
    return _PrayerHistory(days, hours, completedNovenas, totalHours, events);
  }

  Future<void> _refresh() async {
    final future = _loadHistory();
    setState(() => _history = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final sw = context.watch<LanguageProvider>().isSwahili;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _HistoryBackdrop(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 7, 20, 14),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Icon(Icons.arrow_back_rounded, color: text),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sw
                                  ? 'SAFARI YAKO YA SALA'
                                  : 'YOUR PRAYER JOURNEY',
                              style: TextStyle(
                                color: text.withValues(alpha: .5),
                                fontSize: 10,
                                letterSpacing: 1.7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              sw ? 'Historia' : 'Journal',
                              style: TextStyle(
                                color: text,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh history',
                        onPressed: _refresh,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: GlassDesignSystem.emerald,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<_PrayerHistory>(
                    future: _history,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final data = snapshot.data!;
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                          children: [
                            _OverviewCard(data: data, sw: sw),
                            const SizedBox(height: 22),
                            Text(
                              sw ? 'Sala za hivi karibuni' : 'Recent prayers',
                              style: TextStyle(
                                color: text,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 11),
                            if (data.events.isEmpty)
                              _EmptyHistory(text: text, sw: sw)
                            else
                              ...data.events
                                  .take(30)
                                  .map(
                                    (event) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: _HistoryEventTile(
                                        event: event,
                                        text: text,
                                        sw: sw,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
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

class _PrayerHistory {
  const _PrayerHistory(
    this.days,
    this.hours,
    this.completedNovenas,
    this.totalHours,
    this.events,
  );
  final int days;
  final int hours;
  final int completedNovenas;
  final int totalHours;
  final List<_PrayerEvent> events;
}

class _PrayerEvent {
  const _PrayerEvent(this.date, this.title, this.detail, this.icon, this.kind);
  final DateTime date;
  final String title;
  final String detail;
  final IconData icon;
  final int kind;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.data, required this.sw});
  final _PrayerHistory data;
  final bool sw;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(25),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GlassDesignSystem.divineBlue.withValues(alpha: .88),
              GlassDesignSystem.emerald.withValues(alpha: .85),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: .8)),
          boxShadow: [
            BoxShadow(
              color: GlassDesignSystem.divineBlue.withValues(alpha: .17),
              blurRadius: 23,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sw
                  ? 'Imani kidogo, siku baada ya siku'
                  : 'A little faith, day by day',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _OverviewStat(
                    value: '${data.days}/9',
                    label: sw ? 'Siku' : 'Days',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                Expanded(
                  child: _OverviewStat(
                    value: '${data.hours}/15',
                    label: sw ? 'Masaa' : 'Hours',
                    icon: Icons.schedule_rounded,
                  ),
                ),
                Expanded(
                  child: _OverviewStat(
                    value: '${data.completedNovenas}',
                    label: sw ? 'Novenas' : 'Novenas done',
                    icon: Icons.auto_stories_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: data.days / 9,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: .28),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${data.totalHours} ${sw ? 'jumla ya masaa ya sala' : 'total prayer hours recorded'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .84),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.white.withValues(alpha: .86), size: 18),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .78),
          fontSize: 9,
        ),
      ),
    ],
  );
}

class _HistoryEventTile extends StatelessWidget {
  const _HistoryEventTile({
    required this.event,
    required this.text,
    required this.sw,
  });
  final _PrayerEvent event;
  final Color text;
  final bool sw;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(19),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Colors.white.withValues(alpha: .8)),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: GlassDesignSystem.emerald.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                event.icon,
                color: GlassDesignSystem.emerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.kind == 1
                        ? (sw ? 'Novena ya siku 9' : '9-day novena')
                        : (sw ? 'Novena ya saa 15' : '15-hour novena'),
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.kind == 1
                        ? '${event.detail} ${sw ? (event.detail == '1' ? 'siku ya sala' : 'siku za sala') : (event.detail == '1' ? 'prayer day' : 'prayer days')}'
                        : '${sw ? 'Saa' : 'Hour'} ${event.detail} ${sw ? 'imekamilika' : 'completed'}',
                    style: TextStyle(
                      color: text.withValues(alpha: .6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${event.date.day}/${event.date.month}',
              style: TextStyle(
                color: text.withValues(alpha: .48),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.text, required this.sw});
  final Color text;
  final bool sw;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(23),
      border: Border.all(color: Colors.white),
    ),
    child: Column(
      children: [
        Icon(
          Icons.auto_stories_outlined,
          size: 35,
          color: GlassDesignSystem.emerald.withValues(alpha: .8),
        ),
        const SizedBox(height: 12),
        Text(
          sw
              ? 'Rekodi za sala zitaonekana hapa unapoendelea na novena.'
              : 'Your prayer records will gather here as you continue your novenas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: text.withValues(alpha: .65),
            height: 1.45,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

class _HistoryBackdrop extends StatelessWidget {
  const _HistoryBackdrop();
  @override
  Widget build(BuildContext context) => Positioned.fill(
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
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -65,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: GlassDesignSystem.emerald.withValues(alpha: .09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -150,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: GlassDesignSystem.divineBlue.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
