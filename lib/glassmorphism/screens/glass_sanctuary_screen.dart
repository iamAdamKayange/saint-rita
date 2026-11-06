import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/screens/glass_favorites_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_history_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_notification_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_settings_screen.dart';
import 'package:saint_rita/pages/masaa15/novena_one.dart';
import 'package:saint_rita/pages/siku9/novena_two.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/services/admob_service.dart';
import 'package:saint_rita/widgets/animated_nun_3d.dart';

class GlassSanctuaryScreen extends StatefulWidget {
  const GlassSanctuaryScreen({super.key});

  @override
  State<GlassSanctuaryScreen> createState() => _GlassSanctuaryScreenState();
}

class _GlassSanctuaryScreenState extends State<GlassSanctuaryScreen> {
  int _selectedIndex = 0;
  int _daysComplete = 0;
  int _hoursComplete = 0;
  bool _loadingProgress = true;

  bool get _sw => context.watch<LanguageProvider>().isSwahili;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _daysComplete = (prefs.getInt('novenaProgress') ?? 0).clamp(0, 9).toInt();
      _hoursComplete = (prefs.getInt('novenaHourProgress') ?? 0).clamp(0, 15).toInt();
      _loadingProgress = false;
    });
  }

  Future<void> _openJourney({required bool daily}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => daily ? const NovenaTwo() : const NovenaOne(),
      ),
    );
    _loadProgress();
  }

  Future<void> _openRoute(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final foreground = dark ? Colors.white : GlassDesignSystem.deepForestGreen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _SanctuaryBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(foreground),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: GlassDesignSystem.durationNormal,
                    child: _selectedIndex == 1
                        ? _buildDevotions(theme, dark)
                        : _buildHome(theme, dark),
                  ),
                ),
                const AdBannerWidget(adSize: AdSize.banner),
                _buildNavigation(dark, foreground),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Color foreground) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 18, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GlassDesignSystem.emerald.withValues(alpha: .13),
              border: Border.all(color: Colors.white.withValues(alpha: .75)),
            ),
            child: Icon(Icons.spa_rounded, color: GlassDesignSystem.emerald),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RITA WA KASHIA',
                  style: TextStyle(
                    color: foreground.withValues(alpha: .58),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  _sw ? 'Safari ya sala' : 'A quiet place to pray',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _topAction(
            icon: Icons.settings_outlined,
            label: _sw ? 'Mipangilio' : 'Settings',
            onPressed: () => _openRoute(const GlassSettingsScreen()),
          ),
          const SizedBox(width: 7),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final unread = provider.notifications.where((n) => !n.isRead).length;
              return _topAction(
                icon: Icons.notifications_none_rounded,
                label: _sw ? 'Taarifa' : 'Notifications',
                badge: unread,
                onPressed: () => _openRoute(const GlassNotificationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _topAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    int badge = 0,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              if (badge > 0)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: GlassDesignSystem.emerald,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(ThemeData theme, bool dark) {
    final foreground = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    return ListView(
      key: const ValueKey('sanctuary-home'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          _sw ? 'Karibu, rafiki.' : 'Welcome, friend.',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _sw ? 'Tenga muda wa kuwa na Mt. Rita.' : 'Make a little room for prayer today.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: foreground.withValues(alpha: .65),
          ),
        ),
        const SizedBox(height: 19),
        _buildSaintCard(),
        const SizedBox(height: 18),
        _buildProgressCard(foreground),
        const SizedBox(height: 23),
        _sectionHeading(
          _sw ? 'Endelea na sala' : 'Continue your prayer',
          _sw ? 'Chagua safari yako' : 'Choose a devotional journey',
          foreground,
        ),
        const SizedBox(height: 12),
        _buildJourneyCard(
          title: _sw ? 'Novena ya siku tisa' : 'Nine day novena',
          subtitle: _daysComplete > 0
              ? (_sw ? 'Siku ${_daysComplete.clamp(1, 9)} • Endelea ulipoishia' : 'Day ${_daysComplete.clamp(1, 9)} • Pick up where you left off')
              : (_sw ? 'Sala ya kila siku pamoja na Mt. Rita' : 'A daily prayer journey with St. Rita'),
          progress: _daysComplete / 9,
          icon: Icons.calendar_month_rounded,
          image: 'images/ritabanner2.jpg',
          onTap: () => _openJourney(daily: true),
        ),
        const SizedBox(height: 11),
        _buildJourneyCard(
          title: _sw ? 'Novena ya masaa kumi na tano' : 'Fifteen hour novena',
          subtitle: _hoursComplete > 0
              ? (_sw ? 'Saa ${_hoursComplete.clamp(1, 15)} kati ya 15' : 'Hour ${_hoursComplete.clamp(1, 15)} of 15')
              : (_sw ? 'Muda wa tafakari na sala' : 'A focused day of prayer and reflection'),
          progress: _hoursComplete / 15,
          icon: Icons.schedule_rounded,
          image: 'images/ritabanner4.jpeg',
          onTap: () => _openJourney(daily: false),
        ),
        const SizedBox(height: 22),
        _buildShortcuts(foreground),
      ],
    );
  }

  Widget _buildSaintCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: SizedBox(
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('images/ritabanner3.jpeg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF092B4A).withValues(alpha: .87),
                    const Color(0xFF137D9A).withValues(alpha: .25),
                  ],
                ),
              ),
            ),
            const Positioned(
              right: 0,
              bottom: -6,
              child: AnimatedNun3D(height: 200),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(21, 21, 128, 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _sw ? 'MT. RITA WA KASHIA' : 'ST. RITA OF CASCIA',
                    style: const TextStyle(
                      color: Color(0xFFBDEDF3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _sw ? 'Matumaini katika yasiyowezekana' : 'Hope in the impossible',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _sw ? 'Anza kwa utulivu. Endelea kwa imani.' : 'Begin in stillness. Continue in faith.',
                    style: TextStyle(color: Colors.white.withValues(alpha: .86), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Color foreground) {
    final total = _daysComplete + _hoursComplete;
    return _FrostedPanel(
      padding: const EdgeInsets.all(17),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _sw ? 'Maendeleo yako' : 'Your prayer journey',
                  style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              if (_loadingProgress)
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text(
                  '$total ${_sw ? 'hatua' : 'steps'}',
                  style: TextStyle(color: foreground.withValues(alpha: .58), fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 15),
          _progressLine(_sw ? 'Siku 9' : '9 day novena', _daysComplete, 9, foreground),
          const SizedBox(height: 13),
          _progressLine(_sw ? 'Masaa 15' : '15 hour novena', _hoursComplete, 15, foreground),
        ],
      ),
    );
  }

  Widget _progressLine(String label, int value, int total, Color foreground) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: foreground.withValues(alpha: .72), fontSize: 12))),
            Text('$value / $total', style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : value / total,
            minHeight: 7,
            backgroundColor: foreground.withValues(alpha: .11),
            valueColor: const AlwaysStoppedAnimation(GlassDesignSystem.emerald),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    required String image,
    required VoidCallback onTap,
  }) {
    final foreground = Theme.of(context).colorScheme.primary;
    return _FrostedPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(11),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              width: 62,
              height: 66,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(image, fit: BoxFit.cover),
                  ColoredBox(color: const Color(0xFF0C5474).withValues(alpha: .4)),
                  Icon(icon, color: Colors.white, size: 27),
                ],
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: foreground.withValues(alpha: .62), fontSize: 11)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: foreground.withValues(alpha: .1),
                    valueColor: const AlwaysStoppedAnimation(GlassDesignSystem.emerald),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 15, color: foreground.withValues(alpha: .5)),
        ],
      ),
    );
  }

  Widget _buildShortcuts(Color foreground) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            icon: Icons.bookmark_outline_rounded,
            label: _sw ? 'Zilizohifadhiwa' : 'Saved prayers',
            onTap: () => _openRoute(const GlassFavoritesScreen()),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.history_rounded,
            label: _sw ? 'Historia' : 'Prayer history',
            onTap: () => _openRoute(const GlassHistoryScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildDevotions(ThemeData theme, bool dark) {
    final foreground = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    return ListView(
      key: const ValueKey('devotions'),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 25),
      children: [
        Text(_sw ? 'Safari za sala' : 'Prayer journeys', style: theme.textTheme.headlineSmall?.copyWith(color: foreground, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(_sw ? 'Chagua muda unaokufaa leo.' : 'Choose a rhythm that fits today.', style: TextStyle(color: foreground.withValues(alpha: .63))),
        const SizedBox(height: 20),
        _buildSaintCard(),
        const SizedBox(height: 18),
        _buildJourneyCard(
          title: _sw ? 'Novena ya siku tisa' : 'Nine day novena',
          subtitle: _sw ? 'Sala ya kila siku pamoja na Mt. Rita' : 'A daily prayer journey with St. Rita',
          progress: _daysComplete / 9,
          icon: Icons.calendar_month_rounded,
          image: 'images/ritabanner2.jpg',
          onTap: () => _openJourney(daily: true),
        ),
        const SizedBox(height: 12),
        _buildJourneyCard(
          title: _sw ? 'Novena ya masaa kumi na tano' : 'Fifteen hour novena',
          subtitle: _sw ? 'Muda wa tafakari na sala' : 'A focused day of prayer and reflection',
          progress: _hoursComplete / 15,
          icon: Icons.schedule_rounded,
          image: 'images/ritabanner4.jpeg',
          onTap: () => _openJourney(daily: false),
        ),
      ],
    );
  }

  Widget _sectionHeading(String title, String subtitle, Color foreground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: foreground, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(subtitle, style: TextStyle(color: foreground.withValues(alpha: .57), fontSize: 12)),
      ],
    );
  }

  Widget _buildNavigation(bool dark, Color foreground) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined),
      (Icons.auto_stories_rounded, Icons.auto_stories_outlined),
      (Icons.favorite_rounded, Icons.favorite_border_rounded),
      (Icons.history_rounded, Icons.history_outlined),
    ];
    final labels = _sw
        ? ['Nyumbani', 'Novena', 'Vipendwa', 'Historia']
        : ['Home', 'Pray', 'Saved', 'Journal'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: (dark ? const Color(0xFF142B41) : Colors.white).withValues(alpha: .7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: .72)),
              boxShadow: [BoxShadow(color: const Color(0xFF16466A).withValues(alpha: .1), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final selected = _selectedIndex == index;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: labels[index],
                    child: InkWell(
                      onTap: () {
                        if (index == 2) {
                          _openRoute(const GlassFavoritesScreen());
                        } else if (index == 3) {
                          _openRoute(const GlassHistoryScreen());
                        } else {
                          setState(() => _selectedIndex = index);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(selected ? items[index].$1 : items[index].$2, color: selected ? GlassDesignSystem.emerald : foreground.withValues(alpha: .48), size: 21),
                            const SizedBox(height: 4),
                            Text(labels[index], style: TextStyle(color: selected ? GlassDesignSystem.deepForestGreen : foreground.withValues(alpha: .53), fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedPanel extends StatelessWidget {
  const _FrostedPanel({required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding ?? const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: (dark ? const Color(0xFF17344D) : const Color(0xFFF7FCFF)).withValues(alpha: dark ? .72 : .68),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: dark ? .18 : .82)),
            boxShadow: [BoxShadow(color: const Color(0xFF16466A).withValues(alpha: .08), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return panel;
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: panel));
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return _FrostedPanel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Row(
        children: [
          Icon(icon, color: GlassDesignSystem.emerald, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11))),
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: .5), size: 18),
        ],
      ),
    );
  }
}

class _SanctuaryBackdrop extends StatelessWidget {
  const _SanctuaryBackdrop();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF102940), Color(0xFF0B1D30), Color(0xFF153A51)]
                : const [Color(0xFFEAF6FC), Color(0xFFDCEFF8), Color(0xFFF4FAFD)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -75, right: -45, child: _GlowOrb(size: 230, color: GlassDesignSystem.emerald.withValues(alpha: dark ? .12 : .13))),
            Positioned(bottom: 105, left: -105, child: _GlowOrb(size: 240, color: GlassDesignSystem.divineBlue.withValues(alpha: dark ? .13 : .1))),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
