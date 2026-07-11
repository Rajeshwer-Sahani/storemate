import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Check the current application theme
    final isDarkMode = theme.brightness == Brightness.dark;

    // Select the correct logo for the current theme
    final logoPath = isDarkMode
        ? 'assets/logos/storemate_logo_darkmode.png'
        : 'assets/logos/storemate_logo.png';

    // Responsive logo width
    final logoWidth = screenWidth * 0.48;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: logoWidth + 100,
              height: logoWidth + 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                // Subtle theme-aware blue glow
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    Colors.transparent,
                  ],
                  stops: const [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),

              // Theme-specific StoreMate logo
              child: Image.asset(
                logoPath,
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}