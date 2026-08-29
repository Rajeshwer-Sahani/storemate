import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/emi_installment_model.dart';
import '../../data/models/emi_payment_model.dart';
import '../../data/models/emi_plan_model.dart';
import '../controllers/emi_controller.dart';
import '../widgets/emi_installment_card.dart';
import '../widgets/emi_loading_widget.dart';
import '../widgets/emi_payment_history_card.dart';
import '../widgets/emi_status_badge.dart';
import '../widgets/emi_summary_card.dart';

class EmiPlanDetailsScreen extends StatefulWidget {
  const EmiPlanDetailsScreen({
    super.key,
    required this.controller,
    required this.emiPlanId,
    this.onRecordPayment,
  });

  final EmiController controller;

  final String emiPlanId;

  /// Opens the Record EMI Payment screen.
  ///
  /// The actual payment operation remains inside
  /// RecordEmiPaymentScreen / RecordEmiPaymentController.
  ///
  /// The current outstanding amount is supplied so the payment screen
  /// can validate the entered amount against the displayed balance.
  final Future<void> Function(
    String emiPlanId,
    EmiPlanModel emiPlan,
    EmiInstallmentModel installment,
  )?
  onRecordPayment;

  @override
  State<EmiPlanDetailsScreen> createState() => _EmiPlanDetailsScreenState();
}

class _EmiPlanDetailsScreenState extends State<EmiPlanDetailsScreen> {
  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadDetails();
    });
  }

  // ===========================================================================
  // Data
  // ===========================================================================

  Future<void> _loadDetails() async {
    await widget.controller.loadEmiPlanDetails(widget.emiPlanId);
  }

  Future<void> _refresh() async {
    await widget.controller.refreshEmiPlan(widget.emiPlanId);
  }

  // ===========================================================================
  // Navigation
  // ===========================================================================

  Future<void> _handleRecordPayment(EmiInstallmentModel installment) async {
    final callback = widget.onRecordPayment;
    final plan = widget.controller.selectedPlan;

    if (callback == null || plan == null) {
      return;
    }

    if (plan.isCompleted || plan.isCancelled) {
      return;
    }

    final status = installment.status.toLowerCase();

    final isCancelled = status == 'cancelled' || status == 'canceled';

    if (isCancelled) {
      return;
    }

    if (installment.remainingAmount <= 0.01) {
      return;
    }

    await callback(widget.emiPlanId, plan, installment);

    if (!mounted) {
      return;
    }

    await _refresh();
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        return Scaffold(
          appBar: AppBar(
            title: const Text('EMI Plan Details'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: controller.isLoadingDetails ? null : _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  // ===========================================================================
  // Body
  // ===========================================================================

  Widget _buildBody(BuildContext context) {
    final controller = widget.controller;

    // -------------------------------------------------------------------------
    // Initial Loading
    // -------------------------------------------------------------------------

    if (controller.isLoadingDetails && controller.selectedPlan == null) {
      return const EmiLoadingWidget(message: 'Loading EMI plan...');
    }

    // -------------------------------------------------------------------------
    // Error
    // -------------------------------------------------------------------------

    if (controller.hasError && controller.selectedPlan == null) {
      return _buildErrorState(context);
    }

    // -------------------------------------------------------------------------
    // No Plan
    // -------------------------------------------------------------------------

    final plan = controller.selectedPlan;

    if (plan == null) {
      return _buildNotFoundState(context);
    }

    // -------------------------------------------------------------------------
    // Content
    // -------------------------------------------------------------------------

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPlanHeader(context, plan),

                const SizedBox(height: 16),

                _buildSummaryCard(context, plan),

                const SizedBox(height: 24),

                _buildNextDueSection(context, plan),

                const SizedBox(height: 24),

                _buildInstallmentsSection(context, controller.installments),

                const SizedBox(height: 24),

                _buildPaymentsSection(context, controller.payments),

                if (controller.hasError) ...[
                  const SizedBox(height: 16),
                  _buildInlineError(context, controller.errorMessage!),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Plan Header
  // ===========================================================================

  Widget _buildPlanHeader(BuildContext context, EmiPlanModel plan) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================================================================
          // Primary Plan Information
          // ===================================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMI Plan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Plan ID: ${_shortId(plan.id)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Status
              EmiStatusBadge(status: plan.status),
            ],
          ),

          const SizedBox(height: 18),

          // ===================================================================
          // Divider
          // ===================================================================
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: .45),
          ),

          const SizedBox(height: 18),

          // ===================================================================
          // Plan Metadata
          // ===================================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------------------
              // Start Date
              // -----------------------------------------------------------------
              Expanded(
                child: _PlanHeaderInfo(
                  icon: Icons.calendar_month_outlined,
                  label: 'Start Date',
                  value: _formatDate(plan.startDate),
                  
                ),
              ),

              _PlanHeaderDivider(),

              // -----------------------------------------------------------------
              // First Due Date
              // -----------------------------------------------------------------
              Expanded(
                child: _PlanHeaderInfo(
                  icon: Icons.event_available_rounded,
                  label: 'First Due',
                  value: _formatDate(plan.firstDueDate),
                ),
              ),

              _PlanHeaderDivider(),

              // -----------------------------------------------------------------
              // Interest
              // -----------------------------------------------------------------
              Expanded(
                child: _PlanHeaderInfo(
                  icon: Icons.percent_rounded,
                  label: 'Interest',
                  value:
                      '${plan.interestRate.toStringAsFixed(2)}% ${_interestTypeLabel(plan.interestType)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _interestTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'flat':
        return 'Flat';

      case 'reducing':
      case 'reducing_balance':
        return 'Reducing';

      case 'none':
        return 'No Interest';

      default:
        return type;
    }
  }

  // ===========================================================================
  // Summary
  // ===========================================================================

  Widget _buildSummaryCard(BuildContext context, EmiPlanModel plan) {
    final installments = widget.controller.installments;

    final totalInstallments = installments.isNotEmpty
        ? installments.length
        : plan.tenureMonths;

    final paidInstallments = installments
        .where((installment) => installment.remainingAmount <= 0.01)
        .length;

    final monthlyEmi = installments.isNotEmpty
        ? installments.first.scheduledAmount
        : plan.tenureMonths > 0
        ? plan.totalPayableAmount / plan.tenureMonths
        : 0.0;

    return EmiSummaryCard(
      totalPayable: plan.totalPayableAmount,
      paidAmount: plan.paidAmount,
      monthlyEmi: monthlyEmi,
      paidInstallments: paidInstallments,
      totalInstallments: totalInstallments,
      status: plan.status,
    );
  }

  // ===========================================================================
  // Next Due
  // ===========================================================================

  Widget _buildNextDueSection(BuildContext context, EmiPlanModel plan) {
    final colorScheme = Theme.of(context).colorScheme;

    final nextInstallment = _getNextInstallment();

    if (nextInstallment == null) {
      return _buildInfoCard(
        context,
        icon: Icons.check_circle_rounded,
        title: 'No pending installment',
        message: plan.isCompleted
            ? 'This EMI plan has been completely paid.'
            : 'There is currently no pending installment.',
        color: colorScheme.tertiary,
      );
    }

    final dueDate = nextInstallment.dueDate.toLocal();

    final normalizedStatus = nextInstallment.status.trim().toLowerCase();

    final isOverdue =
        nextInstallment.remainingAmount > 0.01 &&
        dueDate.isBefore(DateTime.now());

    final isPartiallyPaid =
        normalizedStatus == 'partially_paid' ||
        normalizedStatus == 'partially paid';

    final isPending =
        normalizedStatus == 'pending' ||
        normalizedStatus == 'upcoming' ||
        normalizedStatus == 'due';

    // ---------------------------------------------------------------------------
    // Next Due semantic color
    // ---------------------------------------------------------------------------
    final color = isOverdue
        ? colorScheme.error
        : isPartiallyPaid
        ? Colors.amber.shade700
        : isPending
        ? colorScheme.error
        : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          title: 'Next Due',
          icon: Icons.event_available_rounded,
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Installment #${nextInstallment.installmentNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  EmiStatusBadge(status: nextInstallment.status),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.calendar_month_rounded,
                    size: 19,
                    color: isOverdue ? colorScheme.error : colorScheme.primary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    _formatDate(dueDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                '₹${nextInstallment.remainingAmount.toStringAsFixed(2)} remaining',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _handleRecordPayment(nextInstallment),
                  icon: const Icon(Icons.payments_rounded),
                  label: const Text('Record Payment'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Installments
  // ===========================================================================

  Widget _buildInstallmentsSection(
    BuildContext context,
    List<EmiInstallmentModel> installments,
  ) {
    final nextInstallment = _getNextInstallment();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          title: 'Installment Schedule',
          icon: Icons.calendar_view_month_rounded,
          trailing: installments.isNotEmpty
              ? _buildCountBadge(context, installments.length)
              : null,
        ),

        const SizedBox(height: 12),

        if (installments.isEmpty)
          _buildSectionEmptyState(
            context,
            icon: Icons.event_busy_rounded,
            message: 'No installment schedule is available.',
          )
        else
          ...installments.map((installment) {
            final isNextInstallment =
                nextInstallment?.installmentNumber ==
                installment.installmentNumber;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EmiInstallmentCard(
                installment: installment,
                onTap: isNextInstallment
                    ? () => _handleRecordPayment(installment)
                    : null,
              ),
            );
          }),
      ],
    );
  }

  // ===========================================================================
  // Payments
  // ===========================================================================

  Widget _buildPaymentsSection(
    BuildContext context,
    List<EmiPaymentModel> payments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          title: 'Payment History',
          icon: Icons.receipt_long_rounded,
          trailing: payments.isNotEmpty
              ? _buildCountBadge(context, payments.length)
              : null,
        ),

        const SizedBox(height: 12),

        if (payments.isEmpty)
          _buildSectionEmptyState(
            context,
            icon: Icons.payments_outlined,
            message: 'No EMI payments have been recorded yet.',
          )
        else
          ...payments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == payments.length - 1 ? 0 : 12,
              ),
              child: EmiPaymentHistoryCard(
                payment: payment,
                paymentNumber: payments.length - index,
              ),
            );
          }),
      ],
    );
  }

  // ===========================================================================
  // Section Title
  // ===========================================================================

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        if (trailing != null) trailing,
      ],
    );
  }

  // ===========================================================================
  // Count Badge
  // ===========================================================================

  Widget _buildCountBadge(BuildContext context, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ===========================================================================
  // Info Card
  // ===========================================================================

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
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
  }

  // ===========================================================================
  // Empty State
  // ===========================================================================

  Widget _buildSectionEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: colorScheme.onSurfaceVariant),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Error State
  // ===========================================================================

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load EMI plan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.controller.errorMessage ??
                  'Something went wrong while loading the EMI plan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _loadDetails,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Inline Error
  // ===========================================================================

  Widget _buildInlineError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Not Found
  // ===========================================================================

  Widget _buildNotFoundState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 42,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'EMI plan not found',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'The requested EMI plan could not be found.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  EmiInstallmentModel? _getNextInstallment() {
    final installments = widget.controller.installments;

    if (installments.isEmpty) {
      return null;
    }

    final pending = installments.where((installment) {
      final status = installment.status.toLowerCase();

      final isCancelled = status == 'cancelled' || status == 'canceled';

      return installment.remainingAmount > 0.01 && !isCancelled;
    }).toList();

    if (pending.isEmpty) {
      return null;
    }

    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return pending.first;
  }

  String _shortId(String id) {
    if (id.length <= 12) {
      return id;
    }

    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }
}

// =============================================================================
// Plan Header Info
// =============================================================================

class _PlanHeaderInfo extends StatelessWidget {
  const _PlanHeaderInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.tertiary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.04
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.05
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Plan Header Divider
// =============================================================================

class _PlanHeaderDivider extends StatelessWidget {
  const _PlanHeaderDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: colorScheme.outlineVariant.withValues(alpha: .45),
    );
  }
}
