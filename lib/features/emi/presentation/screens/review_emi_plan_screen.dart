import 'package:flutter/material.dart';

import '../../data/requests/create_emi_plan_request.dart';

class ReviewEmiPlanScreen extends StatelessWidget {
  const ReviewEmiPlanScreen({
    super.key,
    required this.request,
    required this.financedAmount,
    this.invoiceNumber,
    this.customerName,
    required this.onConfirm,
  });

  // ===========================================================================
  // Inputs
  // ===========================================================================

  /// Configuration that will eventually be sent to create_emi_plan RPC.
  final CreateEmiPlanRequest request;

  /// Current invoice outstanding amount.
  ///
  /// This is the amount from invoice.due_amount and is used only for preview.
  /// PostgreSQL will recalculate the authoritative value during creation.
  final double financedAmount;

  /// Human-readable invoice number for display.
  final String? invoiceNumber;

  /// Customer name for display.
  final String? customerName;

  /// Called only after the user confirms the review.
  ///
  /// The actual database creation should be performed by the parent/controller.
  final VoidCallback onConfirm;

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final financialPreview = _calculateFinancialPreview();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Review EMI Plan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),

                    const SizedBox(height: 24),

                    _buildInvoiceSection(context),

                    const SizedBox(height: 20),

                    _buildEmiTermsSection(context),

                    const SizedBox(height: 20),

                    _buildFinancialSummary(context, financialPreview),

                    const SizedBox(height: 20),

                    _buildScheduleSection(context, financialPreview),

                    const SizedBox(height: 20),

                    _buildImportantNotice(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            _buildBottomAction(context),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review before creating',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please verify the EMI terms, charges, and payment schedule before confirming.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Invoice
  // ===========================================================================

  Widget _buildInvoiceSection(BuildContext context) {
    return _SectionCard(
      title: 'Invoice',
      icon: Icons.receipt_long_rounded,
      child: Column(
        children: [
          if (invoiceNumber != null)
            _InfoRow(label: 'Invoice', value: invoiceNumber!),

          if (invoiceNumber != null && customerName != null)
            const SizedBox(height: 14),

          if (customerName != null)
            _InfoRow(label: 'Customer', value: customerName!),

          if (invoiceNumber != null || customerName != null)
            const SizedBox(height: 14),

          _InfoRow(
            label: 'Outstanding Amount',
            value: _formatCurrency(financedAmount),
            valueWeight: FontWeight.w700,
            valueColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMI Terms
  // ===========================================================================

  Widget _buildEmiTermsSection(BuildContext context) {
    return _SectionCard(
      title: 'EMI Terms',
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: [
          _InfoRow(
            label: 'Frequency',
            value: _formatFrequency(request.frequency),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Tenure',
            value: '${request.tenureMonths} installments',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'First Due Date',
            value: _formatDate(request.firstDueDate),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Interest Rate',
            value: '${_formatNumber(request.interestRate)}%',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Processing Fee',
            value: _formatCurrency(request.processingFee),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Financial Summary
  // ===========================================================================

  Widget _buildFinancialSummary(
    BuildContext context,
    _FinancialPreview preview,
  ) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Financial Summary',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          _InfoRow(
            label: 'Financed Amount',
            value: _formatCurrency(preview.financedAmount),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Interest',
            value:
                '${_formatCurrency(preview.interestAmount)} '
                '(${_formatNumber(request.interestRate)}%)',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Processing Fee',
            value: _formatCurrency(preview.processingFee),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Total Payable',
            value: _formatCurrency(preview.totalPayableAmount),
            valueWeight: FontWeight.w800,
            valueSize: 21,
            valueColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Regular Installment',
            value: _formatCurrency(preview.installmentAmount),
            valueWeight: FontWeight.w700,
            valueSize: 17,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Installment Schedule
  // ===========================================================================

  Widget _buildScheduleSection(
    BuildContext context,
    _FinancialPreview preview,
  ) {
    return _SectionCard(
      title: 'Payment Schedule',
      icon: Icons.event_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${request.tenureMonths} monthly installments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          ...preview.installments.map(
            (installment) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InstallmentRow(
                number: installment.number,
                dueDate: installment.dueDate,
                amount: installment.amount,
                isFinal: installment.number == request.tenureMonths,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Divider(color: Theme.of(context).colorScheme.outlineVariant),

          const SizedBox(height: 14),

          _InfoRow(
            label: 'Schedule Total',
            value: _formatCurrency(preview.scheduleTotal),
            valueWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Notice
  // ===========================================================================

  Widget _buildImportantNotice(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The final EMI amounts are securely recalculated and validated by StoreMate before the plan is created.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Bottom Action
  // ===========================================================================

  Widget _buildBottomAction(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Confirm & Create EMI Plan'),
        ),
      ),
    );
  }

  // ===========================================================================
  // Financial Calculation — PREVIEW ONLY
  // ===========================================================================

  _FinancialPreview _calculateFinancialPreview() {
    final normalizedFinancedAmount = _roundCurrency(financedAmount);

    final interestAmount = _roundCurrency(
      normalizedFinancedAmount * request.interestRate / 100,
    );

    final processingFee = _roundCurrency(request.processingFee);

    final totalPayableAmount = _roundCurrency(
      normalizedFinancedAmount + interestAmount + processingFee,
    );

    final installmentAmount = _roundCurrency(
      totalPayableAmount / request.tenureMonths,
    );

    final finalInstallmentAmount = _roundCurrency(
      totalPayableAmount - (installmentAmount * (request.tenureMonths - 1)),
    );

    final installments = <_InstallmentPreview>[];

    for (var i = 1; i <= request.tenureMonths; i++) {
      final dueDate = _calculateMonthlyDueDate(request.firstDueDate, i - 1);

      final amount = i == request.tenureMonths
          ? finalInstallmentAmount
          : installmentAmount;

      installments.add(
        _InstallmentPreview(number: i, dueDate: dueDate, amount: amount),
      );
    }

    return _FinancialPreview(
      financedAmount: normalizedFinancedAmount,
      interestAmount: interestAmount,
      processingFee: processingFee,
      totalPayableAmount: totalPayableAmount,
      installmentAmount: installmentAmount,
      finalInstallmentAmount: finalInstallmentAmount,
      installments: installments,
      scheduleTotal: totalPayableAmount,
    );
  }

  // ===========================================================================
  // Monthly Date Calculation
  // ===========================================================================
  //
  // This mirrors the database logic:
  //
  // Jan 31
  //   ↓
  // Feb 28/29
  //   ↓
  // Mar 31
  //   ↓
  // Apr 30
  //
  // It does NOT permanently drift to the 28th.
  // ===========================================================================

  DateTime _calculateMonthlyDueDate(DateTime firstDueDate, int monthOffset) {
    final firstDate = DateTime(
      firstDueDate.year,
      firstDueDate.month,
      firstDueDate.day,
    );

    final targetMonth = DateTime(
      firstDate.year,
      firstDate.month + monthOffset,
      1,
    );

    final daysInTargetMonth = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
    ).day;

    final day = firstDate.day < daysInTargetMonth
        ? firstDate.day
        : daysInTargetMonth;

    return DateTime(targetMonth.year, targetMonth.month, day);
  }

  // ===========================================================================
  // Formatting
  // ===========================================================================

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _formatFrequency(String frequency) {
    if (frequency.toLowerCase() == 'monthly') {
      return 'Monthly';
    }

    return frequency;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  double _roundCurrency(double value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

// ==============================================================================
// Financial Preview
// ==============================================================================

class _FinancialPreview {
  const _FinancialPreview({
    required this.financedAmount,
    required this.interestAmount,
    required this.processingFee,
    required this.totalPayableAmount,
    required this.installmentAmount,
    required this.finalInstallmentAmount,
    required this.installments,
    required this.scheduleTotal,
  });

  final double financedAmount;
  final double interestAmount;
  final double processingFee;
  final double totalPayableAmount;
  final double installmentAmount;
  final double finalInstallmentAmount;
  final List<_InstallmentPreview> installments;
  final double scheduleTotal;
}

// ==============================================================================
// Installment Preview
// ==============================================================================

class _InstallmentPreview {
  const _InstallmentPreview({
    required this.number,
    required this.dueDate,
    required this.amount,
  });

  final int number;
  final DateTime dueDate;
  final double amount;
}

// ==============================================================================
// Section Card
// ==============================================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.accentColor,
  });

  final String title;
  final IconData icon;
  final Widget child;

  /// Accent color used for the icon and its soft background.
  /// Falls back to the theme primary color.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 23, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ==============================================================================
// Info Row
// ==============================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWeight = FontWeight.w600,
    this.valueSize,
    this.valueColor,
  });

  final String label;
  final String value;
  final FontWeight valueWeight;
  final double? valueSize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: valueWeight,
              fontSize: valueSize,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ==============================================================================
// Installment Row
// ==============================================================================

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.isFinal,
  });

  final int number;
  final DateTime dueDate;
  final double amount;
  final bool isFinal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            child: Text(
              '$number',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Installment $number',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$day/$month/${dueDate.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              if (isFinal) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Final',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
