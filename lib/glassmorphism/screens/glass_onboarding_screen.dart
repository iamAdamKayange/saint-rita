import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_ui_components.dart';
import 'package:saint_rita/services/admob_service.dart';
import 'package:saint_rita/provider/language_provider.dart';

/// Premium Glassmorphism Onboarding Screen
/// Catholic spirituality + modern glassmorphism + premium technology aesthetic
class GlassOnboardingScreen extends StatefulWidget {
  const GlassOnboardingScreen({super.key});

  @override
  State<GlassOnboardingScreen> createState() => _GlassOnboardingScreenState();
}

class _GlassOnboardingScreenState extends State<GlassOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.church,
      title: 'Your Spiritual Sanctuary',
      description: 'A peaceful space for daily prayer, reflection, and spiritual growth. Begin your journey with sacred traditions.',
      titleSw: 'Mahali pako pa sala',
      descriptionSw: 'Tenga muda wa sala ya kila siku, tafakari na kukua kiroho. Anza safari yako ya imani.',
      gradient: GlassGradients.sacredGradient,
    ),
    OnboardingPage(
      icon: Icons.auto_stories,
      title: 'Sacred Prayer Journeys',
      description: 'Experience the power of novenas and dedicated prayer sequences. Walk with saints through time-honored devotions.',
      titleSw: 'Safari takatifu za sala',
      descriptionSw: 'Fuata novena na sala za mfululizo pamoja na watakatifu katika ibada za jadi.',
      gradient: GlassGradients.forestGradient,
    ),
    OnboardingPage(
      icon: Icons.favorite,
      title: 'Personal Spiritual Growth',
      description: 'Track your prayer progress, save favorites, and build a meaningful spiritual practice that fits your life.',
      titleSw: 'Kukua katika imani',
      descriptionSw: 'Fuatilia maendeleo ya sala, hifadhi unazozipenda na jenga utaratibu wa imani unaokufaa.',
      gradient: GlassGradients.goldGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: GlassDesignSystem.durationNormal,
        curve: GlassDesignSystem.curveSmooth,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeUser', false);
    if (!mounted) return;
    // Show interstitial ad at natural transition
    AdMobService().showInterstitialAd();
    
    Navigator.pushReplacementNamed(context, '/sanctuary');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isSwahili = context.watch<LanguageProvider>().isSwahili;

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: GlassDesignSystem.spaceL,
                  vertical: GlassDesignSystem.spaceM,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      isSwahili ? 'Ruka' : 'Skip',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(context, _pages[index], isDarkMode, isSwahili);
                  },
                ),
              ),

              // Bottom navigation
              Padding(
                padding: EdgeInsets.all(GlassDesignSystem.spaceXL),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildPageIndicator(index),
                      ),
                    ),
                    SizedBox(height: GlassDesignSystem.spaceL),
                    
                    // Next/Complete button
                    GlassButton(
                      text: _currentPage == _pages.length - 1
                          ? (isSwahili ? 'Anza' : 'Begin')
                          : (isSwahili ? 'Endelea' : 'Continue'),
                      onPressed: _nextPage,
                      isFullWidth: true,
                      preset: GlassDesignSystem.prominent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page, bool isDarkMode, bool isSwahili) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(GlassDesignSystem.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass icon container
          GlassCard(
            preset: GlassDesignSystem.prominent,
            margin: EdgeInsets.only(bottom: GlassDesignSystem.spaceXXL),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: page.gradient,
                borderRadius: BorderRadius.circular(GlassDesignSystem.radiusXXL),
              ),
              child: Icon(
                page.icon,
                size: GlassDesignSystem.iconXL,
                color: Colors.white,
              ),
            ),
          ),

          // Title
          Text(
            isSwahili ? page.titleSw : page.title,
            style: theme.textTheme.displaySmall?.copyWith(
              color: isDarkMode ? Colors.white : GlassDesignSystem.deepForestGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: GlassDesignSystem.spaceL),

          // Description
          Text(
            isSwahili ? page.descriptionSw : page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.8)
                  : GlassDesignSystem.subtleBrown.withOpacity(0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: GlassDesignSystem.durationNormal,
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? GlassDesignSystem.emerald
            : (isDarkMode ? Colors.white24 : Colors.black12),
        borderRadius: BorderRadius.circular(GlassDesignSystem.radiusFull),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String titleSw;
  final String descriptionSw;
  final LinearGradient gradient;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.titleSw,
    required this.descriptionSw,
    required this.gradient,
  });
}
