import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';

/// Premium Glassmorphism Theme System
/// Catholic spirituality + modern glassmorphism + premium technology aesthetic
class GlassTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.light(
      primary: GlassDesignSystem.deepForestGreen,
      primaryContainer: GlassDesignSystem.emerald,
      secondary: GlassDesignSystem.sacredPurple,
      secondaryContainer: GlassDesignSystem.cathedralStone,
      tertiary: Color(0xDDF6FBFE),
      surface: GlassDesignSystem.lightGlass,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.black87,
      onSurface: GlassDesignSystem.subtleBrown,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    dividerColor: Color(0x263E9DCA),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: GlassDesignSystem.emerald,
      linearTrackColor: Color(0x263E9DCA),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xF2F6FBFE),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
        side: BorderSide(color: Color(0x333E9DCA)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GlassDesignSystem.deepForestGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: GlassDesignSystem.deepForestGreen,
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: GlassDesignSystem.deepForestGreen),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GlassDesignSystem.emerald,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceXL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GlassDesignSystem.deepForestGreen,
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GlassDesignSystem.emerald,
        side: BorderSide(color: GlassDesignSystem.emerald, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceXL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: GlassDesignSystem.spaceL,
        vertical: GlassDesignSystem.spaceM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide(color: GlassDesignSystem.emerald, width: 2),
      ),
      labelStyle: TextStyle(
        color: GlassDesignSystem.subtleBrown.withValues(alpha: 0.7),
        fontSize: GlassDesignSystem.fontSizeS,
      ),
      hintStyle: TextStyle(
        color: GlassDesignSystem.subtleBrown.withValues(alpha: 0.5),
        fontSize: GlassDesignSystem.fontSizeM,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: GlassDesignSystem.emerald,
      unselectedItemColor: GlassDesignSystem.subtleBrown.withValues(alpha: 0.6),
      selectedLabelStyle: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeDisplay,
        fontWeight: FontWeight.w700,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.deepForestGreen,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w500,
        color: GlassDesignSystem.subtleBrown,
        letterSpacing: 0,
      ),
      titleSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w500,
        color: GlassDesignSystem.subtleBrown,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.subtleBrown,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.subtleBrown,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.subtleBrown.withValues(alpha: 0.7),
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emerald,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emerald,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emerald,
        letterSpacing: 1.0,
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.dark(
      primary: GlassDesignSystem.emeraldLight,
      primaryContainer: GlassDesignSystem.emerald,
      secondary: GlassDesignSystem.sacredPurple,
      secondaryContainer: GlassDesignSystem.cathedralStone,
      tertiary: Color(0xD92A4862),
      surface: GlassDesignSystem.darkGlass,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.black87,
      onSurface: GlassDesignSystem.warmCream,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    dividerColor: Color(0x263E9DCA),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: GlassDesignSystem.emerald,
      linearTrackColor: Color(0x263E9DCA),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xF21B3249),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
        side: BorderSide(color: Color(0x4462DCE2)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GlassDesignSystem.deepForestGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: GlassDesignSystem.emeraldLight,
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: GlassDesignSystem.emeraldLight),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusL),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GlassDesignSystem.emeraldLight,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceXL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GlassDesignSystem.emeraldLight,
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GlassDesignSystem.emeraldLight,
        side: BorderSide(color: GlassDesignSystem.emeraldLight, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: GlassDesignSystem.spaceXL,
          vertical: GlassDesignSystem.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        ),
        textStyle: TextStyle(
          fontSize: GlassDesignSystem.fontSizeM,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: GlassDesignSystem.spaceL,
        vertical: GlassDesignSystem.spaceM,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
        borderSide: BorderSide(color: GlassDesignSystem.emeraldLight, width: 2),
      ),
      labelStyle: TextStyle(
        color: GlassDesignSystem.warmCream.withValues(alpha: 0.7),
        fontSize: GlassDesignSystem.fontSizeS,
      ),
      hintStyle: TextStyle(
        color: GlassDesignSystem.warmCream.withValues(alpha: 0.5),
        fontSize: GlassDesignSystem.fontSizeM,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: GlassDesignSystem.emeraldLight,
      unselectedItemColor: GlassDesignSystem.warmCream.withValues(alpha: 0.6),
      selectedLabelStyle: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeDisplay,
        fontWeight: FontWeight.w700,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0,
      ),
      headlineLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeL,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w500,
        color: GlassDesignSystem.warmCream,
        letterSpacing: 0,
      ),
      titleSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w500,
        color: GlassDesignSystem.warmCream,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeM,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.warmCream,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.warmCream,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w400,
        color: GlassDesignSystem.warmCream.withValues(alpha: 0.7),
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        fontSize: GlassDesignSystem.fontSizeS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: GlassDesignSystem.fontSizeXXS,
        fontWeight: FontWeight.w600,
        color: GlassDesignSystem.emeraldLight,
        letterSpacing: 1.0,
      ),
    ),
  );
}
