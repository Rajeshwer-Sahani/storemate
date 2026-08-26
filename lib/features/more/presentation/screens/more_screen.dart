import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/emi/data/models/emi_installment_model.dart';

import 'package:storemate/features/emi/data/repositories/emi_repository_impl.dart';
import 'package:storemate/features/emi/data/services/emi_service.dart';
import 'package:storemate/features/emi/presentation/controllers/create_emi_plan_controller.dart';
import 'package:storemate/features/emi/presentation/controllers/emi_controller.dart';
import 'package:storemate/features/emi/presentation/controllers/record_emi_payment_controller.dart';
import 'package:storemate/features/emi/presentation/screens/create_emi_plan_screen.dart';
import 'package:storemate/features/emi/presentation/screens/emi_plan_details_screen.dart';
import 'package:storemate/features/emi/presentation/screens/emi_plan_list_screen.dart';
import 'package:storemate/features/emi/presentation/screens/record_emi_payment_screen.dart';
import 'package:storemate/features/emi/presentation/screens/select_invoice_for_emi_screen.dart';
import 'package:storemate/features/more/widgets/more_section_header.dart';

import '../../../../core/widgets/app_module_header.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Future<void> _onRefresh() async {
    // TODO: Add More module refresh logic when needed.
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===================================================================
            // Fixed Main Header
            // ===================================================================
            const AppModuleHeader(
              title: 'More',
              subtitle: 'Additional tools & management',
            ),

            // ===================================================================
            // Header Divider
            // ===================================================================
            const _SectionDivider(),

            // ===================================================================
            // Scrollable Content + Pull to Refresh
            // ===================================================================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                displacement: 24,
                strokeWidth: 2.5,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.zero,
                  children: [
                    // =============================================================
                    // Management Section
                    // =============================================================
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 12),
                      child: MoreSectionHeader(
                        title: 'Management',
                        subtitle: 'Manage your store operations',
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // =======================================================
                          // Featured EMI Card
                          // =======================================================
                          _FeaturedEmiCard(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const _EmiPlanRoute(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // =======================================================
                          // Reports + Warranty
                          // =======================================================
                          Row(
                            children: [
                              Expanded(
                                child: _CompactModuleCard(
                                  icon: Icons.bar_chart_rounded,
                                  title: 'Reports',
                                  subtitle: 'Business insights',
                                  onTap: null,
                                  comingSoon: true,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _CompactModuleCard(
                                  icon: Icons.verified_user_rounded,
                                  title: 'Warranty',
                                  subtitle: 'Product coverage',
                                  onTap: null,
                                  comingSoon: true,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // =======================================================
                          // Repairs
                          // =======================================================
                          _WideModuleCard(
                            icon: Icons.build_rounded,
                            title: 'Repairs',
                            subtitle: 'Manage repair jobs & service records',
                            onTap: null,
                            comingSoon: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =============================================================
                    // Store Section
                    // =============================================================
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: MoreSectionHeader(
                        title: 'Store',
                        subtitle: 'Manage your store and team',
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CompactModuleCard(
                              icon: Icons.badge_rounded,
                              title: 'Employees',
                              subtitle: 'Staff & access',
                              onTap: null,
                              comingSoon: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _CompactModuleCard(
                              icon: Icons.settings_rounded,
                              title: 'Settings',
                              subtitle: 'Store preferences',
                              onTap: null,
                              comingSoon: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =============================================================
                    // Bottom Spacing
                    // =============================================================
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Section Divider
// =============================================================================

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.65),
      ),
    );
  }
}

// =============================================================================
// Featured EMI Card
// =============================================================================

// =============================================================================
// Featured EMI Card
// =============================================================================

class _FeaturedEmiCard extends StatelessWidget {
  const _FeaturedEmiCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final baseColor = colorScheme.surfaceContainerLow;

    final subtleBlue = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      baseColor,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            // -----------------------------------------------------------------
            // Subtle premium surface gradient
            // -----------------------------------------------------------------
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [subtleBlue, baseColor],
              stops: const [0.0, 1.0],
            ),

            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.16),
            ),

            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // Top Row
                // =============================================================
                Row(
                  children: [
                    // ---------------------------------------------------------
                    // Icon
                    // ---------------------------------------------------------
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: colorScheme.primary,
                        size: 26,
                      ),
                    ),

                    const Spacer(),

                    // ---------------------------------------------------------
                    // Available Badge
                    // ---------------------------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            'Available',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // =============================================================
                // Title
                // =============================================================
                Text(
                  'EMI Management',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                  ),
                ),

                const SizedBox(height: 5),

                // =============================================================
                // Description
                // =============================================================
                Text(
                  'Manage plans, installments and repayments',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 18),

                // =============================================================
                // CTA
                // =============================================================
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open EMI Management',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Compact Module Card
// =============================================================================

class _CompactModuleCard extends StatelessWidget {
  const _CompactModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 154,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ModuleIcon(icon: icon, size: 42),
                  const Spacer(),
                  if (comingSoon) const _ComingSoonBadge(),
                ],
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Wide Module Card
// =============================================================================

class _WideModuleCard extends StatelessWidget {
  const _WideModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _ModuleIcon(icon: icon, size: 46),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              if (comingSoon) const _ComingSoonBadge(),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Module Icon
// =============================================================================

class _ModuleIcon extends StatelessWidget {
  const _ModuleIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: colorScheme.primary, size: size * 0.52),
    );
  }
}

// =============================================================================
// Coming Soon Badge
// =============================================================================

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Soon',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// EMI Plan Route
// =============================================================================

class _EmiPlanRoute extends StatefulWidget {
  const _EmiPlanRoute();

  @override
  State<_EmiPlanRoute> createState() => _EmiPlanRouteState();
}

class _EmiPlanRouteState extends State<_EmiPlanRoute> {
  late final EmiController _controller;

  @override
  void initState() {
    super.initState();

    _controller = EmiController(repository: EmiRepositoryImpl());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmiPlanListScreen(
      controller: _controller,
      onCreateEmiPlan: _onCreateEmiPlan,
      onPlanTap: _onPlanTap,
    );
  }

  // ===========================================================================
  // Create EMI Plan
  // ===========================================================================

  Future<void> _onCreateEmiPlan() async {
    final selectedInvoice = await Navigator.of(context).push<InvoiceModel>(
      MaterialPageRoute(builder: (_) => const SelectInvoiceForEmiScreen()),
    );

    if (!mounted || selectedInvoice == null) {
      return;
    }

    final createdPlan = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CreateEmiPlanController(
            service: EmiService(repository: EmiRepositoryImpl()),
          ),
          child: CreateEmiPlanScreen(invoice: selectedInvoice),
        ),
      ),
    );

    if (!mounted || createdPlan == null) {
      return;
    }

    await _controller.loadEmiPlans();
  }

  // =============================================================================
  // EMI Plan Details
  // =============================================================================

  Future<void> _onPlanTap(String emiPlanId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmiPlanDetailsScreen(
          controller: _controller,
          emiPlanId: emiPlanId,
          onRecordPayment: (emiPlanId, installment) async {
            await _onRecordPayment(emiPlanId, installment);
          },
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _controller.loadEmiPlans();
  }

  // =============================================================================
  // Record EMI Payment
  // =============================================================================

  Future<void> _onRecordPayment(
    String emiPlanId,
    EmiInstallmentModel installment,
  ) async {
    final payment = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RecordEmiPaymentController(
            service: EmiService(repository: EmiRepositoryImpl()),
          ),
          child: RecordEmiPaymentScreen(
            emiPlanId: emiPlanId,
            installment: installment,
            remainingAmount: installment.remainingAmount,
          ),
        ),
      ),
    );

    if (!mounted || payment == null) {
      return;
    }

    await _controller.refreshEmiPlan(emiPlanId);

    if (!mounted) {
      return;
    }

    await _controller.loadEmiPlans();
  }
}
