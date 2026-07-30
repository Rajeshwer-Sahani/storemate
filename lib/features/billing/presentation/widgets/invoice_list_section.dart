import 'package:flutter/material.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_empty_state.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_loading.dart';

class InvoiceListSection extends StatelessWidget {
  const InvoiceListSection({
    super.key,
    required this.isLoading,
    required this.invoices,
    required this.onRefresh,
    required this.onCreateInvoice,
    required this.onInvoiceTap,
  });

  final bool isLoading;
  final List<InvoiceModel> invoices;

  final Future<void> Function() onRefresh;
  final VoidCallback onCreateInvoice;
  final ValueChanged<InvoiceModel> onInvoiceTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const InvoiceLoading();
    }

    if (invoices.isEmpty) {
      return InvoiceEmptyState(
        onRefresh: onRefresh,
        onCreateInvoice: onCreateInvoice,
      );
    }

    return Column(
      children: List.generate(
        invoices.length,
        (index) {
          final invoice = invoices[index];

          return Padding(
            padding: EdgeInsets.only(
              bottom: index == invoices.length - 1 ? 0 : 12,
            ),
            child: InvoiceCard(
              invoice: invoice,
              onTap: () => onInvoiceTap(invoice),
            ),
          );
        },
      ),
    );
  }
}