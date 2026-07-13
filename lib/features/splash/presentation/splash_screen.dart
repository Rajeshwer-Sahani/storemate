import 'package:flutter/material.dart';
import 'package:storemate/features/auth/presentation/screens/login_screen.dart';
import 'package:storemate/features/home/presentation/screens/home_screen.dart';
import 'package:storemate/features/store_setup/presentation/screens/store_setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    // Logo scale animation
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Bottom loading-line animation
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
    );

    _animationController.forward();


    _checkAuthenticationStatus();  // Check authentication and store setup status.
  }

  Future<void> _checkAuthenticationStatus() async {
    // Keep the splash screen visible while its animation completes.
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) {
      return;
    }

    try {
      final supabase = Supabase.instance.client;

      // Get the currently authenticated user.
      final currentUser = supabase.auth.currentUser;

      // No authenticated user exists.
      if (currentUser == null) {
        _navigateTo(const LoginScreen());
        return;
      }

      // Check whether the logged-in user has completed store setup.
      final store = await supabase
          .from('stores')
          .select('id')
          .eq('owner_id', currentUser.id)
          .maybeSingle();

      if (!mounted) {
        return;
      }

      // No store exists, so the user must complete store setup.
      if (store == null) {
        _navigateTo(const StoreSetupScreen());
        return;
      }

      // A store already exists, so open the StoreMate dashboard.
      _navigateTo(const HomeScreen());
    } catch (error) {
      if (!mounted) {
        return;
      }

      // If the startup check fails, return to login safely.
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
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
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Subtle theme-aware background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF111C35),
                    const Color(0xFF10213D),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8FAFF),
                    const Color(0xFFEAF3FF),
                  ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),

        child: SafeArea(
          child: Stack(
            children: [
              // Existing animated StoreMate logo
              Center(
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

                        // Existing subtle blue glow
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.12),
                            colorScheme.primary.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                      child: Image.asset(
                        logoPath,
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Animated loading line
              Positioned(
                left: 40,
                right: 40,
                bottom: 32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    height: 4,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 4,
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
