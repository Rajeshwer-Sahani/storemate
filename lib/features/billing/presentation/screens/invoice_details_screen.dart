import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_section_header.dart';

import 'package:storemate/features/billing/data/models/invoice_item_model.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/models/invoice_timeline_model.dart';
import 'package:storemate/features/billing/data/models/payment_history_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/data/services/invoice_download_service.dart';
import 'package:storemate/features/billing/data/services/invoice_pdf_service.dart';
import 'package:storemate/features/billing/data/services/invoice_return_service.dart';
import 'package:storemate/features/billing/presentation/screens/edit_invoice_screen.dart';
import 'package:storemate/features/billing/presentation/screens/invoice_return_screen.dart';
import 'package:storemate/features/billing/presentation/screens/invoice_timeline_screen.dart';
import 'package:storemate/features/billing/presentation/utils/invoice_financial_calculator.dart';
import 'package:storemate/features/billing/presentation/widgets/delete_invoice_dialog.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_action_menu.dart';

import 'package:storemate/features/billing/presentation/widgets/invoice_bottom_bar.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_customer_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_item_tile.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_loading.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_notes_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_payment_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_payment_history_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_summary_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_timeline_card.dart';
import 'package:storemate/features/billing/presentation/widgets/receive_payment_bottom_sheet.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final BillingService _billingService = BillingService();
  final InvoiceReturnService _invoiceReturnService = InvoiceReturnService();
  final InvoicePdfService _pdfService = InvoicePdfService();
  final InvoiceDownloadService _downloadService =
      const InvoiceDownloadService();

  InvoiceModel? _invoice;

  List<InvoiceItemModel> _items = [];

  List<InvoiceTimelineModel> _timeline = [];

  // ============================================================================
  // Payment History
  // ============================================================================

  List<PaymentHistoryModel> _paymentHistory = [];

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

      _invoice = invoice;
      _items = items;

      await Future.wait([_loadPaymentHistory(), _loadTimeline()]);

      if (!mounted) return;

      setState(() {
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
  // Load Invoice Timeline
  //---------------------------------------------------------------------------
  Future<void> _loadTimeline() async {
    try {
      _timeline = await _billingService.getInvoiceTimeline(widget.invoiceId);
    } on BillingException {
      _timeline = [];
    } catch (_) {
      _timeline = [];
    }
  }

  //---------------------------------------------------------------------------
  // Actions
  //---------------------------------------------------------------------------

  void _onMenuSelected(InvoiceAction action) {
    switch (action) {
      case InvoiceAction.print:
        _printInvoice();
        break;

      case InvoiceAction.downloadPdf:
        _downloadPdf();
        break;

      case InvoiceAction.timeline:
        _openTimeline();
        break;

      case InvoiceAction.edit:
        _editInvoice();
        break;

      case InvoiceAction.receivePayment:
        _receivePayment();
        break;

      case InvoiceAction.returnInvoice:
        _returnInvoice();
        break;

      case InvoiceAction.delete:
        _deleteInvoice();
        break;
    }
  }

  //---------------------------------------------------------------------------
  // Print Invoice
  //---------------------------------------------------------------------------

  Future<void> _printInvoice() async {
    if (_invoice == null) return;

    try {
      final store = await _billingService.getCurrentStore();

      final pdfBytes = await _pdfService.generateInvoicePdf(
        store: store,
        invoice: _invoice!,
        items: _items,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: _invoice!.invoiceNumber,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to print invoice.\n$e')));
    }
  }

  //---------------------------------------------------------------------------
  // Download PDF
  //---------------------------------------------------------------------------

  Future<void> _downloadPdf() async {
    try {
      if (_invoice == null) return;

      final invoiceItems = await _billingService.getInvoiceItems(_invoice!.id);

      final store = await _billingService.getCurrentStore();

      final pdfBytes = await _pdfService.generateInvoicePdf(
        invoice: _invoice!,
        items: invoiceItems,
        store: store,
      );

      final File pdfFile = await _downloadService.saveInvoicePdf(
        pdfBytes: pdfBytes,
        invoiceNumber: _invoice!.invoiceNumber,
      );

      await _downloadService.openPdf(pdfFile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_invoice!.invoiceNumber}.pdf downloaded successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download PDF.\n$e')));
    }
  }

  //---------------------------------------------------------------------------
  // Open Timeline
  //---------------------------------------------------------------------------

  void _openTimeline() {
    if (_invoice == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InvoiceTimelineScreen(
          invoiceNumber: _invoice!.invoiceNumber,
          timeline: _timeline,
        ),
      ),
    );
  }
  //---------------------------------------------------------------------------
  // Share Invoice
  //---------------------------------------------------------------------------

  Future<void> _shareInvoice() async {
    try {
      if (_invoice == null) return;

      final store = await _billingService.getCurrentStore();

      final pdfBytes = await _pdfService.generateInvoicePdf(
        store: store,
        invoice: _invoice!,
        items: _items,
      );

      final file = await _downloadService.saveInvoicePdf(
        pdfBytes: pdfBytes,
        invoiceNumber: _invoice!.invoiceNumber,
      );

      await _downloadService.sharePdf(file);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share invoice.\n$e')));
    }
  }

  //---------------------------------------------------------------------------
  // Edit Invoice
  //---------------------------------------------------------------------------

  Future<void> _editInvoice() async {
    if (_invoice == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditInvoiceScreen(invoice: _invoice!)),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadInvoice();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice updated successfully.')),
      );

      // Notify BillingScreen that something changed
      Navigator.pop(context, true);
    }
  }

  //---------------------------------------------------------------------------
  // Receive Payment
  //---------------------------------------------------------------------------

  Future<void> _receivePayment() async {
    if (_invoice == null) return;

    // Don't allow payment if already fully paid.
    if (_invoice!.paymentStatus.toLowerCase() == 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This invoice has already been fully paid.'),
        ),
      );
      return;
    }

    final received = await ReceivePaymentBottomSheet.show(
      context,
      billingService: _billingService,
      invoice: _invoice!,
    );

    if (!mounted || received != true) {
      return;
    }

    await _loadInvoice();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment received successfully.')),
    );
    // Notify BillingScreen so its invoice list refreshes.
    Navigator.pop(context, true);
  }

  //---------------------------------------------------------------------------
  // Return Invoice
  //---------------------------------------------------------------------------
  Future<void> _returnInvoice() async {
    if (_invoice == null) return;

    try {
      // Check whether any quantity is still available for return.
      final returnableItems = await _invoiceReturnService.getReturnableItems(
        _invoice!.id,
      );

      if (!mounted) return;

      // All invoice quantities have already been returned.
      if (returnableItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'All items in this invoice have already been returned.',
            ),
          ),
        );
        return;
      }

      // At least one item is still returnable.
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceReturnScreen(invoice: _invoice!),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        await _loadInvoice();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice returned successfully.')),
        );

        // Notify BillingScreen that the invoice has changed.
        Navigator.pop(context, true);
      }
    } on InvoiceReturnException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to check return availability. Please try again.',
          ),
        ),
      );
    }
  }

  //---------------------------------------------------------------------------
  // Delete Invoice
  //---------------------------------------------------------------------------
  Future<void> _deleteInvoice() async {
    if (_invoice == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteInvoiceDialog(
        invoiceNumber: _invoice!.invoiceNumber,
        onDelete: () => Navigator.pop(context, true),
      ),
    );

    if (shouldDelete != true) return;

    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      await _billingService.deleteInvoice(_invoice!.id);

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully.')),
      );
    } on BillingException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete invoice. Please try again.'),
        ),
      );
    }
  }

  // ============================================================================
  // Return-aware calculations
  // ============================================================================

  int get _totalSoldQuantity {
    return _items.fold<int>(0, (total, item) => total + item.quantity);
  }

  int get _totalReturnedQuantity {
    return _items.fold<int>(0, (total, item) => total + item.returnedQuantity);
  }

  int get _totalRemainingQuantity {
    return _items.fold<int>(0, (total, item) {
      final remaining = item.quantity - item.returnedQuantity;
      return total + (remaining < 0 ? 0 : remaining);
    });
  }

  bool get _hasReturns {
    return _totalReturnedQuantity > 0;
  }

  bool get _isFullyReturned {
    return _totalSoldQuantity > 0 &&
        _totalReturnedQuantity >= _totalSoldQuantity;
  }

  double _itemOriginalAmount(InvoiceItemModel item) {
    return item.sellingPrice * item.quantity;
  }

  double _itemReturnedAmount(InvoiceItemModel item) {
    return item.sellingPrice * item.returnedQuantity;
  }

  double _itemNetAmount(InvoiceItemModel item) {
    return _itemOriginalAmount(item) - _itemReturnedAmount(item);
  }

  int _itemRemainingQuantity(InvoiceItemModel item) {
    final remaining = item.quantity - item.returnedQuantity;

    return remaining < 0 ? 0 : remaining;
  }

  double get _returnedAmount {
    return _items.fold<double>(
      0,
      (total, item) => total + _itemReturnedAmount(item),
    );
  }

  double get _netGrandTotal {
    final value = _invoice!.grandTotal - _returnedAmount;

    return value < 0 ? 0 : value;
  }

  double get _netDueAmount {
    final value = _netGrandTotal - _invoice!.paidAmount;

    return value < 0 ? 0 : value;
  }

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

              if (_invoice != null) ...[
                IconButton(
                  tooltip: 'Share Invoice',
                  icon: const Icon(CupertinoIcons.share),
                  onPressed: _shareInvoice,
                ),

                InvoiceActionMenu(
                  invoice: _invoice!,
                  onSelected: _onMenuSelected,
                ),
              ],
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

                _buildPaymentHistorySection(),

                //_buildTimelineSection(),
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
                              ? 'Due: ${formatCurrency(_invoice!.dueAmount)}'
                              : 'Fully Paid',
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
              returnedQuantity: item.returnedQuantity,

              unitPrice: item.sellingPrice,

              originalPrice: _itemOriginalAmount(item),
              returnedAmount: _itemReturnedAmount(item),
              netAmount: _itemNetAmount(item),

              totalPrice: _itemNetAmount(item),
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
  //---------------------------------------------------------------------
// Summary
//---------------------------------------------------------------------
Widget _buildSummarySection() {
  final financial = _financialSummary!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSectionHeader(title: 'Summary'),

      const SizedBox(height: 12),

      InvoiceSummaryCard(
        subtotal: _invoice!.subtotal,
        discount: _invoice!.discount,
        tax: _invoice!.tax,

        // Original invoice amount — never modified by returns.
        originalTotal: financial.originalAmount,

        // Return-aware values.
        returnedAmount: financial.returnedAmount,
        netInvoiceAmount: financial.netInvoiceAmount,
      ),

      const SizedBox(height: 18),
    ],
  );
}

  InvoiceFinancialSummary? get _financialSummary {
    if (_invoice == null) return null;

    final returnedAmount = InvoiceFinancialCalculator.calculateReturnedAmount(
      _items.map(
        (item) => InvoiceFinancialItem(
          sellingPrice: item.sellingPrice,
          returnedQuantity: item.returnedQuantity,
        ),
      ),
    );

    return InvoiceFinancialCalculator.calculate(
      originalAmount: _invoice!.grandTotal,
      returnedAmount: returnedAmount,
      paidAmount: _invoice!.paidAmount,
      refundedAmount: 0, // temporary until refund source is connected
    );
  }

  //---------------------------------------------------------------------
  // Payment
  //---------------------------------------------------------------------
  Widget _buildPaymentSection() {
    final financial = _financialSummary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Payment'),

        const SizedBox(height: 12),

        InvoicePaymentCard(
          readOnly: true,
          paymentMethod: _invoice!.paymentMethod,
          paidAmount: financial.paidAmount,
          grandTotal: financial.netInvoiceAmount,
          dueAmount: financial.amountDue,
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

  //---------------------------------------------------------------------------
  // Payment History
  //---------------------------------------------------------------------------

  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Payment History'),

        const SizedBox(height: 12),

        if (_paymentHistory.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 42,
                    color: Colors.grey.shade500,
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'No payment history available.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Payments received for this invoice will appear here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentHistory.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final payment = _paymentHistory[index];

              final isInitialPayment = index == _paymentHistory.length - 1;
              final paymentNumber = _paymentHistory.length - index;

              return InvoicePaymentHistoryCard(
                payment: payment,
                paymentNumber: paymentNumber,
                isInitialPayment: isInitialPayment,
              );
            },
          ),

        const SizedBox(height: 18),
      ],
    );
  }

  //---------------------------------------------------------------------
  // Invoice Timeline
  //---------------------------------------------------------------------

  // Widget _buildTimelineSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const AppSectionHeader(title: 'Invoice Timeline'),

  //       const SizedBox(height: 12),

  //       InvoiceTimelineCard(timeline: _timeline),

  //       const SizedBox(height: 18),
  //     ],
  //   );
  // }

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

  // ============================================================================
  // Load Payment History
  // ============================================================================

  Future<void> _loadPaymentHistory() async {
    if (_invoice == null) {
      return;
    }

    try {
      _paymentHistory = await _billingService.getInvoicePayments(_invoice!.id);
    } catch (_) {
      _paymentHistory = [];
    }
  }
}
