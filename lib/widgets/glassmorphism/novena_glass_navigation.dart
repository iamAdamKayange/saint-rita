import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

class NovenaGlassNavigation extends StatelessWidget {
  const NovenaGlassNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isSwahili,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isSwahili;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: (dark ? const Color(0xFF142B41) : Colors.white)
                    .withValues(alpha: .72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: .75)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16466A).withValues(alpha: .1),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_rounded),
                    label: isSwahili ? 'Nyumbani' : 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history_rounded),
                    label: isSwahili ? 'Historia' : 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.tune_rounded),
                    label: isSwahili ? 'Mpangilio' : 'Settings',
                  ),
                ],
                selectedItemColor: GlassDesignSystem.emerald,
                unselectedItemColor: dark ? Colors.white60 : GlassDesignSystem.subtleBrown.withValues(alpha: .63),
                selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
