import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/app/theme/app_colors.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice, required this.onTap});

  final InvoiceModel invoice;
  final VoidCallback onTap;

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
              _InvoiceHeader(invoice: invoice),

              const SizedBox(height: 14),

              _CustomerSection(invoice: invoice),

              const SizedBox(height: 14),

              _InvoiceMeta(invoice: invoice),

              const SizedBox(height: 16),

              _InvoiceAmount(invoice: invoice),
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
  const _InvoiceHeader({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

        _PaymentStatusChip(status: invoice.paymentStatus),

        const SizedBox(width: 8),

        Icon(
          Icons.chevron_right_rounded,
          size: 22,
          color: theme.colorScheme.outline,
        ),
      ],
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
            fontWeight: FontWeight.w600,
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
                color: theme.colorScheme.outline,
              ),

              const SizedBox(width: 6),

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
          color: theme.colorScheme.outline,
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
          color: theme.colorScheme.outline,
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
  const _InvoiceAmount({required this.invoice});

  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasDue = invoice.dueAmount > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              Text(
                _formatCurrency(invoice.grandTotal),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

                const SizedBox(height: 4),

              Text(
                'Total Amount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

         
            ],
          ),
        ),

        if (hasDue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Due ${_formatCurrency(invoice.dueAmount)}',
              style: TextStyle(
                color:AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Paid',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

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

Color _paymentStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return AppColors.success;

    case 'partial':
      return AppColors.warning;

    case 'unpaid':
      return AppColors.error;

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

    default:
      return Colors.grey.shade200;
  }
}

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

    default:
      return method;
  }
}
