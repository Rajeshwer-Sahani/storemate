import 'package:flutter/material.dart';

import '../controllers/emi_controller.dart';
import '../widgets/emi_empty_state.dart';
import '../widgets/emi_loading_widget.dart';
import '../widgets/emi_plan_card.dart';

class EmiPlanListScreen extends StatefulWidget {
  const EmiPlanListScreen({
    super.key,
    required this.controller,
    required this.onCreateEmiPlan,
    this.onPlanTap,
  });

  final EmiController controller;

  /// Opens the Create EMI Plan screen.
  final VoidCallback onCreateEmiPlan;

  /// Opens the selected EMI Plan Details screen.
  final ValueChanged<String>? onPlanTap;

  @override
  State<EmiPlanListScreen> createState() => _EmiPlanListScreenState();
}

class _EmiPlanListScreenState extends State<EmiPlanListScreen> {
  late final TextEditingController _searchController;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    widget.controller.addListener(_onControllerChanged);

    _loadInitialData();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Data
  // ===========================================================================

  Future<void> _loadInitialData() async {
    await widget.controller.loadEmiPlans();
  }

  Future<void> _refresh() async {
    await widget.controller.refreshEmiPlans();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ===========================================================================
  // Search
  // ===========================================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  List<dynamic> get _filteredPlans {
    final plans = widget.controller.emiPlans;

    if (_searchQuery.isEmpty) {
      return plans;
    }

    return plans.where((plan) {
      final status = plan.status.toLowerCase();
      final interestType = plan.interestType.toLowerCase();
      final tenure = plan.tenureMonths.toString();

      return status.contains(_searchQuery) ||
          interestType.contains(_searchQuery) ||
          tenure.contains(_searchQuery);
    }).toList();
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  int get _totalPlans {
    return widget.controller.emiPlans.length;
  }

  int get _activePlans {
    return widget.controller.emiPlans.where((plan) => plan.isActive).length;
  }

  double get _totalFinanced {
    return widget.controller.emiPlans.fold(
      0.0,
      (sum, plan) => sum + plan.financedAmount,
    );
  }

  double get _totalOutstanding {
    return widget.controller.emiPlans.fold(
      0.0,
      (sum, plan) => sum + plan.remainingAmount,
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // =================================================================
              // Header
              // =================================================================
              SliverToBoxAdapter(child: _buildHeader(context)),

              // =================================================================
              // Error
              // =================================================================
              if (controller.hasError)
                SliverToBoxAdapter(child: _buildErrorState(context)),

              // =================================================================
              // Loading
              // =================================================================
              if (controller.isLoading && controller.emiPlans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmiLoadingWidget(message: 'Loading EMI plans...'),
                )
              // =================================================================
              // Initial Empty State
              // =================================================================
              else if (!controller.isLoading && controller.emiPlans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmiEmptyState(
                    onCreateEmiPlan: widget.onCreateEmiPlan,
                    onRefresh: _refresh,
                  ),
                )
              // =================================================================
              // Content
              // =================================================================
              else ...[
                SliverToBoxAdapter(child: _buildStatistics(context)),

                SliverToBoxAdapter(child: _buildSearchField(context)),

                if (_filteredPlans.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildSearchEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    sliver: SliverList.separated(
                      itemCount: _filteredPlans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final plan = _filteredPlans[index];

                        return EmiPlanCard(
                          plan: plan,
                          onTap: widget.onPlanTap == null
                              ? null
                              : () => widget.onPlanTap!(plan.id),
                        );
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMI Plans',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage customer installment plans',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          FilledButton.icon(
            onPressed: widget.onCreateEmiPlan,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  icon: Icons.description_outlined,
                  label: 'Total Plans',
                  value: _totalPlans.toString(),
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatisticCard(
                  icon: Icons.autorenew_rounded,
                  label: 'Active',
                  value: _activePlans.toString(),
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Financed',
                  value: _formatCurrency(_totalFinanced),
                  color: colorScheme.secondary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatisticCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Outstanding',
                  value: _formatCurrency(_totalOutstanding),
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Search
  // ===========================================================================

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by status, interest type or tenure...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded),
                  tooltip: 'Clear search',
                ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: .45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Search Empty State
  // ===========================================================================

  Widget _buildSearchEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 34,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'No matching EMI plans',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Try a different search term or clear the search.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Error State
  // ===========================================================================

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.error.withValues(alpha: .20)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colorScheme.error),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.controller.errorMessage ?? 'Something went wrong.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: widget.controller.clearError,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Formatting
  // ===========================================================================

  String _formatCurrency(double amount) {
    if (amount.abs() >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    }

    if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }
}

// =============================================================================
// Statistic Card
// =============================================================================

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: color),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
