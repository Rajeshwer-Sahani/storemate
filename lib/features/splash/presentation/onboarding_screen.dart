import 'dart:math' as math;

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

    // ---------------------------------------------------------------
    // Logo fade
    // ---------------------------------------------------------------
    _logoFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    // ---------------------------------------------------------------
    // Logo scale
    // ---------------------------------------------------------------
    _logoScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    // ---------------------------------------------------------------
    // Orbit
    // ---------------------------------------------------------------
    _orbitAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.58, curve: Curves.easeOut),
    );

    // ---------------------------------------------------------------
    // Branding
    // ---------------------------------------------------------------
    _brandingAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 0.72, curve: Curves.easeOut),
    );

    // ---------------------------------------------------------------
    // Benefits
    // ---------------------------------------------------------------
    _featuresAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.82, curve: Curves.easeOut),
    );

    // ---------------------------------------------------------------
    // Button
    // ---------------------------------------------------------------
    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 1.0, curve: Curves.easeOut),
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
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curvedAnimation),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.25),
            radius: 1.0,
            colors: [
              colorScheme.primary.withValues(alpha: 0.075),
              const Color(0xFFF8FBFF),
              const Color(0xFFF1F7FF),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // ---------------------------------------------------------
              // Responsive sizing
              // ---------------------------------------------------------

              // Main orbit is deliberately smaller than before.
              final orbitSize = math.min(math.max(width * 0.68, 245.0), 285.0);

              final centerIconSize = orbitSize * 0.37;

              final featureBubbleSize = math.min(
                math.max(width * 0.145, 58.0),
                66.0,
              );

              final featureIconSize = featureBubbleSize * 0.42;

              final brandFontSize = math.min(
                math.max(width * 0.095, 32.0),
                38.0,
              );

              // Give smaller devices less vertical spacing.
              final compact = height < 700;
              final veryCompact = height < 630;

              return Padding(
                padding: EdgeInsets.fromLTRB(20, compact ? 8 : 14, 20, 6),
                child: Column(
                  children: [
                    // =====================================================
                    // HERO / ORBIT
                    // =====================================================
                    Expanded(
                      flex: veryCompact ? 43 : 46,
                      child: Center(
                        child: SizedBox(
                          width: orbitSize,
                          height: orbitSize,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // -------------------------------
                                  // Orbit rings
                                  // -------------------------------
                                  Opacity(
                                    opacity: _orbitAnimation.value.clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    child: CustomPaint(
                                      size: Size.square(orbitSize * 0.86),
                                      painter: _OrbitPainter(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),

                                  // -------------------------------
                                  // Central soft glow
                                  // -------------------------------
                                  FadeTransition(
                                    opacity: _logoFadeAnimation,
                                    child: Container(
                                      width: centerIconSize * 1.55,
                                      height: centerIconSize * 1.55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            colorScheme.primary.withValues(
                                              alpha: 0.18,
                                            ),
                                            colorScheme.primary.withValues(
                                              alpha: 0.055,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // -------------------------------
                                  // Central logo
                                  // -------------------------------
                                  ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.82,
                                      end: 1.0,
                                    ).animate(_logoScaleAnimation),
                                    child: FadeTransition(
                                      opacity: _logoFadeAnimation,
                                      child: Container(
                                        width: centerIconSize,
                                        height: centerIconSize,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.16),
                                              blurRadius: 22,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 7),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(
                                          centerIconSize * 0.16,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          child: Image.asset(
                                            'assets/logos/app_icon_logo2.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // -------------------------------
                                  // Reports
                                  // -------------------------------
                                  _FeatureBubble(
                                    icon: Icons.bar_chart_rounded,
                                    color: const Color(0xFF1683F8),
                                    backgroundColor: const Color(0xFFE5F2FF),
                                    alignment: const Alignment(-0.67, -0.70),
                                    animation: _orbitAnimation,
                                    size: featureBubbleSize,
                                    iconSize: featureIconSize,
                                  ),

                                  // -------------------------------
                                  // Customers
                                  // -------------------------------
                                  _FeatureBubble(
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF20BFA9),
                                    backgroundColor: const Color(0xFFE4FAF7),
                                    alignment: const Alignment(0.67, -0.70),
                                    animation: _orbitAnimation,
                                    size: featureBubbleSize,
                                    iconSize: featureIconSize,
                                  ),

                                  // -------------------------------
                                  // Inventory
                                  // -------------------------------
                                  _FeatureBubble(
                                    icon: Icons.inventory_2_rounded,
                                    color: const Color(0xFFF28B35),
                                    backgroundColor: const Color(0xFFFFF0E4),
                                    alignment: const Alignment(-0.88, 0.08),
                                    animation: _orbitAnimation,
                                    size: featureBubbleSize,
                                    iconSize: featureIconSize,
                                  ),

                                  // -------------------------------
                                  // EMI
                                  // -------------------------------
                                  _FeatureBubble(
                                    icon: Icons.currency_rupee_rounded,
                                    color: const Color(0xFF7566E8),
                                    backgroundColor: const Color(0xFFECEAFF),
                                    alignment: const Alignment(0.88, 0.08),
                                    animation: _orbitAnimation,
                                    size: featureBubbleSize,
                                    iconSize: featureIconSize,
                                  ),

                                  // -------------------------------
                                  // Billing
                                  // -------------------------------
                                  _FeatureBubble(
                                    icon: Icons.receipt_long_rounded,
                                    color: const Color(0xFF16A6C5),
                                    backgroundColor: const Color(0xFFE3F8FC),
                                    alignment: const Alignment(0.0, 0.82),
                                    animation: _orbitAnimation,
                                    size: featureBubbleSize,
                                    iconSize: featureIconSize,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // =====================================================
                    // BRANDING
                    // =====================================================
                    FadeTransition(
                      opacity: _brandingAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(_brandingAnimation),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: brandFontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.6,
                                  height: 1.0,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Store',
                                    style: TextStyle(
                                      color: Color(0xFF0B1B3A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Mate',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Your Complete Store Management Partner',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: math.min(
                                  math.max(width * 0.036, 11.0),
                                  12.5,
                                ),
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF71819A),
                                letterSpacing: 0.05,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: compact ? 12 : 17),

                    // =====================================================
                    // BENEFITS
                    // =====================================================
                    FadeTransition(
                      opacity: _featuresAnimation,
                      child: SizedBox(
                        height: compact ? 58 : 64,
                        child: Row(
                          children: [
                            Expanded(
                              child: _BenefitItem(
                                icon: Icons.verified_user_outlined,
                                title: 'Organize',
                                subtitle: 'Better',
                                compact: compact,
                              ),
                            ),

                            const _VerticalDivider(),

                            Expanded(
                              child: _BenefitItem(
                                icon: Icons.trending_up_rounded,
                                title: 'Grow',
                                subtitle: 'Faster',
                                compact: compact,
                              ),
                            ),

                            const _VerticalDivider(),

                            Expanded(
                              child: _BenefitItem(
                                icon: Icons.favorite_border_rounded,
                                title: 'Serve',
                                subtitle: 'Smarter',
                                compact: compact,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =====================================================
                    // BUTTON
                    // =====================================================
                    SizedBox(height: compact ? 15 : 22),

                    FadeTransition(
                      opacity: _buttonAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(_buttonAnimation),
                        child: SizedBox(
                          width: double.infinity,
                          height: compact ? 54 : 56,
                          child: ElevatedButton(
                            onPressed: _getStarted,
                            style: ElevatedButton.styleFrom(
                              elevation: 7,
                              shadowColor: colorScheme.primary.withValues(
                                alpha: 0.24,
                              ),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Let's Get Started",
                                  style: TextStyle(
                                    fontSize: compact ? 14 : 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.05,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: compact ? 21 : 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Very small bottom breathing room.
                    SizedBox(height: compact ? 6 : 9),
                  ],
                ),
              );
            },
          ),
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
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Alignment alignment;
  final Animation<double> animation;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size * 0.32),
            ),
            child: Icon(icon, size: iconSize, color: color),
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
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: compact ? 23 : 25, color: const Color(0xFF71819A)),

        const SizedBox(height: 3),

        Text(
          title,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF66758C),
            height: 1.15,
          ),
        ),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF66758C),
            height: 1.15,
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
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: const Color(0xFFD5DFEB));
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

    // Main orbit
    final orbitPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawCircle(center, radius, orbitPaint);

    // Soft inner ring
    final innerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius * 0.72, innerRingPaint);

    // Orbit dots
    final dotPaint = Paint()..color = color.withValues(alpha: 0.82);

    final dotPositions = [
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + radius, center.dy),
      Offset(center.dx - radius * 0.86, center.dy + radius * 0.5),
      Offset(center.dx + radius * 0.60, center.dy + radius * 0.72),
    ];

    for (final position in dotPositions) {
      canvas.drawCircle(position, 4.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
