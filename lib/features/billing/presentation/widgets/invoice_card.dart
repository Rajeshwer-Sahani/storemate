import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/app/theme/app_colors.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/presentation/utils/invoice_financial_calculator.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice, required this.onTap});

  final InvoiceModel invoice;
  final VoidCallback onTap;

  // An invoice is treated as an EMI invoice only when
  // an actual EMI plan is associated with it.
  bool get isEmi => invoice.hasEmiPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InvoiceHeader(invoice: invoice, isEmi: isEmi),

              const SizedBox(height: 14),

              Divider(
                height: 1,
                thickness: .8,
                color: colorScheme.outlineVariant.withValues(alpha: .55),
              ),

              const SizedBox(height: 16),

              _CustomerSection(invoice: invoice),

              const SizedBox(height: 12),

              _InvoiceMeta(invoice: invoice),

              const SizedBox(height: 16),

              Divider(
                height: 1,
                thickness: .8,
                color: colorScheme.outlineVariant.withValues(alpha: .55),
              ),

              const SizedBox(height: 16),

              _InvoiceAmount(invoice: invoice, isEmi: isEmi),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// Invoice Header
/// ===========================================================================

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({required this.invoice, required this.isEmi});

  final InvoiceModel invoice;
  final bool isEmi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            invoice.invoiceNumber,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: .3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 12),

        if (isEmi)
          const _EmiPlanAction()
        else
          _PaymentStatusChip(status: invoice.displayStatus),

        const SizedBox(width: 8),

        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: isEmi
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
        ),
      ],
    );
  }
}

/// ===========================================================================
/// EMI Plan Action
/// ===========================================================================

class _EmiPlanAction extends StatelessWidget {
  const _EmiPlanAction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      'EMI PLAN',
      style: theme.textTheme.labelMedium?.copyWith(
        color: colorScheme.secondary,
        fontWeight: FontWeight.w700,
        letterSpacing: .5,
      ),
    );
  }
}

/// ===========================================================================
/// Customer Section
/// ===========================================================================

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.customerName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (invoice.customerPhone != null &&
            invoice.customerPhone!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(
                Icons.call_outlined,
                size: 16,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  invoice.customerPhone!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// ===========================================================================
/// Invoice Meta
/// ===========================================================================

class _InvoiceMeta extends StatelessWidget {
  const _InvoiceMeta({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.schedule_outlined,
          size: 16,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(width: 6),

        Text(
          _formatDate(invoice.invoiceDate),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 14),

        Icon(
          _paymentMethodIcon(invoice.paymentMethod),
          size: 16,
          color: theme.colorScheme.primary,
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            _paymentMethodLabel(invoice.paymentMethod),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// Invoice Amount
/// ===========================================================================

class _InvoiceAmount extends StatelessWidget {
  const _InvoiceAmount({required this.invoice, required this.isEmi});

  final InvoiceModel invoice;
  final bool isEmi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // -------------------------------------------------------------------------
    // Financial calculation
    // -------------------------------------------------------------------------
    //
    // Keep the existing return-aware financial calculation.
    //
    // This is still the invoice's financial value.
    //
    final financial = InvoiceFinancialCalculator.calculate(
      originalAmount: invoice.grandTotal,
      returnedAmount: invoice.returnedAmount,
      paidAmount: invoice.paidAmount,
      refundedAmount: 0,
    );

    // -------------------------------------------------------------------------
    // EMI Invoice
    // -------------------------------------------------------------------------
    //
    // EMI payments are managed through the EMI plan.
    //
    // Therefore the billing card must NOT show:
    // - Paid
    // - Due
    // - normal invoice payment status
    //
    // It only displays the invoice amount.
    // -------------------------------------------------------------------------

    if (isEmi) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatCurrency(financial.netInvoiceAmount),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Total Amount',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // -------------------------------------------------------------------------
    // Normal Invoice
    // -------------------------------------------------------------------------

    final status = invoice.displayStatus;

    final isReturned = status == 'returned';
    final isPartiallyReturned = status == 'partially_returned';

    // -------------------------------------------------------------------------
    // Fully Returned
    // -------------------------------------------------------------------------

    if (isReturned) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCurrency(financial.netInvoiceAmount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Net Amount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const _StatusAmountBadge(label: 'Returned', color: AppColors.primary),
        ],
      );
    }

    // -------------------------------------------------------------------------
    // Partially Returned
    // -------------------------------------------------------------------------

    if (isPartiallyReturned) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCurrency(financial.netInvoiceAmount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Net Amount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const _StatusAmountBadge(
            label: 'Partially Returned',
            color: AppColors.warning,
          ),
        ],
      );
    }

    // -------------------------------------------------------------------------
    // Normal Invoice
    // -------------------------------------------------------------------------

    final hasDue = financial.hasAmountDue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatCurrency(financial.netInvoiceAmount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Total Amount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (hasDue)
          _StatusAmountBadge(
            label: 'Due ${_formatCurrency(financial.amountDue)}',
            color: AppColors.error,
          )
        else
          const _StatusAmountBadge(label: 'Paid', color: AppColors.success),
      ],
    );
  }
}

/// ===========================================================================
/// Status Amount Badge
/// ===========================================================================

class _StatusAmountBadge extends StatelessWidget {
  const _StatusAmountBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// ===========================================================================
/// Payment Status Chip
/// ===========================================================================

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _paymentStatusColor(status);
    final backgroundColor = _paymentStatusBackgroundColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

/// ===========================================================================
/// Formatting
/// ===========================================================================

String _formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  return formatter.format(amount);
}

String _formatDate(DateTime date) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);

  final invoiceDate = DateTime(date.year, date.month, date.day);

  final difference = today.difference(invoiceDate).inDays;

  if (difference == 0) {
    return 'Today';
  }

  if (difference == 1) {
    return 'Yesterday';
  }

  return DateFormat('dd MMM yyyy').format(date);
}

/// ===========================================================================
/// Payment Status Colors
/// ===========================================================================

Color _paymentStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return AppColors.success;

    case 'partial':
      return AppColors.warning;

    case 'unpaid':
      return AppColors.error;

    case 'partially_returned':
      return AppColors.warning;

    case 'returned':
      return AppColors.primary;

    default:
      return Colors.grey.shade700;
  }
}

Color _paymentStatusBackgroundColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return Colors.green.shade50;

    case 'partial':
      return Colors.orange.shade50;

    case 'unpaid':
      return Colors.red.shade50;

    case 'partially_returned':
      return Colors.orange.shade50;

    case 'returned':
      return Colors.blue.shade50;

    default:
      return Colors.grey.shade200;
  }
}

/// ===========================================================================
/// Payment Method
/// ===========================================================================

IconData _paymentMethodIcon(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return Icons.payments_rounded;

    case 'upi':
      return Icons.qr_code_rounded;

    case 'card':
      return Icons.credit_card_rounded;

    case 'bank transfer':
      return Icons.account_balance_rounded;

    case 'cheque':
      return Icons.receipt_long_rounded;

    case 'emi':
      return Icons.event_repeat_rounded;

    default:
      return Icons.wallet_rounded;
  }
}

String _paymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return 'Cash';

    case 'upi':
      return 'UPI';

    case 'card':
      return 'Card';

    case 'bank transfer':
      return 'Bank Transfer';

    case 'cheque':
      return 'Cheque';

    case 'emi':
      return 'EMI';

    default:
      return method;
  }
}
