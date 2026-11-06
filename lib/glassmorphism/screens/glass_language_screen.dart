import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_ui_components.dart';
import 'package:saint_rita/provider/language_provider.dart';

/// Premium Glassmorphism Language Selection Screen
/// Catholic spirituality + modern glassmorphism + premium technology aesthetic
class GlassLanguageScreen extends StatelessWidget {
  const GlassLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSwahili = languageProvider.isSwahili;

    return Scaffold(
      appBar: GlassAppBar(
        title: isSwahili ? 'Lugha' : 'Language',
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [Color(0xFF102940), Color(0xFF0B1D30)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Color(0xFFEAF6FC), Color(0xFFF5FAFD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(GlassDesignSystem.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              GlassCard(
                preset: GlassDesignSystem.standard,
                padding: EdgeInsets.all(GlassDesignSystem.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.language,
                      color: GlassDesignSystem.emerald,
                      size: GlassDesignSystem.iconL,
                    ),
                    SizedBox(height: GlassDesignSystem.spaceM),
                    Text(
                      isSwahili ? 'Chagua lugha yako' : 'Select Your Language',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen,
                        fontSize: GlassDesignSystem.fontSizeL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: GlassDesignSystem.spaceS),
                    Text(
                      isSwahili
                          ? 'Chagua lugha utakayotumia kwenye sala na programu.'
                          : 'Choose your preferred language for prayers and app interface.',
                      style: TextStyle(
                        color: isDarkMode 
                            ? Colors.white.withValues(alpha: 0.7)
                            : GlassDesignSystem.subtleBrown.withValues(alpha: 0.7),
                        fontSize: GlassDesignSystem.fontSizeM,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: GlassDesignSystem.spaceL),

              // English option
              GlassCard(
                preset: GlassDesignSystem.standard,
                onTap: () {
                  languageProvider.setLanguage('en');
                  GlassToast.show(
                    context: context,
                    message: isSwahili
                        ? 'Lugha imebadilishwa kuwa Kiingereza'
                        : 'Language changed to English',
                    type: GlassToastType.success,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: !languageProvider.isSwahili
                          ? GlassDesignSystem.emerald
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(GlassDesignSystem.spaceL),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [GlassDesignSystem.emerald, GlassDesignSystem.divineBlue],
                            ),
                            borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
                          ),
                          child: Center(
                            child: Text(
                              '🇬🇧',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        SizedBox(width: GlassDesignSystem.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'English',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen,
                                  fontSize: GlassDesignSystem.fontSizeL,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: GlassDesignSystem.spaceXS),
                              Text(
                                isSwahili ? 'Kwa watumiaji wa Kiingereza' : 'For English-speaking users',
                                style: TextStyle(
                                  color: isDarkMode 
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : GlassDesignSystem.subtleBrown.withValues(alpha: 0.6),
                                  fontSize: GlassDesignSystem.fontSizeS,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!languageProvider.isSwahili)
                          Icon(
                            Icons.check_circle,
                            color: GlassDesignSystem.emerald,
                            size: GlassDesignSystem.iconL,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: GlassDesignSystem.spaceM),

              // Swahili option
              GlassCard(
                preset: GlassDesignSystem.standard,
                onTap: () {
                  languageProvider.setLanguage('sw');
                  GlassToast.show(
                    context: context,
                    message: 'Limebadilishwa hadi Kiswahili',
                    type: GlassToastType.success,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: languageProvider.isSwahili
                          ? GlassDesignSystem.emerald
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(GlassDesignSystem.spaceL),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [GlassDesignSystem.emerald, GlassDesignSystem.divineBlue],
                            ),
                            borderRadius: BorderRadius.circular(GlassDesignSystem.radiusM),
                          ),
                          child: Center(
                            child: Text(
                              '🇹🇿',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        SizedBox(width: GlassDesignSystem.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kiswahili',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen,
                                  fontSize: GlassDesignSystem.fontSizeL,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: GlassDesignSystem.spaceXS),
                              Text(
                                'Kwa watumiaji wa Kiswahili',
                                style: TextStyle(
                                  color: isDarkMode 
                                      ? Colors.white.withValues(alpha: 0.6)
                                      : GlassDesignSystem.subtleBrown.withValues(alpha: 0.6),
                                  fontSize: GlassDesignSystem.fontSizeS,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (languageProvider.isSwahili)
                          Icon(
                            Icons.check_circle,
                            color: GlassDesignSystem.emerald,
                            size: GlassDesignSystem.iconL,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: GlassDesignSystem.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}
