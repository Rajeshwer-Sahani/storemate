import 'package:flutter/material.dart';

import '../../../../features/billing/data/models/invoice_model.dart';
import '../../../../features/billing/data/services/billing_service.dart';
import 'create_emi_plan_screen.dart';

class SelectInvoiceForEmiScreen extends StatefulWidget {
  const SelectInvoiceForEmiScreen({
    super.key,
    this.onInvoiceSelected,
  });

  /// Optional callback for callers that want to handle the selected invoice
  /// themselves instead of navigating to CreateEmiPlanScreen.
  final ValueChanged<InvoiceModel>? onInvoiceSelected;

  @override
  State<SelectInvoiceForEmiScreen> createState() =>
      _SelectInvoiceForEmiScreenState();
}

class _SelectInvoiceForEmiScreenState
    extends State<SelectInvoiceForEmiScreen> {
  // ===========================================================================
  // Services
  // ===========================================================================

  late final BillingService _billingService;

  // ===========================================================================
  // State
  // ===========================================================================

  bool _isLoading = true;

  String? _errorMessage;

  List<InvoiceModel> _invoices = const [];

  String _searchQuery = '';

  // ===========================================================================
  // Lifecycle
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _billingService = BillingService();

    _loadInvoices();
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _filteredInvoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Invoice'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInvoices,
        child: CustomScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildSearchField(context),
              ),
            ),

            if (_isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildLoadingState(context),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(context),
              )
            else if (filteredInvoices.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              )
            else ...[
              SliverToBoxAdapter(
                child: _buildResultSummary(
                  context,
                  filteredInvoices.length,
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList.separated(
                  itemCount: filteredInvoices.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(
                      context,
                      filteredInvoices[index],
                    );
                  },
                ),
              ),
            ],
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an invoice',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Select an invoice with an outstanding amount '
            'to create an EMI repayment plan.',
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
  // Search
  // ===========================================================================

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search invoice or customer',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear search',
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  // ===========================================================================
  // Result Summary
  // ===========================================================================

  Widget _buildResultSummary(
    BuildContext context,
    int count,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),

          const SizedBox(width: 7),

          Text(
            '$count ${count == 1 ? 'invoice' : 'invoices'} available',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Invoice Card
  // ===========================================================================

  Widget _buildInvoiceCard(
    BuildContext context,
    InvoiceModel invoice,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _selectInvoice(invoice),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: 0.55,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(
                context,
                invoice,
              ),

              const SizedBox(height: 16),

              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(
                  alpha: 0.45,
                ),
              ),

              const SizedBox(height: 15),

              _buildCustomerInfo(
                context,
                invoice,
              ),

              const SizedBox(height: 16),

              _buildFinancialSummary(
                context,
                invoice,
              ),

              const SizedBox(height: 15),

              _buildSelectAction(
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Invoice Header
  // ===========================================================================

  Widget _buildInvoiceHeader(
    BuildContext context,
    InvoiceModel invoice,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 22,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.invoiceNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _formatDate(invoice.invoiceDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        _buildOutstandingBadge(
          context,
          invoice.dueAmount,
        ),
      ],
    );
  }

  // ===========================================================================
  // Outstanding Badge
  // ===========================================================================

  Widget _buildOutstandingBadge(
    BuildContext context,
    double amount,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(
          alpha: 0.09,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Outstanding',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            _formatCurrency(amount),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Customer
  // ===========================================================================

  Widget _buildCustomerInfo(
    BuildContext context,
    InvoiceModel invoice,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = invoice.customerName.trim();

    if (customerName.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Walk-in Customer',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 18,
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
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Financial Summary
  // ===========================================================================

  Widget _buildFinancialSummary(
    BuildContext context,
    InvoiceModel invoice,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildAmountColumn(
            context,
            label: 'Invoice Total',
            amount: invoice.grandTotal,
          ),
        ),

        _buildVerticalDivider(context),

        Expanded(
          child: _buildAmountColumn(
            context,
            label: 'Paid',
            amount: invoice.paidAmount,
          ),
        ),

        _buildVerticalDivider(context),

        Expanded(
          child: _buildAmountColumn(
            context,
            label: 'Due',
            amount: invoice.dueAmount,
            emphasize: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountColumn(
    BuildContext context, {
    required String label,
    required double amount,
    bool emphasize = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: emphasize
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 34,
      color: colorScheme.outlineVariant.withValues(
        alpha: 0.5,
      ),
    );
  }

  // ===========================================================================
  // Select Action
  // ===========================================================================

  Widget _buildSelectAction(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Create EMI plan',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(width: 5),

        Icon(
          Icons.arrow_forward_rounded,
          size: 18,
          color: colorScheme.primary,
        ),
      ],
    );
  }

  // ===========================================================================
  // Loading
  // ===========================================================================

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Loading invoices...',
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
  // Empty
  // ===========================================================================

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.09,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 32,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              hasSearch
                  ? 'No matching invoices'
                  : 'No invoices available',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              hasSearch
                  ? 'Try searching with a different invoice number '
                      'or customer name.'
                  : 'There are no invoices with an outstanding amount '
                      'available for EMI.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),

            if (hasSearch) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Error
  // ===========================================================================

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: colorScheme.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load invoices',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              _errorMessage ?? 'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: _loadInvoices,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Data
  // ===========================================================================

  Future<void> _loadInvoices() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invoices = await _billingService.getInvoices();

      if (!mounted) {
        return;
      }

      setState(() {
        _invoices = invoices
            .where(_isEligibleForEmi)
            .toList(growable: false);

        _isLoading = false;
      });
    } on BillingException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load invoices. Please try again.';
      });
    }
  }

  // ===========================================================================
  // Eligibility
  // ===========================================================================

  bool _isEligibleForEmi(InvoiceModel invoice) {
  // Invoice must have an outstanding amount.
  if (invoice.dueAmount <= 0) {
    return false;
  }

  final status = invoice.invoiceStatus.trim().toLowerCase();

  // Cancelled invoices cannot be converted to EMI.
  if (status == 'cancelled') {
    return false;
  }

  // Fully returned invoices cannot be converted to EMI.
  if (invoice.isFullyReturned) {
    return false;
  }

  return true;
}

  // ===========================================================================
  // Search
  // ===========================================================================

  List<InvoiceModel> get _filteredInvoices {
    if (_searchQuery.isEmpty) {
      return _invoices;
    }

    return _invoices.where((invoice) {
      final invoiceNumber =
          invoice.invoiceNumber.toLowerCase();

      final customerName =
          invoice.customerName.toLowerCase();

      final customerPhone =
         (invoice.customerPhone ?? '').toLowerCase();

      return invoiceNumber.contains(_searchQuery) ||
          customerName.contains(_searchQuery) ||
          customerPhone.contains(_searchQuery);
    }).toList(growable: false);
  }

  // ===========================================================================
  // Selection
  // ===========================================================================

  Future<void> _selectInvoice(InvoiceModel invoice) async {
    FocusScope.of(context).unfocus();

    if (widget.onInvoiceSelected != null) {
      widget.onInvoiceSelected!(invoice);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEmiPlanScreen(
          invoice: invoice,
        ),
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}