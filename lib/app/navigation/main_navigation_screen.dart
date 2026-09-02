import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';

import 'package:storemate/features/billing/presentation/screens/billing_screen.dart';
import 'package:storemate/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:storemate/features/customers/presentation/screens/customers_screen.dart';
import 'package:storemate/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:storemate/features/emi/data/models/emi_installment_model.dart';
import 'package:storemate/features/emi/data/models/emi_plan_model.dart';
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
import 'package:storemate/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:storemate/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:storemate/features/more/presentation/screens/more_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() {
    return _MainNavigationScreenState();
  }
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardScreen(
        onViewAllBilling: () {
          _onDestinationSelected(2);
        },

        onOpenAddProduct: _openAddProduct,
        onOpenAddCustomer: _openAddCustomer,

       onOpenEmiPlans: _openEmiPlans,
      ),
      const InventoryScreen(),
      const BillingScreen(),
      const CustomersScreen(),
      const MoreScreen(),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openAddProduct() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddProductScreen()));
  }

  void _openAddCustomer() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
  }

  void _openEmiPlans() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const _EmiPlanRoute(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(index: _selectedIndex, children: _screens),

      floatingActionButton: _QuickBillButton(
        onPressed: () {
          // TODO:
          // Open QuickBillScreen
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: _StoreMateBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// StoreMate Custom Bottom Navigation Bar
// -----------------------------------------------------------------------------

class _StoreMateBottomNavigationBar extends StatelessWidget {
  const _StoreMateBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 78,
          child: Row(
            children: [
              Expanded(
                child: _NavigationItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    onDestinationSelected(0);
                  },
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    onDestinationSelected(1);
                  },
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long_rounded,
                  label: 'Billing',
                  isSelected: selectedIndex == 2,
                  onTap: () {
                    onDestinationSelected(2);
                  },
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.people_outline_rounded,
                  selectedIcon: Icons.people_rounded,
                  label: 'Customers',
                  isSelected: selectedIndex == 3,
                  onTap: () {
                    onDestinationSelected(3);
                  },
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: 'More',
                  isSelected: selectedIndex == 4,
                  onTap: () {
                    onDestinationSelected(4);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Normal Navigation Item
// -----------------------------------------------------------------------------

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itemColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 48,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 23,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: itemColor,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Center Quick Bill Button
// -----------------------------------------------------------------------------

class _QuickBillButton extends StatelessWidget {
  const _QuickBillButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Icon(Icons.add_rounded),
            ),
          ),
        ),

        //const SizedBox(height: 3),

        // Text(
        //   'Quick Bill',
        //   style: theme.textTheme.labelSmall?.copyWith(
        //     color: colorScheme.onSurfaceVariant,
        //     fontSize: 10.5,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
      ],
    );
  }
}


// =============================================================================
// EMI Plan Route
// =============================================================================

class _EmiPlanRoute extends StatefulWidget {
  const _EmiPlanRoute();

  @override
  State<_EmiPlanRoute> createState() {
    return _EmiPlanRouteState();
  }
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

  // ===========================================================================
  // Create EMI Plan
  // ===========================================================================

  Future<void> _onCreateEmiPlan() async {
    final selectedInvoice = await Navigator.of(context).push<InvoiceModel>(
      MaterialPageRoute(
        builder: (_) => const SelectInvoiceForEmiScreen(),
      ),
    );

    if (!mounted || selectedInvoice == null) {
      return;
    }

    final createdPlan = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CreateEmiPlanController(
            service: EmiService(
              repository: EmiRepositoryImpl(),
            ),
          ),
          child: CreateEmiPlanScreen(
            invoice: selectedInvoice,
          ),
        ),
      ),
    );

    if (!mounted || createdPlan == null) {
      return;
    }

    await _controller.loadEmiPlans();
  }

  // ===========================================================================
  // EMI Plan Details
  // ===========================================================================

  Future<void> _onPlanTap(String emiPlanId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmiPlanDetailsScreen(
          controller: _controller,
          emiPlanId: emiPlanId,
          onRecordPayment: (emiPlanId, emiPlan, installment) async {
            await _onRecordPayment(
              emiPlanId,
              emiPlan,
              installment,
            );
          },
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _controller.loadEmiPlans();
  }

  // ===========================================================================
  // Record EMI Payment
  // ===========================================================================

  Future<void> _onRecordPayment(
    String emiPlanId,
    EmiPlanModel emiPlan,
    EmiInstallmentModel installment,
  ) async {
    final payment = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RecordEmiPaymentController(
            service: EmiService(
              repository: EmiRepositoryImpl(),
            ),
          ),
          child: RecordEmiPaymentScreen(
            emiPlanId: emiPlanId,
            emiPlan: emiPlan,
            installment: installment,
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