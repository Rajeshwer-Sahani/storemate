import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_search_field.dart';

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

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

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
    if (!mounted) return;

    setState(() {});
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
      final status = plan.status.toString().toLowerCase();
      final interestType = plan.interestType.toString().toLowerCase();
      final tenure = plan.tenureMonths.toString();

      return status.contains(_searchQuery) ||
          interestType.contains(_searchQuery) ||
          tenure.contains(_searchQuery);
    }).toList();
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  int get _totalPlans => widget.controller.emiPlans.length;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // FIXED HEADER
            // ================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _buildHeader(context),
            ),

            // ================================================================
            // SCROLLABLE CONTENT
            // ================================================================
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _dismissKeyboard,
                child: RefreshIndicator.adaptive(
                  onRefresh: _refresh,
                  displacement: 24,
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
                    children: [
                      // ========================================================
                      // Error
                      // ========================================================
                      if (controller.hasError) ...[
                        _buildErrorState(context),
                        const SizedBox(height: 12),
                      ],

                      // ========================================================
                      // Loading
                      // ========================================================
                      if (controller.isLoading &&
                          controller.emiPlans.isEmpty) ...[
                        const SizedBox(height: 24),
                        const SizedBox(
                          height: 320,
                          child: EmiLoadingWidget(
                            message: 'Loading EMI plans...',
                          ),
                        ),
                      ]
                      // ========================================================
                      // Empty State
                      // ========================================================
                      else if (!controller.isLoading &&
                          controller.emiPlans.isEmpty) ...[
                        _buildStatistics(context),

                        const SizedBox(height: 20),

                        _buildSearchField(context),

                        const SizedBox(height: 26),

                        _buildPlansHeader(context),

                        const SizedBox(height: 12),

                        SizedBox(
                          height: 420,
                          child: EmiEmptyState(
                            onCreateEmiPlan: widget.onCreateEmiPlan,
                            onRefresh: _refresh,
                          ),
                        ),
                      ]
                      // ========================================================
                      // EMI PLAN CONTENT
                      // ========================================================
                      else ...[
                        _buildStatistics(context),

                        const SizedBox(height: 20),

                        AppSearchField(
                          controller: _searchController,
                          hintText:
                              'Search by status, interest type or tenure...',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            letterSpacing: -0.3,
                          ),
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 26),

                        _buildPlansHeader(context),

                        const SizedBox(height: 12),

                        if (_filteredPlans.isEmpty)
                          SizedBox(
                            height: 300,
                            child: _buildSearchEmptyState(context),
                          )
                        else
                          ..._buildPlanCards(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---------------------------------------------------------------------
        // Back Button
        // ---------------------------------------------------------------------
        SizedBox(
          width: 42,
          height: 42,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 24,
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
                'EMI Plans',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 20,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage customer installment plans',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ---------------------------------------------------------------------
        // Create Button
        // ---------------------------------------------------------------------
        FilledButton.icon(
          onPressed: widget.onCreateEmiPlan,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    const totalPlansColor = Color(0xFF2563EB);
    const activeColor = Color(0xFF16A34A);
    const financedColor = Color(0xFF7C3AED);
    const outstandingColor = Color(0xFFDC2626);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            fontSize: 19,
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
                color: totalPlansColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatisticCard(
                icon: Icons.autorenew_rounded,
                label: 'Active',
                value: _activePlans.toString(),
                color: activeColor,
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
                color: financedColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatisticCard(
                icon: Icons.pending_actions_rounded,
                label: 'Outstanding',
                value: _formatCurrency(_totalOutstanding),
                color: outstandingColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // Search
  // ===========================================================================

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by status, interest type or tenure...',
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: const Icon(Icons.search_rounded, size: 23),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear_rounded, size: 21),
                tooltip: 'Clear search',
              ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.40),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  // ===========================================================================
  // Plans Header
  // ===========================================================================

  Widget _buildPlansHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'All EMI Plans',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              fontSize: 19,
            ),
          ),
        ),

        Text(
          '${_filteredPlans.length} ${_filteredPlans.length == 1 ? 'plan' : 'plans'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Plan Cards
  // ===========================================================================

  List<Widget> _buildPlanCards() {
    return [
      for (int index = 0; index < _filteredPlans.length; index++) ...[
        EmiPlanCard(
          plan: _filteredPlans[index],
          onTap: widget.onPlanTap == null
              ? null
              : () => widget.onPlanTap!(_filteredPlans[index].id),
        ),
        if (index != _filteredPlans.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  // ===========================================================================
  // Search Empty State
  // ===========================================================================

  Widget _buildSearchEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No matching EMI plans',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Try a different search term or clear the search.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.20)),
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
    );
  }

  // ===========================================================================
  // Currency Formatting
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
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: label == 'Active' || label == 'Outstanding'
                        ? color
                        : colorScheme.onSurface,
                    letterSpacing: -0.3,
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
