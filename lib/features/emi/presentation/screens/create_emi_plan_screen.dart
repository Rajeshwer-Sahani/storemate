import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storemate/features/emi/presentation/screens/review_emi_plan_screen.dart';

import '../../../../features/billing/data/models/invoice_model.dart';
import '../../data/requests/create_emi_plan_request.dart';
import '../controllers/create_emi_plan_controller.dart';

class CreateEmiPlanScreen extends StatefulWidget {
  const CreateEmiPlanScreen({super.key, required this.invoice, this.onCreated});

  /// Invoice for which the EMI plan will be created.
  final InvoiceModel invoice;

  /// Called after successful EMI plan creation.
  final VoidCallback? onCreated;

  @override
  State<CreateEmiPlanScreen> createState() => _CreateEmiPlanScreenState();
}

class _CreateEmiPlanScreenState extends State<CreateEmiPlanScreen> {
  // ===========================================================================
  // Form
  // ===========================================================================

  final _formKey = GlobalKey<FormState>();

  // ===========================================================================
  // Form State
  // ===========================================================================

  int _tenureMonths = 6;

  String _frequency = 'monthly';

  late DateTime _firstDueDate;

  // ===========================================================================
  // EMI Financial Terms
  // ===========================================================================

  final _interestController = TextEditingController();
  final _processingFeeController = TextEditingController();

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _firstDueDate = _addOneMonthSafely(DateTime.now());
  }

  @override
  void dispose() {
    _interestController.dispose();
    _processingFeeController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // -----------------------------------------------------
                  // Intro
                  // -----------------------------------------------------
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // -----------------------------------------------------
                  // Selected Invoice
                  // -----------------------------------------------------
                  _buildInvoiceCard(context),

                  const SizedBox(height: 28),

                  // -----------------------------------------------------
                  // EMI Schedule
                  // -----------------------------------------------------
                  _buildSectionHeader(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'EMI Schedule',
                    subtitle:
                        'Configure how the customer will repay this invoice.',
                  ),

                  const SizedBox(height: 28),

                  _buildTenureField(context),

                  const SizedBox(height: 14),

                  _buildFrequencyField(context),

                  const SizedBox(height: 14),

                  _buildFirstDueDateField(context),

                  const SizedBox(height: 28),

                  // -----------------------------------------------------
                  // EMI Charges / Financial Terms
                  // -----------------------------------------------------
                  _buildSectionHeader(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'EMI Charges / Financial Terms',
                    subtitle:
                        'Configure the charges applicable to this EMI plan.',
                  ),

                  const SizedBox(height: 24),

                  _buildInterestField(context),

                  const SizedBox(height: 14),

                  _buildProcessingFeeField(context),

                  const SizedBox(height: 28),

                  // -----------------------------------------------------
                  // Configuration Preview
                  // -----------------------------------------------------
                  _buildSchedulePreview(context),

                  const SizedBox(height: 20),

                  // -----------------------------------------------------
                  // Information
                  // -----------------------------------------------------
                  _buildInformationCard(context),

                  const SizedBox(height: 24),

                  // -----------------------------------------------------
                  // Submit
                  // -----------------------------------------------------
                  _buildSubmitButton(context),

                  const SizedBox(height: 14),

                  // -----------------------------------------------------
                  // Security Footer
                  // -----------------------------------------------------
                  _buildFooterNote(context),

                  const SizedBox(height: 4),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // App Bar
  // ===========================================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).maybePop();
        },
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
        tooltip: 'Back',
      ),
      title: Text(
        'Create EMI Plan',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showHelpDialog,
          icon: const Icon(Icons.help_outline_rounded, size: 23),
          tooltip: 'Help',
        ),
        const SizedBox(width: 8),
      ],
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
          'Set up an EMI plan',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Create a structured repayment plan for the selected invoice.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
            letterSpacing: -0.5,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Selected Invoice Card
  // ===========================================================================

  // ===========================================================================
  // Selected Invoice Card
  // ===========================================================================

  Widget _buildInvoiceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = widget.invoice.customerName.trim().isEmpty
        ? 'Walk-in Customer'
        : widget.invoice.customerName.trim();

    final customerPhone = widget.invoice.customerPhone?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Soft blue tint instead of the heavy primaryContainer overlay.
        color: colorScheme.primary.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // Invoice Header
          // -------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.primary,
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Invoice',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.invoice.invoiceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Divider(
            height: 1,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // Amounts
          // -------------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _buildInvoiceAmount(
                  context,
                  label: 'Invoice Total',
                  amount: widget.invoice.grandTotal,
                ),
              ),

              Container(
                width: 1,
                height: 40,
                color: colorScheme.primary.withValues(alpha: 0.12),
              ),

              Expanded(
                child: _buildInvoiceAmount(
                  context,
                  label: 'Outstanding',
                  amount: widget.invoice.dueAmount,
                  emphasize: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // Customer + Phone
          // -------------------------------------------------------------------
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 19,
                color: colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              if (customerPhone != null && customerPhone.isNotEmpty) ...[
                const SizedBox(width: 12),

                Icon(
                  Icons.phone_outlined,
                  size: 17,
                  color: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 6),

                Flexible(
                  child: Text(
                    customerPhone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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

  Widget _buildInvoiceAmount(
    BuildContext context, {
    required String label,
    required double amount,
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatCurrency(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: emphasize ? colorScheme.primary : colorScheme.onSurface,
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
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 22, color: colorScheme.primary),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                  letterSpacing: -0.5,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Interest Rate
  // ===========================================================================

  Widget _buildInterestField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: _interestController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Interest Rate',
        hintText: 'Enter interest rate',
        prefixIcon: const Icon(Icons.percent_rounded),
        suffixText: '%',
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter an interest rate';
        }

        final rate = double.tryParse(text);

        if (rate == null) {
          return 'Please enter a valid interest rate';
        }

        if (rate < 0) {
          return 'Interest rate cannot be negative';
        }

        if (rate > 100) {
          return 'Interest rate cannot exceed 100%';
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // Processing Fee
  // ===========================================================================

  Widget _buildProcessingFeeField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: _processingFeeController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Processing Fee',
        hintText: 'Enter processing fee',
        prefixIcon: const Icon(Icons.receipt_long_outlined),
        prefixText: '₹ ',
        filled: true,
        fillColor: colorScheme.surface,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter a processing fee';
        }

        final amount = double.tryParse(text);

        if (amount == null) {
          return 'Please enter a valid amount';
        }

        if (amount < 0) {
          return 'Processing fee cannot be negative';
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // Tenure
  // ===========================================================================

  Widget _buildTenureField(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _tenureMonths,
      decoration: InputDecoration(
        labelText: 'Tenure',
        hintText: 'Select repayment tenure',
        prefixIcon: const Icon(Icons.calendar_month_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: const [
        DropdownMenuItem(value: 3, child: Text('3 Months')),
        DropdownMenuItem(value: 6, child: Text('6 Months')),
        DropdownMenuItem(value: 9, child: Text('9 Months')),
        DropdownMenuItem(value: 12, child: Text('12 Months')),
        DropdownMenuItem(value: 18, child: Text('18 Months')),
        DropdownMenuItem(value: 24, child: Text('24 Months')),
        DropdownMenuItem(value: 36, child: Text('36 Months')),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _tenureMonths = value;
        });
      },
      validator: (value) {
        if (value == null || value <= 0) {
          return 'Please select a valid tenure';
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // Frequency
  // ===========================================================================

  Widget _buildFrequencyField(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _frequency,
      decoration: InputDecoration(
        labelText: 'Payment Frequency',
        hintText: 'Select payment frequency',
        prefixIcon: const Icon(Icons.repeat_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: const [DropdownMenuItem(value: 'monthly', child: Text('Monthly'))],
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _frequency = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a payment frequency';
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // First Due Date
  // ===========================================================================

  Widget _buildFirstDueDateField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormField<DateTime>(
      initialValue: _firstDueDate,
      validator: (value) {
        if (value == null) {
          return 'Please select the first due date';
        }

        return null;
      },
      builder: (field) {
        final hasError = field.errorText != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _selectFirstDueDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'First Due Date',
                    prefixIcon: const Icon(Icons.event_available_rounded),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                    errorText: field.errorText,
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  child: Text(
                    _formatDate(_firstDueDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasError
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),

            if (!hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 7),
                child: Text(
                  'The first installment will be scheduled from this date.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Schedule Preview
  // ===========================================================================

  // ===========================================================================
  // Schedule Preview
  // ===========================================================================

  Widget _buildSchedulePreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Semantic success/confirmation colors.
    // Kept local so the card works correctly in both light and dark mode.
    final isDark = theme.brightness == Brightness.dark;

    final successColor = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF43A047);

    final successBackground = isDark
        ? const Color(0xFF1B2A1D)
        : const Color(0xFFF1F8F2);

    final successBorder = isDark
        ? const Color(0xFF355C3A)
        : const Color(0xFFDCEFE0);

    final successIconBackground = isDark
        ? const Color(0xFF263D29)
        : const Color(0xFFE5F4E7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: successBackground,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: successBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------------------
          // Icon
          // -------------------------------------------------------------------
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: successIconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.auto_graph_rounded,
              size: 22,
              color: successColor,
            ),
          ),

          const SizedBox(width: 13),

          // -------------------------------------------------------------------
          // Configuration Details
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan configuration',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_tenureMonths} monthly installments • '
                  'Starts ${_formatDate(_firstDueDate)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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
  // Information Card
  // ===========================================================================

  Widget _buildInformationCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 19,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              'Interest and processing fee are configured by the store owner. '
              'StoreMate securely calculates and validates the final payable amount '
              'and installment schedule.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
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
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  height: 1.4,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: context.read<CreateEmiPlanController>().clearError,
            icon: const Icon(Icons.close_rounded, size: 19),
            visualDensity: VisualDensity.compact,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Submit Button
  // ===========================================================================

  Widget _buildSubmitButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: _submit,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.arrow_forward_rounded, size: 21),
        label: const Text(
          'Review EMI Plan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ===========================================================================
  // Footer
  // ===========================================================================

  Widget _buildFooterNote(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),

            const SizedBox(width: 8),

            Text(
              'Financial calculations are securely handled by the database.',
              maxLines: 1,
              softWrap: false,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Help
  // ===========================================================================

  void _showHelpDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Creating an EMI plan')),
            ],
          ),
          content: Text(
            'Select the repayment tenure, payment frequency, '
            'and first due date for this invoice.\n\n'
            'StoreMate will calculate and validate the final '
            'financed amount, applicable charges, and repayment '
            'schedule when the EMI plan is created.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Date Picker
  // ===========================================================================

  Future<void> _selectFirstDueDate() async {
    final now = DateTime.now();

    final minimumDate = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _firstDueDate.isBefore(minimumDate)
          ? minimumDate
          : _firstDueDate,
      firstDate: minimumDate,
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _firstDueDate = selectedDate;
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

    final interest = double.parse(_interestController.text.trim());
    final processingFee = double.parse(_processingFeeController.text.trim());

    final request = CreateEmiPlanRequest(
      invoiceId: widget.invoice.id,
      tenureMonths: _tenureMonths,
      frequency: _frequency,
      firstDueDate: _firstDueDate,
      interestRate: interest,
      processingFee: processingFee,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewEmiPlanScreen(
          request: request,
          financedAmount: widget.invoice.dueAmount,
          invoiceNumber: widget.invoice.invoiceNumber,
          customerName: widget.invoice.customerName,
          onConfirm: () => _confirmAndCreateEmiPlan(request),
        ),
      ),
    );
  }

  // ===========================================================================
  // Confirm & Create EMI Plan
  // ===========================================================================

  Future<void> _confirmAndCreateEmiPlan(CreateEmiPlanRequest request) async {
    FocusScope.of(context).unfocus();

    final controller = context.read<CreateEmiPlanController>();

    final plan = await controller.createEmiPlan(request);

    if (!mounted) {
      return;
    }

    if (plan == null) {
      throw Exception('Unable to create EMI plan.');
    }

    // EMI plan was successfully created.
    // Close ReviewEmiPlanScreen first.
    Navigator.of(context).pop();

    // Refresh the previous screen.
    widget.onCreated?.call();
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  DateTime _addOneMonthSafely(DateTime date) {
    final targetMonth = date.month + 1;

    final firstDayOfTargetMonth = DateTime(date.year, targetMonth, 1);

    final lastDayOfTargetMonth = DateTime(
      firstDayOfTargetMonth.year,
      firstDayOfTargetMonth.month + 1,
      0,
    );

    final day = date.day > lastDayOfTargetMonth.day
        ? lastDayOfTargetMonth.day
        : date.day;

    return DateTime(
      firstDayOfTargetMonth.year,
      firstDayOfTargetMonth.month,
      day,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
