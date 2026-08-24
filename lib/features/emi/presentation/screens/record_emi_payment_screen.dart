import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/requests/record_emi_payment_request.dart';
import '../controllers/record_emi_payment_controller.dart';

class RecordEmiPaymentScreen extends StatefulWidget {
  const RecordEmiPaymentScreen({
    super.key,
    required this.emiPlanId,
    this.remainingAmount,
    this.onRecorded,
  });

  /// EMI plan against which the payment will be recorded.
  final String emiPlanId;

  /// Optional outstanding amount.
  ///
  /// This is used only for UI validation/hinting. The backend remains
  /// authoritative for the actual payment validation.
  final double? remainingAmount;

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
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  SliverToBoxAdapter(child: _buildForm(context)),

                  if (controller.errorMessage != null)
                    SliverToBoxAdapter(
                      child: _buildErrorMessage(
                        context,
                        controller.errorMessage!,
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: _buildSubmitButton(context, controller),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          );
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record a payment',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Enter the amount received from the customer '
            'and the payment details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Form
  // ===========================================================================

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanCard(context),

          const SizedBox(height: 20),

          _buildSectionLabel(context, 'Payment Details'),

          const SizedBox(height: 10),

          _buildAmountField(context),

          const SizedBox(height: 14),

          _buildPaymentMethodField(context),

          const SizedBox(height: 14),

          _buildPaymentDateField(context),

          const SizedBox(height: 20),

          _buildSectionLabel(context, 'Additional Information'),

          const SizedBox(height: 10),

          _buildReferenceField(context),

          const SizedBox(height: 14),

          _buildNotesField(context),

          const SizedBox(height: 20),

          _buildPaymentInfoCard(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMI Plan Card
  // ===========================================================================

  Widget _buildPlanCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasRemainingAmount =
        widget.remainingAmount != null && widget.remainingAmount! > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMI Plan',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.emiPlanId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (hasRemainingAmount) ...[
                  const SizedBox(height: 5),

                  Text(
                    'Outstanding: '
                    '₹${widget.remainingAmount!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section Label
  // ===========================================================================

  Widget _buildSectionLabel(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  // ===========================================================================
  // Amount
  // ===========================================================================

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Payment Amount',
        hintText: 'Enter amount received',
        prefixText: '₹ ',
        prefixIcon: Icon(Icons.currency_rupee_rounded),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter the payment amount';
        }

        final amount = double.tryParse(text);

        if (amount == null) {
          return 'Please enter a valid amount';
        }

        if (amount <= 0) {
          return 'Payment amount must be greater than zero';
        }

        if (widget.remainingAmount != null &&
            widget.remainingAmount! > 0 &&
            amount > widget.remainingAmount! + 0.01) {
          return 'Amount cannot exceed the outstanding balance';
        }

        return null;
      },
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
          return 'Please select a payment method';
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
          return 'Please select a payment date';
        }

        return null;
      },
      builder: (field) {
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
                  errorText: field.errorText,
                ),
                child: Text(
                  _formatDate(_paymentDate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (field.errorText == null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(
                  'Date on which the customer made the payment.',
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
      validator: (_) => null,
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
      validator: (_) => null,
    );
  }

  // ===========================================================================
  // Information Card
  // ===========================================================================

  Widget _buildPaymentInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Recording a payment will update the EMI plan '
              'balance and installment status through the '
              'backend transaction.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.error.withValues(alpha: .20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: colorScheme.error),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),

            IconButton(
              onPressed: context.read<RecordEmiPaymentController>().clearError,
              icon: const Icon(Icons.close_rounded),
              visualDensity: VisualDensity.compact,
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Submit Button
  // ===========================================================================

  Widget _buildSubmitButton(
    BuildContext context,
    RecordEmiPaymentController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: controller.isLoading ? null : _submit,
          icon: controller.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.payments_rounded),
          label: Text(
            controller.isLoading ? 'Recording Payment...' : 'Record Payment',
          ),
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

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _paymentDate = selectedDate;
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
