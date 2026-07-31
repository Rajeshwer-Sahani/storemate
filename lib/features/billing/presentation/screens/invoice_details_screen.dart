import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_section_header.dart';

import 'package:storemate/features/billing/data/models/invoice_item_model.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';

import 'package:storemate/features/billing/presentation/widgets/invoice_bottom_bar.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_customer_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_item_tile.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_loading.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_notes_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_payment_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_summary_card.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final BillingService _billingService = BillingService();

  InvoiceModel? _invoice;

  List<InvoiceItemModel> _items = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  //---------------------------------------------------------------------------
  // Load Invoice
  //---------------------------------------------------------------------------

  Future<void> _loadInvoice() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final invoice = await _billingService.getInvoiceById(widget.invoiceId);

      final items = await _billingService.getInvoiceItems(widget.invoiceId);

      if (!mounted) return;

      setState(() {
        _invoice = invoice;
        _items = items;
        _isLoading = false;
      });
    } on BillingException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Something went wrong.\nPlease try again.';
        _isLoading = false;
      });
    }
  }

  //---------------------------------------------------------------------------
  // Actions
  //---------------------------------------------------------------------------

  void _onMenuSelected(String value) {
    switch (value) {
      case 'print':
        _printInvoice();
        break;

      case 'share':
        _shareInvoice();
        break;

      case 'download':
        _downloadPdf();
        break;

      case 'edit':
        _editInvoice();
        break;
    }
  }

  Future<void> _printInvoice() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print Invoice will be available soon.')),
    );
  }

  Future<void> _shareInvoice() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Invoice will be available soon.')),
    );
  }

  Future<void> _downloadPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download PDF will be available soon.')),
    );
  }

  void _editInvoice() {
    // TODO:
    // Navigate to EditInvoiceScreen when it is implemented.
  }

  //---------------------------------------------------------------------------
  // Build
  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      onRefresh: _loadInvoice,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Details'),
          centerTitle: false,
          actions: [
            PopupMenuButton<String>(
              onSelected: _onMenuSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'print', child: Text('Print Invoice')),
                PopupMenuItem(value: 'share', child: Text('Share Invoice')),
                PopupMenuItem(value: 'download', child: Text('Download PDF')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'edit', child: Text('Edit Invoice')),
              ],
            ),
          ],
        ),

        body: _buildBody(),
      ),
    );
  }

  //---------------------------------------------------------------------------
  // Body
  //---------------------------------------------------------------------------

  Widget _buildBody() {
    if (_isLoading) {
      return const InvoiceLoading(itemCount: 5);
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 72),

              const SizedBox(height: 20),

              Text(
                'Unable to load invoice',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              Text(_errorMessage!, textAlign: TextAlign.center),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _loadInvoice,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_invoice == null) {
      return const Center(child: Text('Invoice not found'));
    }

    //==========================
    // PART 2 STARTS HERE
    //==========================

    return Scaffold(
      bottomNavigationBar: InvoiceBottomBar(
        grandTotal: _invoice!.grandTotal,
        buttonText: 'Print Invoice',
        buttonIcon: Icons.print_rounded,
        onPressed: _printInvoice,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //---------------------------------------------------------------------
            // Invoice Header
            //---------------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _invoice!.invoiceNumber,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Invoice Date',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: .7),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${_invoice!.invoiceDate.day}/${_invoice!.invoiceDate.month}/${_invoice!.invoiceDate.year}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            //---------------------------------------------------------------------
            // Customer
            //---------------------------------------------------------------------
            const AppSectionHeader(title: 'Customer'),

            const SizedBox(height: 12),

            InvoiceCustomerCard(
              customerName: _invoice!.customerName,
              customerPhone: _invoice!.customerPhone,
              showActionButton: false,
            ),

            const SizedBox(height: 28),

            //---------------------------------------------------------------------
            // Products
            //---------------------------------------------------------------------
            AppSectionHeader(
              title: 'Products',
              trailing: Text(
                '${_items.length} item${_items.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),

            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _items[index];

                final subtitle = [
                  if (item.productSku != null &&
                      item.productSku!.trim().isNotEmpty)
                    item.productSku,
                  if (item.productCategory != null &&
                      item.productCategory!.trim().isNotEmpty)
                    item.productCategory,
                ].whereType<String>().join(' • ');

                return InvoiceItemTile(
                  editable: false,
                  productName: item.productName,
                  subtitle: subtitle.isEmpty ? null : subtitle,
                  quantity: item.quantity,
                  unitPrice: item.sellingPrice,
                  totalPrice: item.lineTotal,
                );
              },
            ),

            const SizedBox(height: 28),

            //---------------------------------------------------------------------
            // Summary
            //---------------------------------------------------------------------
            const AppSectionHeader(title: 'Summary'),

            const SizedBox(height: 12),

            InvoiceSummaryCard(
              subtotal: _invoice!.subtotal,
              discount: _invoice!.discount,
              tax: _invoice!.tax,
              grandTotal: _invoice!.grandTotal,
            ),

            const SizedBox(height: 28),

            //---------------------------------------------------------------------
            // Payment
            //---------------------------------------------------------------------
            const AppSectionHeader(title: 'Payment'),

            const SizedBox(height: 12),

            InvoicePaymentCard(
              readOnly: true,
              paymentMethod: _invoice!.paymentMethod,
              paidAmount: _invoice!.paidAmount,
              grandTotal: _invoice!.grandTotal,
              dueAmount: _invoice!.dueAmount,
            ),

            const SizedBox(height: 28),

            //---------------------------------------------------------------------
            // Notes
            //---------------------------------------------------------------------
            const AppSectionHeader(title: 'Notes'),

            const SizedBox(height: 12),

            InvoiceNotesCard(readOnly: true, initialValue: _invoice!.notes),
          ],
        ),
      ),
    );
  }
}
