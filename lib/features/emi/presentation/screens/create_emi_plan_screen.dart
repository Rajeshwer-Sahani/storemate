import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/requests/create_emi_plan_request.dart';
import '../controllers/create_emi_plan_controller.dart';

class CreateEmiPlanScreen extends StatefulWidget {
  const CreateEmiPlanScreen({
    super.key,
    required this.invoiceId,
    this.onCreated,
  });

  /// Invoice from which the EMI plan will be created.
  final String invoiceId;

  /// Optional callback invoked after successful creation.
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

  @override
  void initState() {
    super.initState();

    // Default first due date: one month from today.
    final now = DateTime.now();

    _firstDueDate = DateTime(now.year, now.month + 1, now.day);
  }

  @override
  void dispose() {
    super.dispose();
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
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.clearError();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
            'Set up an EMI plan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the repayment tenure and first due date '
            'for this invoice.',
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
          _buildInvoiceCard(context),

          const SizedBox(height: 20),

          _buildSectionLabel(context, 'EMI Schedule'),

          const SizedBox(height: 10),

          _buildTenureField(context),

          const SizedBox(height: 14),

          _buildFrequencyField(context),

          const SizedBox(height: 14),

          _buildFirstDueDateField(context),

          const SizedBox(height: 20),

          _buildInformationCard(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // Invoice
  // ===========================================================================

  Widget _buildInvoiceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.invoiceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.check_circle_rounded,
            color: colorScheme.tertiary,
            size: 20,
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
  // Tenure
  // ===========================================================================

  Widget _buildTenureField(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _tenureMonths,
      decoration: const InputDecoration(
        labelText: 'Tenure',
        hintText: 'Select EMI tenure',
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _selectFirstDueDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'First Due Date',
                  prefixIcon: const Icon(Icons.event_available_rounded),
                  errorText: field.errorText,
                ),
                child: Text(
                  _formatDate(_firstDueDate),
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
                  'The first EMI installment will be due on this date.',
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
  // Information
  // ===========================================================================

  Widget _buildInformationCard(BuildContext context) {
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
              'The EMI plan amount, installments, interest, '
              'and repayment schedule will be generated from '
              'the selected invoice by the backend.',
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
              onPressed: context.read<CreateEmiPlanController>().clearError,
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
  // Submit
  // ===========================================================================

  Widget _buildSubmitButton(
    BuildContext context,
    CreateEmiPlanController controller,
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
              : const Icon(Icons.add_task_rounded),
          label: Text(
            controller.isLoading ? 'Creating EMI Plan...' : 'Create EMI Plan',
          ),
        ),
      ),
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

    if (selectedDate == null) {
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
      invoiceId: widget.invoiceId,
      tenureMonths: _tenureMonths,
      frequency: _frequency,
      firstDueDate: _firstDueDate,
    );

    final plan = await controller.createEmiPlan(request);

    if (!mounted) {
      return;
    }

    if (plan == null) {
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}
