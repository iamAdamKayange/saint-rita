import 'dart:ui';

import 'package:flutter/material.dart';

class GlassAppBackdrop extends StatelessWidget {
  const GlassAppBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF0A1D30), Color(0xFF112E47), Color(0xFF0B2033)]
                : const [Color(0xFFE7F4FB), Color(0xFFF5FAFD), Color(0xFFDDEFF7)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -115,
              right: -70,
              child: _Glow(size: 290, color: const Color(0xFF55CBD4).withValues(alpha: dark ? .12 : .16)),
            ),
            Positioned(
              bottom: -165,
              left: -125,
              child: _Glow(size: 350, color: const Color(0xFF4A96C5).withValues(alpha: dark ? .13 : .11)),
            ),
            Positioned(
              top: 245,
              left: -115,
              child: _Glow(size: 210, color: const Color(0xFFB8EAF0).withValues(alpha: dark ? .06 : .18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
}
