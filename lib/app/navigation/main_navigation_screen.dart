import 'package:flutter/material.dart';

import 'package:storemate/features/billing/presentation/screens/billing_screen.dart';
import 'package:storemate/features/customers/presentation/screens/customers_screen.dart';
import 'package:storemate/features/dashboard/presentation/screens/dashboard_screen.dart';
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
