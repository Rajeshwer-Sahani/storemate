import 'package:flutter/material.dart';
import 'package:storemate/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _orbitAnimation;
  late final Animation<double> _brandingAnimation;
  late final Animation<double> _featuresAnimation;
  late final Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    _orbitAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOut),
    );

    _brandingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );

    _featuresAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getStarted() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const LoginScreen();
        },
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final isSmallHeight = size.height < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: Stack(
          children: [
            // -----------------------------------------------------------
            // Soft background glow
            // -----------------------------------------------------------
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.25),
                      radius: 0.9,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.10),
                        const Color(0xFFF8FBFF),
                        const Color(0xFFF1F7FF),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------
            // Bottom soft blue shape
            // -----------------------------------------------------------
            Positioned(
              left: -100,
              bottom: -150,
              child: IgnorePointer(
                child: Container(
                  width: 430,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.10),
                        colorScheme.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // -----------------------------------------------------------
            // Main content
            // -----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: isSmallHeight ? 18 : 30),

                  // -----------------------------------------------------
                  // Logo + orbit
                  // -----------------------------------------------------
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return SizedBox(
                            width: size.width * 0.82,
                            height: size.width * 0.82,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Orbit rings
                                Opacity(
                                  opacity: _orbitAnimation.value,
                                  child: CustomPaint(
                                    size: Size(
                                      size.width * 0.72,
                                      size.width * 0.72,
                                    ),
                                    painter: _OrbitPainter(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),

                                // Central glow
                                FadeTransition(
                                  opacity: _logoFadeAnimation,
                                  child: Container(
                                    width: size.width * 0.43,
                                    height: size.width * 0.43,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          colorScheme.primary.withValues(
                                            alpha: 0.20,
                                          ),
                                          colorScheme.primary.withValues(
                                            alpha: 0.06,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Main StoreMate icon
                                ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.75,
                                    end: 1.0,
                                  ).animate(_logoScaleAnimation),
                                  child: FadeTransition(
                                    opacity: _logoFadeAnimation,
                                    child: Container(
                                      width: size.width * 0.30,
                                      height: size.width * 0.30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.20),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.asset(
                                          'assets/logos/app_icon_logo2.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Top-left: Reports
                                _FeatureBubble(
                                  icon: Icons.bar_chart_rounded,
                                  color: const Color(0xFF1683F8),
                                  backgroundColor: const Color(0xFFE4F1FF),
                                  alignment: const Alignment(-0.68, -0.72),
                                  animation: _orbitAnimation,
                                ),

                                // Top-right: Customers
                                _FeatureBubble(
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF20BFA9),
                                  backgroundColor: const Color(0xFFE3FAF7),
                                  alignment: const Alignment(0.68, -0.68),
                                  animation: _orbitAnimation,
                                ),

                                // Left: Inventory
                                _FeatureBubble(
                                  icon: Icons.inventory_2_rounded,
                                  color: const Color(0xFFF28B35),
                                  backgroundColor: const Color(0xFFFFF0E4),
                                  alignment: const Alignment(-0.92, 0.10),
                                  animation: _orbitAnimation,
                                ),

                                // Right: EMI
                                _FeatureBubble(
                                  icon: Icons.currency_rupee_rounded,
                                  color: const Color(0xFF7566E8),
                                  backgroundColor: const Color(0xFFECEAFF),
                                  alignment: const Alignment(0.92, 0.10),
                                  animation: _orbitAnimation,
                                ),

                                // Bottom: Billing
                                _FeatureBubble(
                                  icon: Icons.receipt_long_rounded,
                                  color: const Color(0xFF16A6C5),
                                  backgroundColor: const Color(0xFFE2F8FC),
                                  alignment: const Alignment(0.0, 0.83),
                                  animation: _orbitAnimation,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // -----------------------------------------------------
                  // StoreMate branding
                  // -----------------------------------------------------
                  FadeTransition(
                    opacity: _brandingAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(_brandingAnimation),
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.8,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Store',
                                  style: TextStyle(
                                    color: const Color(0xFF0D1B3E),
                                  ),
                                ),
                                TextSpan(
                                  text: 'Mate',
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Your Complete Store Management Partner',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF65748B),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // -----------------------------------------------------
                  // Three benefits
                  // -----------------------------------------------------
                  FadeTransition(
                    opacity: _featuresAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: _BenefitItem(
                            icon: Icons.verified_user_outlined,
                            title: 'Organize',
                            subtitle: 'Better',
                          ),
                        ),
                        _VerticalDivider(),
                        Expanded(
                          child: _BenefitItem(
                            icon: Icons.trending_up_rounded,
                            title: 'Grow',
                            subtitle: 'Faster',
                          ),
                        ),
                        _VerticalDivider(),
                        Expanded(
                          child: _BenefitItem(
                            icon: Icons.favorite_border_rounded,
                            title: 'Serve',
                            subtitle: 'Smarter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallHeight ? 20 : 30),

                  // -----------------------------------------------------
                  // Let's Get Started button
                  // -----------------------------------------------------
                  FadeTransition(
                    opacity: _buttonAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(_buttonAnimation),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _getStarted,
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            shadowColor: colorScheme.primary.withValues(
                              alpha: 0.28,
                            ),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Let's Get Started",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallHeight ? 18 : 26),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Feature bubble
// ===========================================================================

class _FeatureBubble extends StatelessWidget {
  const _FeatureBubble({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.alignment,
    required this.animation,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Alignment alignment;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.65, end: 1.0).animate(animation),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 35, color: color),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Benefit item
// ===========================================================================

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF71819A)),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF66758C),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF66758C),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Vertical divider
// ===========================================================================

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFD5DFEB));
  }
}

// ===========================================================================
// Orbit painter
// ===========================================================================

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width * 0.43;

    final orbitPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, orbitPaint);

    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    canvas.drawCircle(center, radius * 0.72, outerPaint);

    final dotPaint = Paint()..color = color.withValues(alpha: 0.85);

    final dotPositions = [
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius, center.dy),
      Offset(center.dx - radius * 0.86, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.60, center.dy + radius * 0.72),
    ];

    for (final position in dotPositions) {
      canvas.drawCircle(position, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
