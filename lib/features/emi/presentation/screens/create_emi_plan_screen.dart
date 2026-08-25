import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _firstDueDate = _addOneMonthSafely(now);
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create EMI Plan')),
      body: Consumer<CreateEmiPlanController>(
        builder: (context, controller, _) {
          return Form(
            key: _formKey,
            child: AbsorbPointer(
              absorbing: controller.isLoading,
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildInvoiceCard(context),

                        const SizedBox(height: 28),

                        _buildSectionHeader(
                          context,
                          icon: Icons.payments_outlined,
                          title: 'EMI Schedule',
                          subtitle:
                              'Configure how the customer will repay this invoice.',
                        ),

                        const SizedBox(height: 16),

                        _buildTenureField(context),

                        const SizedBox(height: 14),

                        _buildFrequencyField(context),

                        const SizedBox(height: 14),

                        _buildFirstDueDateField(context),

                        const SizedBox(height: 20),

                        _buildSchedulePreview(context),

                        const SizedBox(height: 20),

                        _buildInformationCard(context),

                        if (controller.errorMessage != null) ...[
                          const SizedBox(height: 20),
                          _buildErrorMessage(context, controller.errorMessage!),
                        ],

                        const SizedBox(height: 28),

                        _buildSubmitButton(context, controller),

                        const SizedBox(height: 12),

                        _buildFooterNote(context),
                      ]),
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up an EMI plan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Create a structured repayment plan for the selected invoice.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Invoice Card
  // ===========================================================================

  Widget _buildInvoiceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Invoice',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.invoice.invoiceNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),

          const SizedBox(height: 16),

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
                height: 36,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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

          if (widget.invoice.customerName.trim().isNotEmpty) ...[
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      widget.invoice.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Tenure
  // ===========================================================================

  Widget _buildTenureField(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _tenureMonths,
      decoration: const InputDecoration(
        labelText: 'Tenure',
        hintText: 'Select repayment tenure',
        prefixIcon: Icon(Icons.calendar_month_rounded),
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
      decoration: const InputDecoration(
        labelText: 'Payment Frequency',
        hintText: 'Select payment frequency',
        prefixIcon: Icon(Icons.repeat_rounded),
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
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _selectFirstDueDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'First Due Date',
                  prefixIcon: const Icon(Icons.event_available_rounded),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  errorText: field.errorText,
                ),
                child: Text(
                  _formatDate(_firstDueDate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hasError ? colorScheme.error : colorScheme.onSurface,
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

  Widget _buildSchedulePreview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph_rounded, size: 21, color: colorScheme.primary),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan configuration',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_tenureMonths} monthly installments • '
                  'Starts ${_formatDate(_firstDueDate)}',
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
  // Information
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
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              'The final financed amount, interest, processing fee, '
              'total payable amount, and installment schedule are '
              'calculated and validated by StoreMate.',
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 21),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: context.read<CreateEmiPlanController>().clearError,
            icon: const Icon(Icons.close_rounded),
            visualDensity: VisualDensity.compact,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Submit
  // ===========================================================================

  Widget _buildSubmitButton(
    BuildContext context,
    CreateEmiPlanController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: controller.isLoading ? null : _submit,
        icon: controller.isLoading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : const Icon(Icons.add_task_rounded),
        label: Text(
          controller.isLoading ? 'Creating EMI Plan...' : 'Create EMI Plan',
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Financial calculations are securely handled by the database.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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

    final controller = context.read<CreateEmiPlanController>();

    final request = CreateEmiPlanRequest(
      invoiceId: widget.invoice.id,
      tenureMonths: _tenureMonths,
      frequency: _frequency,
      firstDueDate: _firstDueDate,
    );

    final plan = await controller.createEmiPlan(request);

    if (!mounted || plan == null) {
      return;
    }

    if (widget.onCreated != null) {
      widget.onCreated!();
      return;
    }

    Navigator.of(context).pop(plan);
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
