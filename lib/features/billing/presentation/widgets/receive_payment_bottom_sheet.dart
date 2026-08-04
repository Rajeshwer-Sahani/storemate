import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/presentation/controllers/receive_payment_controller.dart';
import 'package:storemate/features/billing/presentation/widgets/payment_method_bottom_sheet.dart';

class ReceivePaymentBottomSheet extends StatefulWidget {
  const ReceivePaymentBottomSheet({
    super.key,
    required this.billingService,
    required this.invoice,
  });

  final BillingService billingService;
  final InvoiceModel invoice;

  static Future<bool?> show(
    BuildContext context, {
    required BillingService billingService,
    required InvoiceModel invoice,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ReceivePaymentBottomSheet(
          billingService: billingService,
          invoice: invoice,
        );
      },
    );
  }

  @override
  State<ReceivePaymentBottomSheet> createState() =>
      _ReceivePaymentBottomSheetState();
}

class _ReceivePaymentBottomSheetState extends State<ReceivePaymentBottomSheet> {
  late final ReceivePaymentController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReceivePaymentController(
      billingService: widget.billingService,
      invoice: widget.invoice,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildBottomSheet(),
        );
      },
    );
  }

  //==========================================================================
  // Bottom Sheet UI
  //==========================================================================
  Widget _buildBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),

              const SizedBox(height: 20),

              _buildHeader(),

              const SizedBox(height: 28),

              // Payment Summary
              _buildPaymentSummary(),

              const SizedBox(height: 24),
              // Amount Field
              _buildAmountField(),

              const SizedBox(height: 20),
              // Payment Method
              _buildPaymentMethodField(),

              const SizedBox(height: 24),

              // Notes
              // Bottom Buttons
              _buildNotesField(),

              const SizedBox(height: 20),

              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _controller.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  //==========================================================================
  // Bottom Sheet UI Components
  //==========================================================================
  Widget _buildDragHandle() {
    return Container(
      width: 42,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  //==========================================================================
  // Bottom Sheet UI Sections
  //==========================================================================
  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.money_dollar_circle_fill,
          size: 46,
          color: Color(0xFF2563EB),
        ),

        const SizedBox(height: 16),

        Text(
          'Receive Payment',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),

        Text(
          'Record a payment for this invoice.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  //==========================================================================
  // Bottom Sheet UI Subsections
  //==========================================================================
  Widget _buildPaymentSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildSummaryRow(
              title: 'Already Paid',
              value: _controller.invoice.paidAmount,
              valueColor: Colors.green.shade700,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            _buildSummaryRow(
              title: 'Remaining Due',
              value: _controller.invoice.dueAmount,
              valueColor: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String title,
    required double value,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          '₹${value.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  //==========================================================================
  // Bottom Sheet UI Subsections
  //==========================================================================
  Widget _buildAmountField() {
    return TextFormField(
      controller: _controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Receive Amount',
        hintText: 'Enter received amount',
        prefixText: '₹ ',
      ),
    );
  }

  Widget _buildPaymentMethodField() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _selectPaymentMethod,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Payment Method'),
        child: Row(
          children: [
            Expanded(child: Text(_controller.paymentMethod)),

            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPaymentMethod() async {
    final method = await PaymentMethodBottomSheet.show(
      context,
      selectedMethod: _controller.paymentMethod,
    );

    if (method == null) {
      return;
    }

    _controller.updatePaymentMethod(method);
  }

  //==========================================================================
  // Bottom Sheet UI Subsections
  //==========================================================================
  Widget _buildNotesField() {
    return TextFormField(
      controller: _controller.notesController,
      minLines: 3,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Enter payment remarks',
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        //------------------------------------------------------
        // Cancel
        //------------------------------------------------------
        Expanded(
          child: OutlinedButton(
            onPressed: _controller.isLoading
                ? null
                : () {
                    Navigator.pop(context);
                  },
            child: const Text('Cancel'),
          ),
        ),

        const SizedBox(width: 16),

        //------------------------------------------------------
        // Receive Payment
        //------------------------------------------------------
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _controller.isLoading ? null : _submit,

            icon: _controller.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.payments_rounded),

            label: Text(
              _controller.isLoading ? 'Processing...' : 'Receive Payment',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final invoiceId = await _controller.receivePayment();

    if (!mounted) {
      return;
    }

    if (invoiceId == null) {
      return;
    }

    Navigator.pop(context, true);
  }
}
