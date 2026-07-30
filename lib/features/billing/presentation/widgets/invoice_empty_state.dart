import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/%20app_refreshable_empty_state.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';

class InvoiceEmptyState extends StatelessWidget {
  const InvoiceEmptyState({
    super.key,
    required this.onCreateInvoice,
    required this.onRefresh,
  });

  final VoidCallback onCreateInvoice;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: AppRefreshableEmptyState(
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No invoices yet',
          message:
              'Your created invoices will appear here.\n'
              'Create your first invoice to start recording sales.',
          buttonText: 'Create Invoice',
          onPressed: onCreateInvoice,
        ),
      ),
    );
  }
}