import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // Fixed Header
            // =================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _ProfileHeader(
                onBack: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),

            // =================================================================
            // Scrollable Content
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------------
                    // Profile Summary
                    // ---------------------------------------------------------
                    const _ProfileSummaryCard(),

                    const SizedBox(height: 22),

                    // ---------------------------------------------------------
                    // Personal Information
                    // ---------------------------------------------------------
                    _ProfileSectionCard(
                      title: 'Personal Information',
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.person_outline_rounded,
                          title: 'Full Name',
                          value: 'Rajeshwar S.',
                          onTap: () {
                            // TODO: Open edit personal information.
                          },
                        ),
                        _ProfileInfoRow(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          value: '+91 98765 43210',
                          onTap: () {
                            // TODO: Open edit phone number.
                          },
                        ),
                        _ProfileInfoRow(
                          icon: Icons.email_outlined,
                          title: 'Email Address',
                          value: 'rajeshwar@example.com',
                          onTap: () {
                            // TODO: Open edit email address.
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------------------------------------
                    // Store Information
                    // ---------------------------------------------------------
                    _ProfileSectionCard(
                      title: 'Store Information',
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.storefront_outlined,
                          title: 'Store Name',
                          value: 'Raj Mobile Care',
                          onTap: () {
                            // TODO: Open edit store information.
                          },
                        ),
                        _ProfileInfoRow(
                          icon: Icons.location_on_outlined,
                          title: 'Store Address',
                          value: '123, MG Road, Indore, MP 452001',
                          onTap: () {
                            // TODO: Open edit store address.
                          },
                        ),
                        _ProfileInfoRow(
                          icon: Icons.phone_outlined,
                          title: 'Store Phone',
                          value: '+91 731 123 4567',
                          onTap: () {
                            // TODO: Open edit store phone.
                          },
                        ),
                        _ProfileInfoRow(
                          icon: Icons.email_outlined,
                          title: 'Store Email',
                          value: 'info@rajmobilecare.com',
                          onTap: () {
                            // TODO: Open edit store email.
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------------------------------------
                    // Account
                    // ---------------------------------------------------------
                    _ProfileSectionCard(
                      title: 'Account',
                      children: [
                        _ProfileActionRow(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          iconBackground: colorScheme.secondaryContainer,
                          iconColor: colorScheme.onSecondaryContainer,
                          onTap: () {
                            // TODO: Open change password screen.
                          },
                        ),
                        _ProfileActionRow(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          subtitle: 'Sign out from your account',
                          iconBackground: colorScheme.errorContainer,
                          iconColor: colorScheme.error,
                          titleColor: colorScheme.error,
                          onTap: () {
                            _showLogoutConfirmation(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---------------------------------------------------------
                    // Security Footer
                    // ---------------------------------------------------------
                    const _SecurityFooter(),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Logout Confirmation
  // ===========================================================================

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: const Text('Log Out?'),
          content: const Text(
            'Are you sure you want to sign out from your StoreMate account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // TODO: Connect to the actual authentication logout.
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Profile Header
// =============================================================================

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---------------------------------------------------------------------
        // Back Button
        // ---------------------------------------------------------------------
        SizedBox(
          width: 50,
          height: 50,
          child: OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 25,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // ---------------------------------------------------------------------
        // Title
        // ---------------------------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Manage your account and store',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Profile Summary Card
// =============================================================================

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final baseColor = colorScheme.surfaceContainerLow;

    final subtleBlue = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.045),
      baseColor,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.60),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===================================================================
          // Profile Identity
          // ===================================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [subtleBlue, colorScheme.surface],
              ),
            ),
            child: Row(
              children: [
                // -------------------------------------------------------------
                // Avatar + Camera
                // -------------------------------------------------------------
                SizedBox(
                  width: 142,
                  height: 116,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 104,
                          height: 104,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(alpha: 0.08),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.20,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              'RS',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // -------------------------------------------------------
                      // Camera Button
                      // -------------------------------------------------------
                      Positioned(
                        left: 83,
                        top: 72,
                        child: Material(
                          color: colorScheme.surface,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              // TODO: Open profile image picker.
                            },
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 19,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // -------------------------------------------------------------
                // Identity Information
                // -------------------------------------------------------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajeshwar S.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.25,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Store Owner',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer.withValues(
                              alpha: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 17,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Verified',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================================
          // Statistics
          // ===================================================================
          Container(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.receipt_long_outlined,
                    value: '248',
                    label: 'Bills Created',
                  ),
                ),

                _StatisticDivider(),

                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.people_outline_rounded,
                    value: '32',
                    label: 'Customers',
                  ),
                ),

                _StatisticDivider(),

                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.shopping_bag_outlined,
                    value: '₹2.45L',
                    label: 'Total Sales',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Profile Statistic
// =============================================================================

class _ProfileStatistic extends StatelessWidget {
  const _ProfileStatistic({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 22, color: colorScheme.primary),
        ),

        const SizedBox(height: 9),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Statistic Divider
// =============================================================================

class _StatisticDivider extends StatelessWidget {
  const _StatisticDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 72,
      color: colorScheme.outlineVariant.withValues(alpha: 0.55),
    );
  }
}

// =============================================================================
// Profile Section Card
// =============================================================================

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.62),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.15,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ...children,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Profile Information Row
// =============================================================================

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.50),
              ),
            ),
          ),
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // Icon
              // ----------------------------------------------------------------
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: colorScheme.primary),
              ),

              const SizedBox(width: 14),

              // ----------------------------------------------------------------
              // Text
              // ----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ----------------------------------------------------------------
              // Arrow
              // ----------------------------------------------------------------
              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Profile Action Row
// =============================================================================

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.50),
              ),
            ),
          ),
          child: Row(
            children: [
              // ----------------------------------------------------------------
              // Icon
              // ----------------------------------------------------------------
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),

              const SizedBox(width: 14),

              // ----------------------------------------------------------------
              // Text
              // ----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: titleColor ?? colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Security Footer
// =============================================================================

class _SecurityFooter extends StatelessWidget {
  const _SecurityFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 17,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Text(
            'Your data is secure and encrypted',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
