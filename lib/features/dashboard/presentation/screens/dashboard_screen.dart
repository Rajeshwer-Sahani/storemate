import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() {
    return _DashboardScreenState();
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _storeName = 'Your Store';
  bool _isLoadingStore = true;

  @override
  void initState() {
    super.initState();

    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      // Get the currently logged-in StoreMate user.
      final currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        if (!mounted) return;

        setState(() {
          _isLoadingStore = false;
        });

        return;
      }

      // Fetch the store belonging to the logged-in owner.
      final storeData = await Supabase.instance.client
          .from('stores')
          .select('store_name')
          .eq('owner_id', currentUser.id)
          .maybeSingle();

      if (!mounted) return;

      final fetchedStoreName = storeData?['store_name']?.toString().trim();

      setState(() {
        if (fetchedStoreName != null && fetchedStoreName.isNotEmpty) {
          _storeName = fetchedStoreName;
        }

        _isLoadingStore = false;
      });
    } on PostgrestException catch (error) {
      debugPrint('Failed to fetch store details: ${error.message}');

      if (!mounted) return;

      setState(() {
        _isLoadingStore = false;
      });
    } catch (error) {
      debugPrint('Unexpected dashboard error: $error');

      if (!mounted) return;

      setState(() {
        _isLoadingStore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Dynamic Dashboard header
                  _DashboardHeader(
                    storeName: _storeName,
                    isLoading: _isLoadingStore,
                  ),

                  const SizedBox(height: 24),

                  // Today's sales card
                  const _SalesOverviewCard(),

                  const SizedBox(height: 28),

                  // Business overview title
                  const _SectionHeader(
                    title: 'Business Overview',
                    subtitle: 'Your store at a glance',
                  ),

                  const SizedBox(height: 14),

                  // Business statistics
                  const _BusinessOverviewGrid(),

                  const SizedBox(height: 28),

                  // Quick actions title
                  const _SectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Manage your store faster',
                  ),

                  const SizedBox(height: 14),

                  // Quick actions
                  const _QuickActionsGrid(),

                  const SizedBox(height: 28),

                  // Recent sales title
                  _SectionHeader(
                    title: 'Recent Sales',
                    subtitle: 'Your latest billing activity',
                    actionLabel: 'View all',
                    onActionPressed: () {
                      // Billing navigation will be added later.
                    },
                  ),

                  const SizedBox(height: 14),

                  // Recent sales empty state
                  const _RecentSalesEmptyCard(),

                  const SizedBox(height: 28),

                  // Inventory alert title
                  const _SectionHeader(
                    title: 'Inventory Alerts',
                    subtitle: 'Products requiring attention',
                  ),

                  const SizedBox(height: 14),

                  // Inventory status
                  const _InventoryStatusCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dashboard Header
// -----------------------------------------------------------------------------

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.storeName, required this.isLoading});

  final String storeName;
  final bool isLoading;

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
      final firstWord = words.first;

      if (firstWord.length == 1) {
        return firstWord.toUpperCase();
      }

      return firstWord.substring(0, 2).toUpperCase();
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

              if (isLoading)
                Container(
                  width: 160,
                  height: 25,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              else
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

        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(15),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: colorScheme.primary,
                  ),
                )
              : Text(
                  _getStoreInitials(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
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

// -----------------------------------------------------------------------------
// Today's Sales Card
// -----------------------------------------------------------------------------

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
                  horizontal: 11,
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

          const SizedBox(height: 24),

          Text(
            '₹0',
            style: theme.textTheme.displaySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'No sales recorded today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 22),

          Divider(
            color: colorScheme.onPrimary.withValues(alpha: 0.18),
            height: 1,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _SalesMetric(
                  icon: Icons.receipt_long_outlined,
                  value: '0',
                  label: 'Total bills',
                ),
              ),

              Container(
                width: 1,
                height: 38,
                color: colorScheme.onPrimary.withValues(alpha: 0.18),
              ),

              const Expanded(
                child: _SalesMetric(
                  icon: Icons.compare_arrows_rounded,
                  value: '₹0',
                  label: 'Yesterday',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        Icon(
          icon,
          size: 21,
          color: colorScheme.onPrimary.withValues(alpha: 0.82),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Section Header
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Business Overview
// -----------------------------------------------------------------------------

class _BusinessOverviewGrid extends StatelessWidget {
  const _BusinessOverviewGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      children: [
        _OverviewCard(
          title: 'Customers',
          value: '0',
          icon: Icons.people_outline_rounded,
        ),
        _OverviewCard(
          title: 'Products',
          value: '0',
          icon: Icons.inventory_2_outlined,
        ),
        _OverviewCard(
          title: 'Low Stock',
          value: '0',
          icon: Icons.warning_amber_rounded,
          isWarning: true,
        ),
        _OverviewCard(
          title: 'Pending EMI',
          value: '₹0',
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

// -----------------------------------------------------------------------------
// Quick Actions
// -----------------------------------------------------------------------------

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_card_rounded,
            label: 'New Bill',
            onTap: () {
              // Billing navigation will be added later.
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box_outlined,
            label: 'Product',
            onTap: () {
              // Add-product flow will be added later.
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Customer',
            onTap: () {
              // Add-customer flow will be added later.
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _QuickActionButton(
            icon: Icons.payments_outlined,
            label: 'EMI',
            onTap: () {
              // EMI flow will be added later.
            },
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
  final VoidCallback onTap;

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

// -----------------------------------------------------------------------------
// Recent Sales
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Inventory Status
// -----------------------------------------------------------------------------

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
