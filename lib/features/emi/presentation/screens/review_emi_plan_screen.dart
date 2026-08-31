import 'package:flutter/material.dart';

import '../../data/requests/create_emi_plan_request.dart';

class ReviewEmiPlanScreen extends StatefulWidget {
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

  /// Configuration that will be sent to create_emi_plan RPC.
  final CreateEmiPlanRequest request;

  /// Current invoice outstanding amount.
  ///
  /// Used only for preview.
  /// PostgreSQL recalculates the authoritative value during creation.
  final double financedAmount;

  /// Human-readable invoice number for display.
  final String? invoiceNumber;

  /// Customer name for display.
  final String? customerName;

  /// Called after the EMI plan has been successfully created.
  final Future<void> Function() onConfirm;

  @override
  State<ReviewEmiPlanScreen> createState() => _ReviewEmiPlanScreenState();
}

class _ReviewEmiPlanScreenState extends State<ReviewEmiPlanScreen> {
  bool _isCreating = false;

  // ===========================================================================
  // Confirm & Create EMI Plan
  // ===========================================================================

  Future<void> _confirmAndCreateEmiPlan() async {
    if (_isCreating) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isCreating = true;
    });

    try {
      // The parent owns the actual EMI creation operation.
      await widget.onConfirm();

      if (!mounted) {
        return;
      }

      // Creation succeeded. Close the review screen.
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCreating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create the EMI plan. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
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
  Widget _buildInvoiceSection(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      title: 'Invoice',
      icon: Icons.receipt_long_rounded,
      accentColor: theme.colorScheme.primary,
      child: Column(
        children: [
          if (widget.invoiceNumber != null)
            _InfoRow(label: 'Invoice', value: widget.invoiceNumber!),

          if (widget.invoiceNumber != null && widget.customerName != null)
            const SizedBox(height: 14),

          if (widget.customerName != null)
            _InfoRow(label: 'Customer', value: widget.customerName!),

          if (widget.invoiceNumber != null || widget.customerName != null)
            const SizedBox(height: 14),

          _InfoRow(
            label: 'Outstanding Amount',
            value: _formatCurrency(widget.financedAmount),
            valueWeight: FontWeight.w800,
            valueSize: 17,
            valueColor: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  Widget _buildEmiTermsSection(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      title: 'EMI Terms',
      icon: Icons.calendar_month_rounded,
      accentColor: theme.colorScheme.secondary,
      child: Column(
        children: [
          _InfoRow(
            label: 'Frequency',
            value: _formatFrequency(widget.request.frequency),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Tenure',
            value: '${widget.request.tenureMonths} installments',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'First Due Date',
            value: _formatDate(widget.request.firstDueDate),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Interest Rate',
            value: '${_formatNumber(widget.request.interestRate)}%',
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Processing Fee',
            value: _formatCurrency(widget.request.processingFee),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  Widget _buildFinancialSummary(
    BuildContext context,
    _FinancialPreview preview,
  ) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Financial Summary',
      icon: Icons.account_balance_wallet_outlined,
      accentColor: Colors.green,
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
                '(${_formatNumber(widget.request.interestRate)}%)',
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
            valueColor: Colors.green,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Regular Installment',
            value: _formatCurrency(preview.installmentAmount),
            valueWeight: FontWeight.w800,
            valueSize: 18,
            valueColor: Colors.amber.shade800,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  Widget _buildScheduleSection(
    BuildContext context,
    _FinancialPreview preview,
  ) {
    final theme = Theme.of(context);
    return _SectionCard(
      title: 'Payment Schedule',
      icon: Icons.event_note_rounded,
      accentColor: theme.colorScheme.tertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.request.tenureMonths} monthly installments',
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
                isFinal: installment.number == widget.request.tenureMonths,
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
  Widget _buildImportantNotice(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
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
          onPressed: _isCreating ? null : _confirmAndCreateEmiPlan,
          icon: _isCreating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.check_circle_outline_rounded),
          label: Text(
            _isCreating ? 'Creating EMI Plan...' : 'Confirm & Create EMI Plan',
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  _FinancialPreview _calculateFinancialPreview() {
    final normalizedFinancedAmount = _roundCurrency(widget.financedAmount);

    final interestAmount = _roundCurrency(
      normalizedFinancedAmount * widget.request.interestRate / 100,
    );

    final processingFee = _roundCurrency(widget.request.processingFee);

    final totalPayableAmount = _roundCurrency(
      normalizedFinancedAmount + interestAmount + processingFee,
    );

    final installmentAmount = _roundCurrency(
      totalPayableAmount / widget.request.tenureMonths,
    );

    final finalInstallmentAmount = _roundCurrency(
      totalPayableAmount -
          (installmentAmount * (widget.request.tenureMonths - 1)),
    );

    final installments = <_InstallmentPreview>[];

    for (var i = 1; i <= widget.request.tenureMonths; i++) {
      final dueDate = _calculateMonthlyDueDate(
        widget.request.firstDueDate,
        i - 1,
      );

      final amount = i == widget.request.tenureMonths
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
                  // color: Colors.amber.shade800,
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
