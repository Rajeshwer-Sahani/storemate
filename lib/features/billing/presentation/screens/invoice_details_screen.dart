import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  // App Bar
  //---------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  // App Bar
  //--------------------------------------------------------------------------

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: .45),
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.arrow_back_rounded, size: 28),
              ),

              const SizedBox(width: 12),

              const SizedBox(width: 4),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Invoice Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (_invoice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          _invoice!.invoiceNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'More',
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
        ),
      ),
    );
  }
  //---------------------------------------------------------------------------
  // Build
  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      onRefresh: _loadInvoice,
      child: Column(
        children: [
          _buildAppBar(),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------
  // Body
  //---------------------------------------------------------------------------

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_invoice == null) {
      return _buildNotFoundState();
    }

    //==========================
    // PART 2 STARTS HERE
    //==========================

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceHeader(),

                const SizedBox(height: 18),

                _buildCustomerSection(),

                _buildProductsSection(),

                _buildSummarySection(),

                _buildPaymentSection(),

                _buildNotesSection(),
              ],
            ),
          ),
        ),
        InvoiceBottomBar(
          grandTotal: _invoice!.grandTotal,
          buttonText: 'Print Invoice',
          buttonIcon: Icons.print_rounded,
          onPressed: _printInvoice,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const InvoiceLoading(itemCount: 5);
  }

  Widget _buildErrorState() {
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

  Widget _buildNotFoundState() {
    return const Center(child: Text('Invoice not found'));
  }

  //---------------------------------------------------------------------
  // Invoice Header
  //---------------------------------------------------------------------

  Widget _buildInvoiceHeader() {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: .18),
            blurRadius: 18,
            spreadRadius: -2,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //-------------------------------------------------------------
          // Top Row
          //-------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: Text(
                  _invoice!.invoiceNumber,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 12,
              //     vertical: 6,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withValues(alpha: .18),
              //     borderRadius: BorderRadius.circular(30),
              //   ),
              //   child: Text(
              //     _formatPaymentMethod(_invoice!.invoiceStatus),
              //     style: theme.textTheme.labelMedium?.copyWith(
              //       color: Colors.white,
              //       fontWeight: FontWeight.w700,
              //     ),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 18),

          //-------------------------------------------------------------
          // Information Row
          //-------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _buildHeaderItem(
                  title: 'Invoice Date',
                  value: DateFormat(
                    'dd MMM yyyy',
                  ).format(_invoice!.invoiceDate),
                ),
              ),

              Expanded(
                child: _buildHeaderItem(
                  title: 'Payment',
                  value: _invoice!.paymentMethod,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          //-------------------------------------------------------------
          // Payment Status
          //-------------------------------------------------------------
          Builder(
            builder: (_) {
              final bool hasDue = _invoice!.dueAmount > 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: hasDue
                          ? Colors.orange.withValues(alpha: .22)
                          : Colors.green.withValues(alpha: .22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasDue
                            ? Colors.orange.withValues(alpha: .45)
                            : Colors.green.withValues(alpha: .45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasDue
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: Colors.white,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          hasDue
                              ? formatCurrency(_invoice!.dueAmount)
                              : 'No Due Amount',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Widget _buildHeaderItem({required String title, required String value}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  //---------------------------------------------------------------------
  // Customer
  //---------------------------------------------------------------------
  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Customer'),

        const SizedBox(height: 10),

        InvoiceCustomerCard(
          customerName: _invoice!.customerName,
          customerPhone: _invoice!.customerPhone,
          showActionButton: false,
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  //---------------------------------------------------------------------
  // Products
  //---------------------------------------------------------------------
  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Products',
          trailing: Text(
            '${_items.length} item${_items.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = _items[index];

            final subtitle = [
              if (item.productSku != null && item.productSku!.trim().isNotEmpty)
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

        const SizedBox(height: 18),
      ],
    );
  }

  //---------------------------------------------------------------------
  // Summary
  //---------------------------------------------------------------------
  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Summary'),

        const SizedBox(height: 12),

        InvoiceSummaryCard(
          subtotal: _invoice!.subtotal,
          discount: _invoice!.discount,
          tax: _invoice!.tax,
          grandTotal: _invoice!.grandTotal,
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  //---------------------------------------------------------------------
  // Payment
  //---------------------------------------------------------------------
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Payment'),

        const SizedBox(height: 12),

        InvoicePaymentCard(
          readOnly: true,
          paymentMethod: _invoice!.paymentMethod,
          paidAmount: _invoice!.paidAmount,
          grandTotal: _invoice!.grandTotal,
          dueAmount: _invoice!.dueAmount,
        ),

        const SizedBox(height: 18),
      ],
    );
  }

  final _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String formatCurrency(num value) {
    return _currencyFormatter.format(value);
  }

  //---------------------------------------------------------------------
  // Notes
  //---------------------------------------------------------------------
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Notes'),

        const SizedBox(height: 12),

        InvoiceNotesCard(readOnly: true, initialValue: _invoice!.notes),
      ],
    );
  }
}
