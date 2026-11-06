import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/screens/glass_language_screen.dart';

/// Legacy callers now open the shared premium language experience.
class LanguageDialog {
  static Future<void> show(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const GlassLanguageScreen()),
    );
  }
}
