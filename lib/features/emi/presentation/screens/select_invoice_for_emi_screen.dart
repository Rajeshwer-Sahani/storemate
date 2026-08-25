import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_search_field.dart';

import '../../../../features/billing/data/models/invoice_model.dart';
import '../../../../features/billing/data/services/billing_service.dart';


class SelectInvoiceForEmiScreen extends StatefulWidget {
  const SelectInvoiceForEmiScreen({super.key, this.onInvoiceSelected});

  final ValueChanged<InvoiceModel>? onInvoiceSelected;

  @override
  State<SelectInvoiceForEmiScreen> createState() =>
      _SelectInvoiceForEmiScreenState();
}

class _SelectInvoiceForEmiScreenState extends State<SelectInvoiceForEmiScreen> {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: EdgeInsets.zero,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _buildHeader(context),

          _buildHowItWorks(context),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: AppSearchField(
              hintText: 'Search by invoice or customer',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // ================================================================
          // Invoice content
          // ================================================================
          if (_isLoading)
            SizedBox(height: 220, child: _buildLoadingState(context))
          else if (_errorMessage != null)
            SizedBox(height: 300, child: _buildErrorState(context))
          else if (_filteredInvoices.isEmpty)
            SizedBox(height: 300, child: _buildEmptyState(context))
          else ...[
            _buildSectionHeader(context, _filteredInvoices.length),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  for (int i = 0; i < _filteredInvoices.length; i++) ...[
                    _buildInvoiceCard(context, _filteredInvoices[i]),

                    if (i != _filteredInvoices.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),

            _buildEligibilityInfo(context),

            _buildSecurityFooter(context),

            const SizedBox(height: 20),
          ],
        ],
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
        'Select Invoice for EMI',
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an invoice',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select an invoice with an outstanding amount '
            'to create an EMI repayment plan.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
              letterSpacing: -0.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // How It Works
  // ===========================================================================

  Widget _buildHowItWorks(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: colorScheme.onPrimary,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Only invoices with an outstanding amount '
                    'are eligible for EMI. Fully paid, cancelled, '
                    'or returned invoices cannot be selected.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Small invoice illustration
            _buildInvoiceIllustration(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceIllustration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 50,
      height: 64,
      child: Stack(
        children: [
          Positioned(
            left: 5,
            top: 2,
            child: Container(
              width: 38,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: colorScheme.primary,
                size: 26,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Icon(
                Icons.check_rounded,
                color: colorScheme.onPrimary,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Section Header
  // ===========================================================================

  Widget _buildSectionHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Eligible Invoices',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$count ${count == 1 ? 'invoice' : 'invoices'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Invoice Card
  // ===========================================================================

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _selectInvoice(invoice),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              children: [
                // -----------------------------------------------------------------
                // Header
                // -----------------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInvoiceIcon(context),

                    const SizedBox(width: 12),

                    Expanded(child: _buildInvoiceIdentity(context, invoice)),

                    const SizedBox(width: 10),

                    Icon(
                      Icons.chevron_right_rounded,
                      size: 25,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // -----------------------------------------------------------------
                // Outstanding Amount
                // -----------------------------------------------------------------
                _buildOutstandingAmount(context, invoice),

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),

                const SizedBox(height: 12),

                // -----------------------------------------------------------------
                // Financial Summary
                // -----------------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialValue(
                        context,
                        label: 'Total Amount',
                        amount: invoice.grandTotal,
                      ),
                    ),

                    _buildVerticalDivider(context),

                    Expanded(
                      child: _buildFinancialValue(
                        context,
                        label: 'Paid Amount',
                        amount: invoice.paidAmount,
                        valueColor: colorScheme.primary,
                      ),
                    ),

                    _buildVerticalDivider(context),

                    Expanded(
                      child: _buildFinancialValue(
                        context,
                        label: 'Outstanding',
                        amount: invoice.dueAmount,
                        valueColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                // -----------------------------------------------------------------
                // Status + CTA
                // -----------------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPaymentStatusBadge(context, invoice),

                    const Spacer(),

                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _selectInvoice(invoice),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Create EMI plan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 19,
                                color: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Invoice Icon
  // ===========================================================================

  Widget _buildInvoiceIcon(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        color: Colors.blue.shade700,
        size: 25,
      ),
    );
  }

  // ===========================================================================
  // Invoice Identity
  // ===========================================================================

  Widget _buildInvoiceIdentity(BuildContext context, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = invoice.customerName.trim().isEmpty
        ? 'Walk-in Customer'
        : invoice.customerName.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invoice number
        Text(
          invoice.invoiceNumber,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 4),

        // Customer name
        Text(
          customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        // Phone + Date
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            if (invoice.customerPhone != null &&
                invoice.customerPhone!.trim().isNotEmpty)
              _buildInvoiceMetaItem(
                context,
                icon: Icons.phone_outlined,
                text: invoice.customerPhone!.trim(),
              ),

            _buildInvoiceMetaItem(
              context,
              icon: Icons.calendar_today_outlined,
              text: _formatDate(invoice.invoiceDate),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // Invoice Meta Item
  // ===========================================================================

  Widget _buildInvoiceMetaItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Outstanding Amount
  // ===========================================================================

  Widget _buildOutstandingAmount(BuildContext context, InvoiceModel invoice) {
    final theme = Theme.of(context);

    final valueColor = Colors.green.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: valueColor,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'Outstanding Amount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            _formatCurrency(invoice.dueAmount),
            style: theme.textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Financial Value
  // ===========================================================================

  Widget _buildFinancialValue(
    BuildContext context, {
    required String label,
    required double amount,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w800,
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
      height: 32,
      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
    );
  }

  // ===========================================================================
  // Payment Status
  // ===========================================================================

  Widget _buildPaymentStatusBadge(BuildContext context, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUnpaid = invoice.paidAmount <= 0;

    final statusColor = isUnpaid ? colorScheme.error : Colors.amber.shade700;

    final statusBackground = statusColor.withValues(alpha: 0.09);

    final label = isUnpaid ? 'Unpaid' : 'Partially Paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Not Eligible Badge
  // ===========================================================================

  Widget _buildNotEligibleBadge(BuildContext context, InvoiceModel invoice) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Not Eligible',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ===========================================================================
  // Eligibility Information
  // ===========================================================================

  Widget _buildEligibilityInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accentColor = Colors.orange.shade800;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------------------------
            // Header
            // -------------------------------------------------------------------
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: accentColor,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Why some invoices are not eligible?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            // -------------------------------------------------------------------
            // Description
            // -------------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(left: 37),
              child: Text(
                'Fully paid, cancelled, or fully returned invoices '
                'cannot be converted into EMI plans.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // -------------------------------------------------------------------
            // Learn More
            // -------------------------------------------------------------------
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: _showHelpDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: Colors.orange.withValues(alpha: 0.40),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Security Footer
  // ===========================================================================

  Widget _buildSecurityFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 15,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'Your financial data is secure and encrypted.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Loading
  // ===========================================================================

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading invoices...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 30,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              hasSearch ? 'No matching invoices' : 'No eligible invoices',
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
                  : 'There are no invoices with an outstanding '
                        'amount available for EMI.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),

            if (hasSearch) ...[
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 30,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadInvoices,
              icon: const Icon(Icons.refresh_rounded, size: 18),
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

      final eligibleInvoices = invoices
          .where(_isEligibleForEmi)
          .toList(growable: false);

      setState(() {
        _invoices = eligibleInvoices;
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load invoices. Please try again.';
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
  // Filtered Invoices
  // ===========================================================================

  // ===========================================================================
  // Filtered Invoices
  // ===========================================================================

  List<InvoiceModel> get _filteredInvoices {
    if (_searchQuery.isEmpty) {
      return _invoices;
    }

    return _invoices
        .where((invoice) {
          final invoiceNumber = invoice.invoiceNumber.toLowerCase();

          final customerName = invoice.customerName.toLowerCase();

          final customerPhone = (invoice.customerPhone ?? '').toLowerCase();

          return invoiceNumber.contains(_searchQuery) ||
              customerName.contains(_searchQuery) ||
              customerPhone.contains(_searchQuery);
        })
        .toList(growable: false);
  }

  // ===========================================================================
  // Selection
  // ===========================================================================

  void _selectInvoice(InvoiceModel invoice) {
    FocusScope.of(context).unfocus();

    if (widget.onInvoiceSelected != null) {
      widget.onInvoiceSelected!(invoice);
      return;
    }

    Navigator.of(context).pop<InvoiceModel>(invoice);
  }

  // ===========================================================================
  // Help
  // ===========================================================================

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('EMI Invoice Eligibility'),
          content: const Text(
            'An invoice can be converted into an EMI plan '
            'when it has an outstanding amount and is not '
            'cancelled or fully returned.\n\n'
            'Partially paid invoices are also eligible because '
            'the remaining outstanding amount can be converted '
            'into an EMI plan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Not Eligible Reason
  // ===========================================================================

  void _showNotEligibleReason(InvoiceModel invoice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String reason;

    if (invoice.dueAmount <= 0) {
      reason = 'This invoice has no outstanding amount remaining.';
    } else if (invoice.invoiceStatus.trim().toLowerCase() == 'cancelled') {
      reason = 'Cancelled invoices cannot be converted into EMI plans.';
    } else if (invoice.isFullyReturned) {
      reason = 'Fully returned invoices cannot be converted into EMI plans.';
    } else {
      reason = 'This invoice is currently not eligible for EMI.';
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colorScheme.error),
              const SizedBox(width: 8),
              const Expanded(child: Text('Invoice not eligible')),
            ],
          ),
          content: Text(
            '${invoice.invoiceNumber}\n\n$reason',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
