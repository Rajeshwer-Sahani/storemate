import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/emi_installment_model.dart';
import '../../data/requests/record_emi_payment_request.dart';
import '../controllers/record_emi_payment_controller.dart';

class RecordEmiPaymentScreen extends StatefulWidget {
  const RecordEmiPaymentScreen({
    super.key,
    required this.emiPlanId,
    required this.installment,
    this.onRecorded, required double remainingAmount,
  });

  /// EMI plan against which the payment will be recorded.
  final String emiPlanId;

  /// The specific installment for which this payment is being recorded.
  final EmiInstallmentModel installment;

  /// Called after a payment has been successfully recorded.
  final VoidCallback? onRecorded;

  @override
  State<RecordEmiPaymentScreen> createState() => _RecordEmiPaymentScreenState();
}

class _RecordEmiPaymentScreenState extends State<RecordEmiPaymentScreen> {
  // ===========================================================================
  // Form
  // ===========================================================================

  final _formKey = GlobalKey<FormState>();

  // ===========================================================================
  // Controllers
  // ===========================================================================

  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;

  // ===========================================================================
  // State
  // ===========================================================================

  String _paymentMethod = 'Cash';

  late DateTime _paymentDate;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _referenceController = TextEditingController();
    _notesController = TextEditingController();

    final now = DateTime.now();

    _paymentDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record EMI Payment')),
      body: Consumer<RecordEmiPaymentController>(
        builder: (context, controller, _) {
          return AbsorbPointer(
            absorbing: controller.isLoading,
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(context),

                        const SizedBox(height: 20),

                        _buildPlanCard(context),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          context,
                          icon: Icons.payments_outlined,
                          title: 'Payment Details',
                        ),

                        const SizedBox(height: 12),

                        _buildAmountField(context),

                        const SizedBox(height: 14),

                        _buildPaymentMethodField(context),

                        const SizedBox(height: 14),

                        _buildPaymentDateField(context),

                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          context,
                          icon: Icons.notes_rounded,
                          title: 'Additional Information',
                        ),

                        const SizedBox(height: 12),

                        _buildReferenceField(context),

                        const SizedBox(height: 14),

                        _buildNotesField(context),

                        const SizedBox(height: 18),

                        _buildPaymentInfoCard(context),

                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _buildErrorMessage(context, controller.errorMessage!),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<RecordEmiPaymentController>(
        builder: (context, controller, _) {
          return _buildBottomAction(context, controller);
        },
      ),
    );
  }

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record a payment',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the amount received from the customer '
          'and provide the payment details.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // EMI Plan / Installment Card
  // ===========================================================================

  Widget _buildPlanCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final installment = widget.installment;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMI Plan',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      widget.emiPlanId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Installment #${installment.installmentNumber}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    _StatusBadge(status: installment.status),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      'Due ${_formatDisplayDate(installment.dueDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _InstallmentAmount(
                        label: 'Scheduled',
                        amount: installment.scheduledAmount,
                      ),
                    ),

                    Expanded(
                      child: _InstallmentAmount(
                        label: 'Paid',
                        amount: installment.paidAmount,
                        amountColor: Colors.green,
                      ),
                    ),

                    Expanded(
                      child: _InstallmentAmount(
                        label: 'Remaining',
                        amount: installment.remainingAmount,
                        amountColor: installment.remainingAmount > 0
                            ? colorScheme.error
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section Header
  // ===========================================================================

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: colorScheme.primary),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Amount Field
  // ===========================================================================

  Widget _buildAmountField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          labelText: 'Payment Amount',
          hintText: '0.00',
          prefixIcon: Icon(
            Icons.currency_rupee_rounded,
            color: colorScheme.primary,
          ),
          prefixText: '₹ ',
          prefixStyle: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.primary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return 'Enter the payment amount';
          }

          final amount = double.tryParse(text);

          if (amount == null) {
            return 'Enter a valid amount';
          }

          if (amount <= 0) {
            return 'Amount must be greater than zero';
          }

          if (amount > widget.installment.remainingAmount + 0.01) {
            return 'Amount cannot exceed the installment balance';
          }

          return null;
        },
      ),
    );
  }

  // ===========================================================================
  // Payment Method
  // ===========================================================================

  Widget _buildPaymentMethodField(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _paymentMethod,
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        hintText: 'Select payment method',
        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
        DropdownMenuItem(value: 'Card', child: Text('Card')),
        DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
        DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _paymentMethod = value;
        });
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Select a payment method';
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // Payment Date
  // ===========================================================================

  Widget _buildPaymentDateField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormField<DateTime>(
      initialValue: _paymentDate,
      validator: (value) {
        if (value == null) {
          return 'Select a payment date';
        }

        return null;
      },
      builder: (field) {
        final hasError = field.errorText != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectPaymentDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Payment Date',
                  prefixIcon: const Icon(Icons.event_rounded),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  errorText: field.errorText,
                ),
                child: Text(
                  _formatDisplayDate(_paymentDate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(
                  'Date on which the payment was received.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Reference
  // ===========================================================================

  Widget _buildReferenceField(BuildContext context) {
    return TextFormField(
      controller: _referenceController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Reference',
        hintText: 'Transaction ID, cheque number, etc.',
        prefixIcon: Icon(Icons.tag_rounded),
      ),
    );
  }

  // ===========================================================================
  // Notes
  // ===========================================================================

  Widget _buildNotesField(BuildContext context) {
    return TextFormField(
      controller: _notesController,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      maxLength: 500,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Add any additional payment notes',
        prefixIcon: Icon(Icons.notes_rounded),
        alignLabelWithHint: true,
      ),
    );
  }

  // ===========================================================================
  // Payment Information
  // ===========================================================================

  Widget _buildPaymentInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.50),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 19,
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Payment will update the EMI balance '
              'and installment status automatically.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Error
  // ===========================================================================

  Widget _buildErrorMessage(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: context.read<RecordEmiPaymentController>().clearError,
            icon: const Icon(Icons.close_rounded, size: 19),
            visualDensity: VisualDensity.compact,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Bottom Action
  // ===========================================================================

  Widget _buildBottomAction(
    BuildContext context,
    RecordEmiPaymentController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: FilledButton.icon(
        onPressed: controller.isLoading ? null : _submit,
        icon: controller.isLoading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Icon(Icons.payments_rounded),
        label: Text(
          controller.isLoading ? 'Recording Payment...' : 'Record Payment',
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ===========================================================================
  // Date Picker
  // ===========================================================================

  Future<void> _selectPaymentDate() async {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _paymentDate.isAfter(today) ? today : _paymentDate,
      firstDate: DateTime(now.year - 10, now.month, now.day),
      lastDate: today,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _paymentDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
    });
  }

  // ===========================================================================
  // Submit
  // ===========================================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    final controller = context.read<RecordEmiPaymentController>();

    final request = RecordEmiPaymentRequest(
      emiPlanId: widget.emiPlanId,
      amount: amount,
      paymentMethod: _paymentMethod,
      paymentDate: _paymentDate,
      reference: _nullableText(_referenceController.text),
      notes: _nullableText(_notesController.text),
    );

    final payment = await controller.recordPayment(request);

    if (!mounted) {
      return;
    }

    if (payment == null) {
      return;
    }

    if (widget.onRecorded != null) {
      widget.onRecorded!();
      return;
    }

    Navigator.of(context).pop(payment);
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  String? _nullableText(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(amount);
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }
}

// =============================================================================
// Installment Amount
// =============================================================================

class _InstallmentAmount extends StatelessWidget {
  const _InstallmentAmount({
    required this.label,
    required this.amount,
    this.amountColor,
  });

  final String label;
  final double amount;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Status Badge
// =============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final normalized = status.toLowerCase();

    final Color color;

    switch (normalized) {
      case 'paid':
        color = Colors.green;
        break;

      case 'overdue':
        color = colorScheme.error;
        break;

      case 'partially_paid':
      case 'partially paid':
        color = Colors.orange;
        break;

      case 'due':
        color = colorScheme.primary;
        break;

      case 'cancelled':
      case 'canceled':
        color = colorScheme.onSurfaceVariant;
        break;

      default:
        color = colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        _statusLabel(status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'partially_paid':
      case 'partially paid':
        return 'Partially Paid';

      case 'paid':
        return 'Paid';

      case 'overdue':
        return 'Overdue';

      case 'due':
        return 'Due';

      case 'upcoming':
        return 'Upcoming';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        if (value.isEmpty) {
          return 'Unknown';
        }

        return value[0].toUpperCase() + value.substring(1);
    }
  }
}
