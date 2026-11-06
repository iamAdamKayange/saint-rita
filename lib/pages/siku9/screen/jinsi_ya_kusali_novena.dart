import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/screens/glass_prayer_guide_screen.dart';
import 'package:saint_rita/provider/language_provider.dart';

class JinsiYaKusaliSikuPage extends StatelessWidget {
  const JinsiYaKusaliSikuPage({super.key});
  @override
  Widget build(BuildContext context) => GlassPrayerGuideScreen(
    isSwahili: context.watch<LanguageProvider>().isSwahili,
    isHourly: false,
  );
}
