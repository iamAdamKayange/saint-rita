import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/screens/glass_language_screen.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/provider/theme_provider.dart';

class GlassSettingsScreen extends StatelessWidget {
  const GlassSettingsScreen({super.key});

  bool _sw(BuildContext context) => context.watch<LanguageProvider>().isSwahili;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final text = isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen;
    final sw = _sw(context);
    final theme = context.watch<ThemeProvider>();
    final notifications = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const _SettingsBackdrop(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 7, 20, 18),
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
                                    ? 'UBINAFSISHA SAFARI YAKO'
                                    : 'MAKE IT YOURS',
                                style: TextStyle(
                                  color: text.withValues(alpha: .5),
                                  fontSize: 10,
                                  letterSpacing: 1.7,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                sw ? 'Mipangilio' : 'Settings',
                                style: TextStyle(
                                  color: text,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                  sliver: SliverList.list(
                    children: [
                      _sectionTitle(sw ? 'Mwonekano' : 'Appearance', text),
                      _SettingPanel(
                        children: [
                          _SettingRow(
                            icon: theme.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            title: sw ? 'Mandhari ya usiku' : 'Dark appearance',
                            subtitle: sw
                                ? 'Pumzisha macho kwenye mwanga hafifu'
                                : 'A softer palette for evening prayer',
                            trailing: Switch.adaptive(
                              value: theme.isDarkMode,
                              activeColor: GlassDesignSystem.emerald,
                              onChanged: (_) => theme.toggleTheme(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(
                        sw ? 'Kumbusho za sala' : 'Prayer reminders',
                        text,
                      ),
                      _SettingPanel(
                        children: [
                          _SettingRow(
                            icon: Icons.notifications_active_outlined,
                            title: sw
                                ? 'Kumbusho la jumla'
                                : 'Daily encouragement',
                            subtitle: sw
                                ? 'Taarifa za sala ya Mt. Rita'
                                : 'A gentle invitation to return to prayer',
                            trailing: Switch.adaptive(
                              value: notifications.generalReminder,
                              activeColor: GlassDesignSystem.emerald,
                              onChanged: (value) =>
                                  notifications.toggleReminder(
                                    NotificationType.general,
                                    value,
                                    context,
                                  ),
                            ),
                          ),
                          _SettingDivider(),
                          _SettingRow(
                            icon: Icons.wb_sunny_outlined,
                            title: sw ? 'Novena ya siku 9' : '9 day novena',
                            subtitle:
                                '${sw ? 'Arifa dakika 5 kabla ya' : 'Alert 5 minutes before'} ${notifications.dailyTime.format(context)}',
                            trailing: _ReminderControl(
                              enabled: notifications.dailyReminder,
                              label: sw ? 'Novena ya siku 9' : '9 day novena',
                              onToggle: (value) => notifications.toggleReminder(
                                NotificationType.daily,
                                value,
                                context,
                              ),
                              onTime: () => _selectTime(
                                context,
                                notifications.dailyTime,
                                notifications.setDailyTime,
                              ),
                            ),
                          ),
                          _SettingDivider(),
                          _SettingRow(
                            icon: Icons.schedule_rounded,
                            title: sw ? 'Novena ya masaa 15' : '15 hour novena',
                            subtitle:
                                '${sw ? 'Mfululizo huanza; arifa dakika 5 kabla ya' : 'Sequence starts; alert 5 minutes before'} ${notifications.hourlyTime.format(context)}',
                            trailing: _ReminderControl(
                              enabled: notifications.hourlyReminder,
                              label: sw
                                  ? 'Novena ya masaa 15'
                                  : '15 hour novena',
                              onToggle: (value) => notifications.toggleReminder(
                                NotificationType.hourly,
                                value,
                                context,
                              ),
                              onTime: () => _selectTime(
                                context,
                                notifications.hourlyTime,
                                notifications.setHourlyTime,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(
                        sw ? 'Lugha na taarifa' : 'Language & information',
                        text,
                      ),
                      _SettingPanel(
                        children: [
                          _SettingRow(
                            icon: Icons.language_rounded,
                            title: sw ? 'Lugha' : 'Language',
                            subtitle: sw ? 'Kiswahili' : 'English',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: text.withValues(alpha: .5),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const GlassLanguageScreen(),
                              ),
                            ),
                          ),
                          const _SettingDivider(),
                          _SettingRow(
                            icon: Icons.favorite_outline_rounded,
                            title: sw ? 'Kuhusu Mt. Rita' : 'About St. Rita',
                            subtitle: sw
                                ? 'Mtakatifu wa mambo yasiyowezekana'
                                : 'The saint of impossible causes',
                            trailing: Icon(
                              Icons.auto_awesome_outlined,
                              color: GlassDesignSystem.softGold,
                            ),
                            onTap: () => showAboutDialog(
                              context: context,
                              applicationName: 'Rita Wa Kashia',
                              applicationVersion: '1.0.1',
                              applicationIcon: const Icon(
                                Icons.spa_rounded,
                                color: GlassDesignSystem.emerald,
                              ),
                              children: [
                                Text(
                                  sw
                                      ? 'Sala na tafakari pamoja na Mt. Rita wa Kashia.'
                                      : 'Prayer and reflection with St. Rita of Cascia.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Text(
                          'RITA WA KASHIA  •  1.0.1',
                          style: TextStyle(
                            color: text.withValues(alpha: .43),
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
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

  Widget _sectionTitle(String title, Color color) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay initial,
    Future<void> Function(TimeOfDay) onSave,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) await onSave(selected);
  }
}

class _SettingPanel extends StatelessWidget {
  const _SettingPanel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(23),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        decoration: BoxDecoration(
          color:
              (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF17344D)
                      : Colors.white)
                  .withValues(alpha: .68),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: Colors.white.withValues(alpha: .78)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16466A).withValues(alpha: .07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : GlassDesignSystem.deepForestGreen;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GlassDesignSystem.emerald.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: GlassDesignSystem.emerald, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: text.withValues(alpha: .58),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 66),
    child: Divider(
      height: 1,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
    ),
  );
}

class _ReminderControl extends StatelessWidget {
  const _ReminderControl({
    required this.enabled,
    required this.label,
    required this.onToggle,
    required this.onTime,
  });

  final bool enabled;
  final String label;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Change $label reminder time',
        onPressed: onTime,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.schedule_rounded,
          size: 19,
          color: enabled
              ? GlassDesignSystem.emerald
              : GlassDesignSystem.emerald.withValues(alpha: .5),
        ),
      ),
      Switch.adaptive(
        value: enabled,
        activeColor: GlassDesignSystem.emerald,
        onChanged: onToggle,
      ),
    ],
  );
}

class _SettingsBackdrop extends StatelessWidget {
  const _SettingsBackdrop();
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
            bottom: -10,
            left: -145,
            child: Container(
              width: 260,
              height: 260,
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
