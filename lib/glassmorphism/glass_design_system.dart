import 'package:flutter/material.dart';

/// Premium Glassmorphism Design System for Catholic Prayer App
/// Catholic spirituality + modern glassmorphism + premium technology aesthetic
class GlassDesignSystem {
  // Spiritual Color Palette - Warm Catholic colors
  static const Color deepForestGreen = Color(0xFF123451); // Midnight blue
  static const Color emerald = Color(0xFF19AFC0); // Aqua accent
  static const Color emeraldLight = Color(0xFF62DCE2); // Light aqua
  static const Color softGold = Color(0xFFC89D56); // Quiet gold
  static const Color warmCream = Color(0xFFEAF4FA); // Ice blue
  static const Color subtleBrown = Color(0xFF415B70); // Slate blue
  static const Color cathedralStone = Color(0xFF758D9F); // Soft slate
  static const Color sacredPurple = Color(0xFF638CC5); // Periwinkle
  static const Color divineBlue = Color(0xFF3E9DCA); // Clear blue
  
  // Glass Colors
  static const Color whiteGlass = Color(0xFFFFFFFF); // White translucent
  static const Color darkGlass = Color(0xFF132A41); // Dark glass surface
  static const Color lightGlass = Color(0xFFF6FBFE); // Light glass surface
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF153E62); // Blue start
  static const Color gradientEnd = Color(0xFF38C5D2); // Aqua end
  static const Color goldAccent = Color(0xFFC89D56); // Gold accent
  
  // Glass Effect Design Tokens
  static const double glassBlurSmall = 10.0;
  static const double glassBlurMedium = 20.0;
  static const double glassBlurLarge = 30.0;
  
  static const double glassOpacityLight = 0.15;
  static const double glassOpacityMedium = 0.25;
  static const double glassOpacityHeavy = 0.35;
  
  static const double glassBorderOpacity = 0.15;
  static const double glassShadowOpacity = 0.1;
  
  // Spacing Scale - Premium breathing room
  static const double spaceXXS = 4.0;
  static const double spaceXS = 8.0;
  static const double spaceS = 12.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double spaceXXXL = 64.0;
  
  // Border Radius - Premium elegance
  static const double radiusXS = 8.0;
  static const double radiusS = 12.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusXXL = 36.0;
  static const double radiusFull = 999.0;
  
  // Typography - Strong hierarchy
  static const double fontSizeXXS = 11.0;
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;
  static const double fontSizeDisplay = 48.0;
  
  // Animation - Smooth glass transitions
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  static const Curve curveSmooth = Curves.easeOutCubic;
  static const Curve curveBounce = Curves.elasticOut;
  
  // Elevation - Depth hierarchy
  static const double elevationNone = 0.0;
  static const double elevationXS = 2.0;
  static const double elevationS = 4.0;
  static const double elevationM = 8.0;
  static const double elevationL = 16.0;
  static const double elevationXL = 24.0;
  
  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Glass Card Presets
  static const GlassCardPreset subtle = GlassCardPreset(
    blur: glassBlurSmall,
    opacity: glassOpacityLight,
    borderOpacity: glassBorderOpacity,
    elevation: elevationXS,
  );
  
  static const GlassCardPreset standard = GlassCardPreset(
    blur: glassBlurMedium,
    opacity: glassOpacityMedium,
    borderOpacity: glassBorderOpacity,
    elevation: elevationS,
  );
  
  static const GlassCardPreset prominent = GlassCardPreset(
    blur: glassBlurLarge,
    opacity: glassOpacityHeavy,
    borderOpacity: glassBorderOpacity,
    elevation: elevationM,
  );
}

class GlassCardPreset {
  final double blur;
  final double opacity;
  final double borderOpacity;
  final double elevation;
  
  const GlassCardPreset({
    required this.blur,
    required this.opacity,
    required this.borderOpacity,
    required this.elevation,
  });
}

/// Glass Gradients - Premium spiritual gradients
class GlassGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [GlassDesignSystem.deepForestGreen, GlassDesignSystem.divineBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sacredGradient = LinearGradient(
    colors: [GlassDesignSystem.deepForestGreen, GlassDesignSystem.divineBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [GlassDesignSystem.softGold, GlassDesignSystem.warmCream],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient forestGradient = LinearGradient(
    colors: [GlassDesignSystem.divineBlue, GlassDesignSystem.emerald],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient glassOverlay = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Glass Shadows - Premium depth shadows
class GlassShadows {
  static List<BoxShadow> get glassShadowSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(GlassDesignSystem.glassShadowOpacity),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get glassShadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(GlassDesignSystem.glassShadowOpacity),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get glassShadowLarge => [
    BoxShadow(
      color: Colors.black.withOpacity(GlassDesignSystem.glassShadowOpacity),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get glassShadowXL => [
    BoxShadow(
      color: Colors.black.withOpacity(GlassDesignSystem.glassShadowOpacity),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}
