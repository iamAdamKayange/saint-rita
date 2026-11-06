import 'package:flutter/material.dart';
import 'package:saint_rita/widgets/animated_nun_3d.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/glassmorphism/glass_components.dart';
import 'package:saint_rita/glassmorphism/glass_ui_components.dart';

/// Premium Glassmorphism Splash Screen
/// Catholic spirituality + modern glassmorphism + premium technology aesthetic
class GlassSplashScreen extends StatefulWidget {
  const GlassSplashScreen({super.key});

  @override
  State<GlassSplashScreen> createState() => _GlassSplashScreenState();
}

class _GlassSplashScreenState extends State<GlassSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GlassDesignSystem.durationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: GlassDesignSystem.curveSmooth),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: GlassDesignSystem.curveSmooth),
    );

    _controller.forward();

    // Navigate to onboarding after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: GlassGradients.sacredGradient,
        ),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: _SacredPatternPainter(),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glass logo container
                      GlassCard(
                        preset: GlassDesignSystem.prominent,
                        padding: EdgeInsets.all(GlassDesignSystem.spaceXXL),
                        margin: EdgeInsets.symmetric(
                          horizontal: GlassDesignSystem.spaceXL,
                        ),
                        child: Column(
                          children: [
                            // Spiritual icon
                            const AnimatedNun3D(
                              height: 210,
                              interactive: false,
                            ),
                            SizedBox(height: GlassDesignSystem.spaceL),
                            
                            // App name
                            Text(
                              'Prayer Companion',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: GlassDesignSystem.spaceS),
                            
                            // Tagline
                            Text(
                              'Your Spiritual Journey',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: GlassDesignSystem.spaceXXL),
                      
                      // Glass loading indicator
                      GlassContainer(
                        preset: GlassDesignSystem.subtle,
                        padding: EdgeInsets.symmetric(
                          horizontal: GlassDesignSystem.spaceL,
                          vertical: GlassDesignSystem.spaceM,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  GlassDesignSystem.softGold,
                                ),
                              ),
                            ),
                            SizedBox(width: GlassDesignSystem.spaceM),
                            Text(
                              'Preparing your sanctuary...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom glass decoration
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDarkMode 
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sacred pattern painter for subtle background
class _SacredPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle geometric pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    // Concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * i / 3,
        paint,
      );
    }

    // Cross pattern
    final crossSize = radius * 0.5;
    canvas.drawLine(
      Offset(centerX - crossSize, centerY),
      Offset(centerX + crossSize, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - crossSize),
      Offset(centerX, centerY + crossSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SacredPatternPainter oldDelegate) => false;
}