import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storemate/features/dashboard/data/models/profile_data_model.dart';
import 'package:storemate/features/dashboard/data/repositories/profile_repository_impl.dart';
import 'package:storemate/features/dashboard/data/services/profile_service.dart';
import 'package:storemate/features/dashboard/presentation/providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onEditProfile,
    this.onEditStore,
    this.onChangePassword,
    this.onLogout,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onEditStore;
  final VoidCallback? onChangePassword;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(
        service: ProfileService(repository: ProfileRepositoryImpl()),
      )..loadProfile(),
      child: _ProfileView(
        onEditProfile: onEditProfile,
        onEditStore: onEditStore,
        onChangePassword: onChangePassword,
        onLogout: onLogout,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    this.onEditProfile,
    this.onEditStore,
    this.onChangePassword,
    this.onLogout,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onEditStore;
  final VoidCallback? onChangePassword;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ========================================================================
    // Initial Loading
    // ========================================================================

    if (provider.isLoading && !provider.hasData) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    // ========================================================================
    // Error
    // ========================================================================

    if (provider.hasError && !provider.hasData) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Unable to load profile',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    provider.errorMessage ??
                        'Something went wrong. Please try again.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  FilledButton.icon(
                    onPressed: provider.loadProfile,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final data = provider.profileData;

    if (data == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('No profile data available.')),
        ),
      );
    }

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
              child: RefreshIndicator(
                onRefresh: provider.refreshProfile,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ---------------------------------------------------
                          // Profile Summary
                          // ---------------------------------------------------
                          _ProfileSummaryCard(
                            data: data,
                            onEditProfile: onEditProfile,
                          ),

                          const SizedBox(height: 22),

                          // ---------------------------------------------------
                          // Personal Information
                          // ---------------------------------------------------
                          _PersonalInformationCard(
                            data: data,
                            onEditProfile: onEditProfile,
                          ),

                          const SizedBox(height: 18),

                          // ---------------------------------------------------
                          // Store Information
                          // ---------------------------------------------------
                          _StoreInformationCard(
                            data: data,
                            onEditStore: onEditStore,
                          ),

                          const SizedBox(height: 18),

                          // ---------------------------------------------------
                          // Account
                          // ---------------------------------------------------
                          _ProfileSectionCard(
                            title: 'Account',
                            children: [
                              _ProfileActionRow(
                                icon: Icons.lock_outline_rounded,
                                title: 'Change Password',
                                subtitle: 'Update your account password',
                                iconBackground: colorScheme.secondaryContainer,
                                iconColor: colorScheme.onSecondaryContainer,
                                onTap: onChangePassword,
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

                          const SizedBox(height: 20),

                          const _SecurityFooter(),

                          const SizedBox(height: 8),
                        ]),
                      ),
                    ),
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
                onLogout?.call();
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------------------
          // Back Button
          // -------------------------------------------------------------------
          SizedBox(
            width: 48,
            height: 48,
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

          const SizedBox(width: 16),

          // -------------------------------------------------------------------
          // Title + Subtitle
          // -------------------------------------------------------------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Manage your account and store',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Profile Summary Card
// =============================================================================

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.data, this.onEditProfile});

  final ProfileDataModel data;
  final VoidCallback? onEditProfile;

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
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
                // Avatar
                // -------------------------------------------------------------
                SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
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
                            data.initials,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: -2,
                        bottom: 3,
                        child: Material(
                          color: colorScheme.surface,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: onEditProfile,
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

                const SizedBox(width: 14),

                // -------------------------------------------------------------
                // Identity
                // -------------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        data.store.businessType,
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
                          color: data.isEmailVerified
                              ? Colors.green.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              data.isEmailVerified
                                  ? Icons.verified_outlined
                                  : Icons.info_outline_rounded,
                              size: 17,
                              color: data.isEmailVerified
                                  ? Colors.green.shade700
                                  : colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data.isEmailVerified
                                  ? 'Email Verified'
                                  : 'Email Not Verified',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: data.isEmailVerified
                                    ? Colors.green.shade700
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
            child: Row(
              children: [
                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.receipt_long_outlined,
                    value: data.billCount.toString(),
                    label: 'Bills Created',
                    iconBackground: Colors.deepPurple.withValues(alpha: 0.12),
                    iconColor: Colors.deepPurple,
                  ),
                ),

                const _StatisticDivider(),

                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.people_outline_rounded,
                    value: data.customerCount.toString(),
                    label: 'Customers',
                    iconBackground: Colors.teal.withValues(alpha: 0.12),
                    iconColor: Colors.teal.shade700,
                  ),
                ),

                const _StatisticDivider(),

                Expanded(
                  child: _ProfileStatistic(
                    icon: Icons.shopping_bag_outlined,
                    value: _formatCurrency(data.totalSales),
                    label: 'Total Sales',
                    iconBackground: Colors.green.withValues(alpha: 0.12),
                    iconColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
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
    required this.iconBackground,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBackground;
  final Color iconColor;

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
            color: iconBackground,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 22, color: iconColor),
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

class _PersonalInformationCard extends StatelessWidget {
  const _PersonalInformationCard({required this.data, this.onEditProfile});

  final ProfileDataModel data;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Personal Information',
      children: [
        _ProfileInfoRow(
          icon: Icons.person_outline_rounded,
          title: 'Full Name',
          value: data.fullName.isEmpty ? 'Not set' : data.fullName,
          iconBackground: Colors.indigo.withValues(alpha: 0.12),
          iconColor: Colors.indigo,
          onTap: onEditProfile,
        ),

        _ProfileInfoRow(
          icon: Icons.email_outlined,
          title: 'Email Address',
          value: data.email.isEmpty ? 'Not available' : data.email,
          iconBackground: Colors.blue.withValues(alpha: 0.12),
          iconColor: Colors.blue.shade700,
          onTap: onEditProfile,
        ),

        _ProfileInfoRow(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          value: data.store.ownerPhone.isEmpty
              ? 'Not available'
              : data.store.ownerPhone,
          iconBackground: Colors.orange.withValues(alpha: 0.12),
          iconColor: Colors.orange.shade700,
          onTap: onEditProfile,
        ),
      ],
    );
  }
}

class _StoreInformationCard extends StatelessWidget {
  const _StoreInformationCard({required this.data, this.onEditStore});

  final ProfileDataModel data;
  final VoidCallback? onEditStore;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionCard(
      title: 'Store Information',
      children: [
        _ProfileInfoRow(
          icon: Icons.storefront_outlined,
          title: 'Store Name',
          value: data.store.storeName,
          iconBackground: Colors.deepPurple.withValues(alpha: 0.12),
          iconColor: Colors.deepPurple,
          onTap: onEditStore,
        ),

        _ProfileInfoRow(
          icon: Icons.location_on_outlined,
          title: 'Store Address',
          value: data.store.storeAddress,
          iconBackground: Colors.red.withValues(alpha: 0.12),
          iconColor: Colors.red.shade700,
          onTap: onEditStore,
        ),

        _ProfileInfoRow(
          icon: Icons.business_outlined,
          title: 'Business Type',
          value: data.store.businessType,
          iconBackground: Colors.teal.withValues(alpha: 0.12),
          iconColor: Colors.teal.shade700,
          onTap: onEditStore,
        ),

        _ProfileInfoRow(
          icon: Icons.phone_outlined,
          title: 'Store Phone',
          value: data.store.ownerPhone,
          iconBackground: Colors.orange.withValues(alpha: 0.12),
          iconColor: Colors.orange.shade700,
          onTap: onEditStore,
        ),

        _ProfileInfoRow(
          icon: Icons.receipt_long_outlined,
          title: 'GST Number',
          value: data.store.gstNumber?.trim().isNotEmpty == true
              ? data.store.gstNumber!
              : 'Not added',
          iconBackground: Colors.blueGrey.withValues(alpha: 0.12),
          iconColor: Colors.blueGrey.shade700,
          onTap: onEditStore,
        ),
      ],
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
    this.onTap,
    this.iconBackground,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final Color? iconBackground;
  final Color? iconColor;

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.50),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      iconBackground ??
                      colorScheme.primaryContainer.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? colorScheme.primary,
                ),
              ),

              const SizedBox(width: 14),

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
                        color: value == 'Not available'
                            ? colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.70,
                              )
                            : colorScheme.onSurfaceVariant,
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
  final VoidCallback? onTap;
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.50),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),

              const SizedBox(width: 14),

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
