import 'package:flutter/material.dart';

import 'package:storemate/features/emi/data/repositories/emi_repository_impl.dart';
import 'package:storemate/features/emi/presentation/controllers/emi_controller.dart';
import 'package:storemate/features/emi/presentation/screens/emi_plan_list_screen.dart';
import 'package:storemate/features/more/widgets/more_module_card.dart';
import 'package:storemate/features/more/widgets/more_section_header.dart';

import '../../../../core/widgets/app_module_header.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // =================================================================
            // Main Header
            // =================================================================
            const AppModuleHeader(
              title: 'More',
              subtitle: 'Additional tools & management',
            ),

            // =================================================================
            // Management
            // =================================================================
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: MoreSectionHeader(
                title: 'Management',
                subtitle: 'Manage your store operations',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ===========================================================
                  // EMI Management
                  // ===========================================================
                  MoreModuleCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'EMI Management',
                    subtitle: 'Manage plans & repayments',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _EmiPlanRoute(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ===========================================================
                  // Reports
                  // ===========================================================
                  MoreModuleCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Reports',
                    subtitle: 'View sales and business reports',
                    trailing: const _ComingSoonBadge(),
                  ),

                  const SizedBox(height: 12),

                  // ===========================================================
                  // Warranty
                  // ===========================================================
                  MoreModuleCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Warranty',
                    subtitle: 'Manage product warranties',
                    trailing: const _ComingSoonBadge(),
                  ),

                  const SizedBox(height: 12),

                  // ===========================================================
                  // Repairs
                  // ===========================================================
                  MoreModuleCard(
                    icon: Icons.build_rounded,
                    title: 'Repairs',
                    subtitle: 'Manage repair jobs & service records',
                    trailing: const _ComingSoonBadge(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================================
            // Store
            // =================================================================
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: MoreSectionHeader(
                title: 'Store',
                subtitle: 'Manage your store and team',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  MoreModuleCard(
                    icon: Icons.badge_rounded,
                    title: 'Employees',
                    subtitle: 'Manage store staff and access',
                    trailing: const _ComingSoonBadge(),
                  ),

                  const SizedBox(height: 12),

                  MoreModuleCard(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'Manage store and application settings',
                    trailing: const _ComingSoonBadge(),
                  ),
                ],
              ),
            ),

            // =================================================================
            // Bottom spacing
            // =================================================================
            const SizedBox(height: 110),
          ],
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

    _controller = EmiController(
      repository: EmiRepositoryImpl(),
    );
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

  void _onCreateEmiPlan() {
    // TODO:
    // Navigate to Create EMI Plan screen.
  }

  void _onPlanTap(String emiPlanId) {
    // TODO:
    // Navigate to EMI Plan Details screen.
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
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