import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/screens/glass_sanctuary_screen.dart';
import 'package:saint_rita/pages/masaa15/novena_one.dart';
import 'package:saint_rita/pages/siku9/novena_two.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/services/admob_service.dart';

/// Premium choice screen shown when a novena journey is completed.
class BridgeScreen extends StatelessWidget {
  const BridgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final swahili = context.watch<LanguageProvider>().isSwahili;
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: GlassGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: GlassShadows.glassShadowMedium,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    swahili ? 'Endelea na safari ya sala' : 'Continue your prayer journey',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    swahili
                        ? 'Chagua novena nyingine au rudi kwenye patakatifu.'
                        : 'Choose another novena or return to your sanctuary.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  _JourneyCard(
                    icon: Icons.wb_sunny_outlined,
                    title: swahili ? 'Novena ya Saa 15' : '15 Hour Novena',
                    subtitle: swahili
                        ? 'Sala ya Mt. Rita inayosaliwa kwa saa 15.'
                        : 'The devotion to St. Rita prayed across 15 hours.',
                    onTap: () => _openNovena(context, const NovenaOne()),
                  ),
                  const SizedBox(height: 14),
                  _JourneyCard(
                    icon: Icons.calendar_month_rounded,
                    title: swahili ? 'Novena ya Siku 9' : '9 Day Novena',
                    subtitle: swahili
                        ? 'Endelea na sala ya kila siku kwa siku tisa.'
                        : 'Build a daily prayer rhythm over nine days.',
                    onTap: () => _openNovena(context, const NovenaTwo()),
                  ),
                  const SizedBox(height: 22),
                  GlassButton(
                    text: swahili ? 'Rudi patakatifu' : 'Return to sanctuary',
                    icon: const Icon(Icons.home_rounded),
                    isOutlined: true,
                    isFullWidth: true,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const GlassSanctuaryScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openNovena(BuildContext context, Widget screen) {
    AdMobService().showInterstitialAd();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: GlassDesignSystem.emerald.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: GlassDesignSystem.emerald, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 5),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colors.primary),
        ],
      ),
    );
  }
}
