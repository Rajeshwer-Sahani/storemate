import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storemate/features/billing/presentation/screens/invoice_details_screen.dart';

import 'package:storemate/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:storemate/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:storemate/features/dashboard/data/services/dashboard_service.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onViewAllBilling,
    this.onOpenAddProduct,
    this.onOpenAddCustomer,
    this.onOpenEmiPlans,
    this.onOpenProfile,
  });

  final VoidCallback? onViewAllBilling;
  final VoidCallback? onOpenAddProduct;
  final VoidCallback? onOpenAddCustomer;
  final VoidCallback? onOpenEmiPlans;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(
        service: DashboardService(repository: DashboardRepositoryImpl()),
      )..loadDashboard(),
      child: _DashboardView(
        onViewAllBilling: onViewAllBilling,
        onOpenAddProduct: onOpenAddProduct,
        onOpenAddCustomer: onOpenAddCustomer,
        onOpenEmiPlans: onOpenEmiPlans,
        onOpenProfile: onOpenProfile,
      ),
    );
  }
}

// =============================================================================
// Dashboard View
// =============================================================================

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    this.onViewAllBilling,
    this.onOpenAddProduct,
    this.onOpenAddCustomer,
    this.onOpenEmiPlans,
    this.onOpenProfile,
  });

  final VoidCallback? onViewAllBilling;
  final VoidCallback? onOpenAddProduct;
  final VoidCallback? onOpenAddCustomer;
  final VoidCallback? onOpenEmiPlans;
  final VoidCallback? onOpenProfile;

  Future<void> _openInvoiceDetails(
    BuildContext context,
    String invoiceId,
  ) async {
    final provider = context.read<DashboardProvider>();

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InvoiceDetailsScreen(invoiceId: invoiceId),
      ),
    );

    if (!context.mounted) return;

    if (updated == true) {
      await provider.refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // -------------------------------------------------------------------------
    // Loading
    // -------------------------------------------------------------------------

    if (provider.isLoading && !provider.hasData) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    // -------------------------------------------------------------------------
    // Error without existing data
    // -------------------------------------------------------------------------

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
                    'Unable to load dashboard',
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
                    onPressed: provider.loadDashboard,
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

    final data = provider.dashboardData;

    if (data == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('No dashboard data available.')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------------------------------------------------------------
            // Fixed Dashboard Header
            // ---------------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: _DashboardHeader(
                storeName: data.storeName,
                onOpenProfile: onOpenProfile,
              ),
            ),

            // ---------------------------------------------------------------------
            // Scrollable Dashboard Content
            // ---------------------------------------------------------------------
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.refreshDashboard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // -------------------------------------------------------
                          // Today's Sales
                          // -------------------------------------------------------
                          _SalesOverviewCard(
                            todaySales: data.todaySales,
                            todayBillCount: data.todayBillCount,
                            yesterdaySales: data.yesterdaySales,
                          ),

                          const SizedBox(height: 28),

                          // -------------------------------------------------------
                          // Business Overview
                          // -------------------------------------------------------
                          const _SectionHeader(
                            title: 'Business Overview',
                            subtitle: 'Your store at a glance',
                          ),

                          const SizedBox(height: 14),

                          _BusinessOverviewGrid(
                            customerCount: data.customerCount,
                            productCount: data.productCount,
                            lowStockCount: data.lowStockCount,
                            outstandingDueAmount: data.outstandingDueAmount,
                          ),

                          const SizedBox(height: 28),

                          // -------------------------------------------------------
                          // Quick Actions
                          // -------------------------------------------------------
                          const _SectionHeader(
                            title: 'Quick Actions',
                            subtitle: 'Manage your store faster',
                          ),

                          const SizedBox(height: 14),

                          _QuickActionsGrid(
                            onOpenAddProduct: onOpenAddProduct,
                            onOpenAddCustomer: onOpenAddCustomer,
                            onOpenEmiPlans: onOpenEmiPlans,
                          ),

                          const SizedBox(height: 28),

                          // -------------------------------------------------------
                          // Recent Sales
                          // -------------------------------------------------------
                          _SectionHeader(
                            title: 'Recent Sales',
                            subtitle: 'Your latest billing activity',
                            actionLabel: 'View all',
                            onActionPressed: onViewAllBilling,
                          ),

                          const SizedBox(height: 14),

                          if (data.recentSales.isEmpty)
                            const _RecentSalesEmptyCard()
                          else ...[
                            _RecentSalesList(
                              sales: data.recentSales,
                              onInvoiceTap: (invoiceId) {
                                _openInvoiceDetails(context, invoiceId);
                              },
                            ),

                            const SizedBox(height: 6),

                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Showing the 5 most recent sales',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // -------------------------------------------------------
                          // Inventory Alerts
                          // -------------------------------------------------------
                          const _SectionHeader(
                            title: 'Inventory Alerts',
                            subtitle: 'Products requiring attention',
                          ),

                          const SizedBox(height: 14),

                          if (data.inventoryAlerts.isEmpty)
                            const _InventoryStatusCard()
                          else
                            _InventoryAlertsCard(alerts: data.inventoryAlerts),
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
}

// =============================================================================
// Dashboard Header
// =============================================================================

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.storeName, this.onOpenProfile});

  final String storeName;
  final VoidCallback? onOpenProfile;

  String _getGreeting() {
    final currentHour = DateTime.now().hour;

    if (currentHour < 12) {
      return 'Good morning 👋';
    }

    if (currentHour < 17) {
      return 'Good afternoon 👋';
    }

    return 'Good evening 👋';
  }

  String _getStoreInitials() {
    final words = storeName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return 'SM';
    }

    if (words.length == 1) {
      final word = words.first;

      if (word.length == 1) {
        return word.toUpperCase();
      }

      return word.substring(0, 2).toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        _HeaderActionButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onPressed: () {
            // Notification screen will be added later.
          },
        ),

        const SizedBox(width: 10),

        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onOpenProfile,
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  _getStoreInitials(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Today's Sales
// =============================================================================

// =============================================================================
// Today's Sales
// =============================================================================

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard({
    required this.todaySales,
    required this.todayBillCount,
    required this.yesterdaySales,
  });

  final double todaySales;
  final int todayBillCount;
  final double yesterdaySales;

  String _formatAmount(double amount) {
    final rounded = amount.round();

    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return '₹${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasSales = todaySales > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Header
          // -------------------------------------------------------------------
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: colorScheme.onPrimary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  "Today's Sales",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Today',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // Main Sales Amount
          // -------------------------------------------------------------------
          Text(
            _formatAmount(todaySales),
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            hasSales ? 'Net sales after returns' : 'No sales recorded today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // Divider
          // -------------------------------------------------------------------
          Divider(
            color: colorScheme.onPrimary.withValues(alpha: 0.18),
            height: 1,
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------------------
          // Supporting Metrics
          // -------------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _SalesMetric(
                  icon: Icons.receipt_long_outlined,
                  value: todayBillCount.toString(),
                  label: 'Bills Today',
                ),
              ),

              _SalesMetricDivider(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: _SalesMetric(
                    icon: Icons.compare_arrows_rounded,
                    value: _formatAmount(yesterdaySales),
                    label: 'Yesterday',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Sales Metric Divider
// =============================================================================

class _SalesMetricDivider extends StatelessWidget {
  const _SalesMetricDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 58,
      color: colorScheme.onPrimary.withValues(alpha: 0.16),
    );
  }
}

// =============================================================================
// Sales Metric
// =============================================================================

class _SalesMetric extends StatelessWidget {
  const _SalesMetric({
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

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: colorScheme.onPrimary.withValues(alpha: 0.88),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w500,
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
// Section Header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        if (actionLabel != null)
          TextButton(onPressed: onActionPressed, child: Text(actionLabel!)),
      ],
    );
  }
}

// =============================================================================
// Business Overview
// =============================================================================

class _BusinessOverviewGrid extends StatelessWidget {
  const _BusinessOverviewGrid({
    required this.customerCount,
    required this.productCount,
    required this.lowStockCount,
    required this.outstandingDueAmount,
  });

  final int customerCount;
  final int productCount;
  final int lowStockCount;
  final double outstandingDueAmount;

  String _formatAmount(double amount) {
    final rounded = amount.round();

    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return '₹${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      children: [
        _OverviewCard(
          title: 'Customers',
          value: customerCount.toString(),
          icon: Icons.people_outline_rounded,
        ),

        _OverviewCard(
          title: 'Products',
          value: productCount.toString(),
          icon: Icons.inventory_2_outlined,
        ),

        _OverviewCard(
          title: 'Low Stock',
          value: lowStockCount.toString(),
          icon: Icons.warning_amber_rounded,
          isWarning: lowStockCount > 0,
        ),

        _OverviewCard(
          title: 'Outstanding Dues',
          value: _formatAmount(outstandingDueAmount),
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accentColor = isWarning ? colorScheme.error : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 21),
          ),

          const Spacer(),

          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

// =============================================================================
// Quick Actions
// =============================================================================

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    this.onOpenAddProduct,
    this.onOpenAddCustomer,
    this.onOpenEmiPlans,
  });

  final VoidCallback? onOpenAddProduct;
  final VoidCallback? onOpenAddCustomer;
  final VoidCallback? onOpenEmiPlans;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_card_rounded,
            label: 'New Bill',
            onTap: () {
              // Billing navigation will be connected later.
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box_outlined,
            label: 'Product',
            onTap: onOpenAddProduct,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Customer',
            onTap: onOpenAddCustomer,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.payments_outlined,
            label: 'EMI',
            onTap: onOpenEmiPlans,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
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
// Recent Sales
// =============================================================================

class _RecentSalesList extends StatelessWidget {
  const _RecentSalesList({required this.sales, required this.onInvoiceTap});

  final List<DashboardRecentSaleModel> sales;
  final ValueChanged<String> onInvoiceTap;

  String _formatAmount(double amount) {
    final rounded = amount.round();

    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return '₹${buffer.toString()}';
  }

  String _formatPaymentMethod(String method) {
    final normalized = method.trim().toLowerCase();

    if (normalized == 'upi') return 'UPI';
    if (normalized == 'cash') return 'Cash';
    if (normalized == 'card') return 'Card';

    if (normalized.isEmpty) {
      return '';
    }

    return method.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: sales.map((sale) {
        final paymentMethod = _formatPaymentMethod(sale.paymentMethod);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => onInvoiceTap(sale.id),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: colorScheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            sale.invoiceNumber,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          if (paymentMethod.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              paymentMethod,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      _formatAmount(sale.netAmount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecentSalesEmptyCard extends StatelessWidget {
  const _RecentSalesEmptyCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 29,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            'No sales recorded yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your latest bills and transactions will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Inventory Alerts
// =============================================================================

class _InventoryAlertsCard extends StatelessWidget {
  const _InventoryAlertsCard({required this.alerts});

  final List<DashboardInventoryAlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: alerts.take(5).map((product) {
        final isOutOfStock = product.isOutOfStock;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isOutOfStock
                      ? Icons.remove_shopping_cart_outlined
                      : Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isOutOfStock
                          ? 'Out of stock'
                          : '${product.stockQuantity} left • Threshold ${product.lowStockThreshold}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InventoryStatusCard extends StatelessWidget {
  const _InventoryStatusCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: colorScheme.onTertiaryContainer,
              size: 25,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your inventory is looking good',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'No low-stock products require attention.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
