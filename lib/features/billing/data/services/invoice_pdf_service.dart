import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:storemate/features/billing/data/models/invoice_item_model.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/store/data/module/store_model.dart';

class InvoicePdfService {
  InvoicePdfService();

  Future<Uint8List> generateInvoicePdf({
    required StoreModel store,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: _smallStyle.copyWith(fontSize: 9),
            ),
          );
        },

        build: (context) => [
          _buildHeader(store, invoice),
          pw.SizedBox(height: 24),

          _buildCustomerSection(invoice),
          pw.SizedBox(height: 24),

          _buildProductsSection(items),
          pw.SizedBox(height: 24),

          _buildSummarySection(invoice),
          pw.SizedBox(height: 24),

          _buildPaymentSection(invoice),
          pw.SizedBox(height: 24),

          _buildNotesSection(invoice),
          pw.SizedBox(height: 30),

          _buildFooter(),
        ],
      ),
    );

    return pdf.save();
  }

  // ===========================================================================
  // Formatters
  // ===========================================================================
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  // ===========================================================================
  // Typography
  // ===========================================================================

  final _brandStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
    letterSpacing: 2,
  );

  final _invoiceTitleStyle = pw.TextStyle(
    fontSize: 24,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
  );

  final _storeNameStyle = pw.TextStyle(
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey900,
  );

  final _sectionTitleStyle = pw.TextStyle(
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
    letterSpacing: 1,
  );

  final _labelStyle = pw.TextStyle(fontSize: 9, color: PdfColors.grey600);

  final _valueStyle = pw.TextStyle(
    fontSize: 10,
    color: PdfColors.grey900,
    fontWeight: pw.FontWeight.bold,
  );

  final _bodyStyle = pw.TextStyle(fontSize: 10, color: PdfColors.grey800);

  final _smallStyle = pw.TextStyle(fontSize: 8, color: PdfColors.grey600);

  final _grandTotalStyle = pw.TextStyle(
    fontSize: 14,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue700,
  );

  final _cardHeaderStyle = pw.TextStyle(
    color: PdfColors.white,
    fontSize: 11,
    fontWeight: pw.FontWeight.bold,
    letterSpacing: 1,
  );

  // ===========================================================================
  // Header
  // ===========================================================================

  // ===========================================================================
  // Header
  // ===========================================================================

  pw.Widget _buildHeader(StoreModel store, InvoiceModel invoice) {
    return pw.Column(
      children: [
        //----------------------------------------------------------------------
        // Top Row
        //----------------------------------------------------------------------
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            //------------------------------------------------------------------
            // Left Side (Business)
            //------------------------------------------------------------------
            pw.Expanded(
              flex: 6,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('STOREMATE', style: _brandStyle),

                  pw.SizedBox(height: 3),

                  pw.Text('Smart Retail Management', style: _smallStyle),

                  pw.SizedBox(height: 24),

                  pw.Text(store.storeName, style: _storeNameStyle),

                  pw.SizedBox(height: 8),

                  pw.Text(store.storeAddress, style: _bodyStyle),

                  pw.SizedBox(height: 6),

                  pw.Text('Phone : ${store.ownerPhone}', style: _bodyStyle),

                  if (store.gstNumber != null &&
                      store.gstNumber!.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        'GSTIN : ${store.gstNumber}',
                        style: _bodyStyle,
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(width: 36),

            //------------------------------------------------------------------
            // Right Side
            //------------------------------------------------------------------
            pw.Expanded(
              flex: 4,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TAX INVOICE', style: _invoiceTitleStyle),

                  pw.SizedBox(height: 28),

                  _invoiceInfoRow('Invoice No', invoice.invoiceNumber),

                  pw.SizedBox(height: 10),

                  _invoiceInfoRow(
                    'Invoice Date',
                    _dateFormatter.format(invoice.invoiceDate),
                  ),

                  pw.SizedBox(height: 10),

                  _invoiceInfoRow('Payment', invoice.paymentMethod),

                  pw.SizedBox(height: 10),

                  _invoiceInfoRow(
                    'Status',
                    invoice.paymentStatus.toUpperCase(),
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 24),

        pw.Container(height: 1, color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _invoiceInfoRow(String title, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 70, child: pw.Text(title, style: _valueStyle)),

        pw.SizedBox(width: 14),

        pw.Container(
          width: 110,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(value, style: _labelStyle),
        ),
      ],
    );
  }

  // ===========================================================================
  // Customer
  // ===========================================================================

  // ===========================================================================
  // Customer
  // ===========================================================================

  pw.Widget _buildCustomerSection(InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        //----------------------------------------------------------------------
        // Section Title
        //----------------------------------------------------------------------
        pw.Text('BILL TO', style: _sectionTitleStyle),

        pw.SizedBox(height: 14),

        //----------------------------------------------------------------------
        // Customer Card
        //----------------------------------------------------------------------
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(18),

          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            border: pw.Border.all(color: PdfColors.grey300, width: .8),

            borderRadius: pw.BorderRadius.circular(8),
          ),

          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                invoice.customerName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),

              if (invoice.customerPhone != null &&
                  invoice.customerPhone!.trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 6),
                  child: pw.Text(invoice.customerPhone!, style: _bodyStyle),
                ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _customerInfoRow({required String title, required String value}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: _labelStyle),

        pw.SizedBox(height: 3),

        pw.Text(value, style: _valueStyle),
      ],
    );
  }

  // ===========================================================================
  // Products
  // ===========================================================================

  pw.Widget _buildProductsSection(List<InvoiceItemModel> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PRODUCTS', style: _sectionTitleStyle),

        pw.SizedBox(height: 12),

        _buildProductsHeader(),

        ...items.map(_buildProductRow),

        pw.Container(height: 1, color: PdfColors.grey300),
      ],
    );
  }

  pw.Widget _buildProductsHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(8),
          topRight: pw.Radius.circular(8),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 6, child: _headerCell('PRODUCT')),

          pw.Expanded(
            flex: 1,
            child: _headerCell('QTY', align: pw.TextAlign.center),
          ),

          pw.Expanded(
            flex: 2,
            child: _headerCell('UNIT PRICE', align: pw.TextAlign.right),
          ),

          pw.Expanded(
            flex: 2,
            child: _headerCell('TOTAL', align: pw.TextAlign.right),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProductRow(InvoiceItemModel item) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: .5),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          //----------------------------------------------------------
          // Product
          //----------------------------------------------------------
          pw.Expanded(
            flex: 6,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.productName,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),

                if (item.productCategory != null &&
                    item.productCategory!.trim().isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      item.productCategory!,
                      style: _bodyStyle.copyWith(fontSize: 9),
                    ),
                  ),
              ],
            ),
          ),

          //----------------------------------------------------------
          // Quantity
          //----------------------------------------------------------
          pw.Expanded(
            flex: 1,
            child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                item.quantity.toString(),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ),

          //----------------------------------------------------------
          // Unit Price
          //----------------------------------------------------------
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _currencyFormatter.format(item.sellingPrice),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ),

          //----------------------------------------------------------
          // Total
          //----------------------------------------------------------
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _currencyFormatter.format(item.lineTotal),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
    );
  }

  // ===========================================================================
  // Summary
  // ===========================================================================

  pw.Widget _buildSummarySection(InvoiceModel invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 280,

        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,

          border: pw.Border.all(color: PdfColors.grey300),

          borderRadius: pw.BorderRadius.circular(8),
        ),

        child: pw.Column(
          children: [
            //----------------------------------------------------------
            // Header
            //----------------------------------------------------------
            pw.Container(
              width: double.infinity,

              padding: const pw.EdgeInsets.symmetric(vertical: 10),

              decoration: const pw.BoxDecoration(
                color: PdfColors.blue700,

                borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(8),
                  topRight: pw.Radius.circular(8),
                ),
              ),

              child: pw.Center(
                child: pw.Text('INVOICE SUMMARY', style: _cardHeaderStyle),
              ),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.all(16),

              child: pw.Column(
                children: [
                  _summaryRow(
                    'Subtotal',
                    _currencyFormatter.format(invoice.subtotal),
                  ),

                  pw.SizedBox(height: 10),

                  _summaryRow(
                    'Discount',
                    '- ${_currencyFormatter.format(invoice.discount)}',
                    valueColor: PdfColors.red700,
                  ),

                  pw.SizedBox(height: 10),

                  _summaryRow(
                    'Tax',
                    '+ ${_currencyFormatter.format(invoice.tax)}',
                    valueColor: PdfColors.blue700,
                  ),

                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 14),
                    child: pw.Divider(color: PdfColors.grey400),
                  ),

                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),

                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,

                      borderRadius: pw.BorderRadius.circular(6),
                    ),

                    child: _summaryRow(
                      'GRAND TOTAL',
                      _currencyFormatter.format(invoice.grandTotal),
                      isGrandTotal: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryRow(
    String title,
    String value, {
    bool isGrandTotal = false,
    PdfColor? valueColor,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: isGrandTotal ? 12 : 10,
              fontWeight: isGrandTotal
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,

              color: PdfColors.grey800,
            ),
          ),
        ),

        pw.Text(
          value,
          style: isGrandTotal
              ? _grandTotalStyle
              : _valueStyle.copyWith(color: valueColor ?? PdfColors.grey900),
        ),
      ],
    );
  }

  // ===========================================================================
  // Payment
  // ===========================================================================

  pw.Widget _buildPaymentSection(InvoiceModel invoice) {
    return pw.Container(
      width: double.infinity,

      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,

        border: pw.Border.all(color: PdfColors.grey300),

        borderRadius: pw.BorderRadius.circular(8),
      ),

      child: pw.Column(
        children: [
          //----------------------------------------------------------
          // Header
          //----------------------------------------------------------
          pw.Container(
            width: double.infinity,

            padding: const pw.EdgeInsets.symmetric(vertical: 10),

            decoration: const pw.BoxDecoration(
              color: PdfColors.blue700,

              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),

            child: pw.Center(
              child: pw.Text('PAYMENT DETAILS', style: _cardHeaderStyle),
            ),
          ),

          pw.Padding(
            padding: const pw.EdgeInsets.all(16),

            child: pw.Column(
              children: [
                _paymentRow(
                  'Paid Amount',
                  _currencyFormatter.format(invoice.paidAmount),
                  PdfColors.green700,
                ),

                pw.SizedBox(height: 12),

                _paymentRow(
                  'Due Amount',
                  _currencyFormatter.format(invoice.dueAmount),
                  PdfColors.red700,
                ),

                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 14),
                  child: pw.Divider(color: PdfColors.grey300),
                ),

                _paymentRow('Payment Method', invoice.paymentMethod),

                pw.SizedBox(height: 12),

                _paymentStatusBadge(invoice.paymentStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _paymentRow(String title, String value, [PdfColor? valueColor]) {
    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(title, style: _labelStyle)),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: valueColor ?? PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  pw.Widget _paymentStatusBadge(String status) {
    PdfColor background;

    PdfColor foreground;

    switch (status.toLowerCase()) {
      case 'paid':
        background = PdfColors.green100;
        foreground = PdfColors.green800;
        break;

      case 'partial':
        background = PdfColors.orange100;
        foreground = PdfColors.orange800;
        break;

      default:
        background = PdfColors.red100;
        foreground = PdfColors.red800;
    }

    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text('Payment Status', style: _labelStyle)),

        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),

          decoration: pw.BoxDecoration(
            color: background,
            borderRadius: pw.BorderRadius.circular(20),
          ),

          child: pw.Text(
            status.toUpperCase(),
            style: pw.TextStyle(
              color: foreground,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Notes
  // ===========================================================================

  pw.Widget _buildNotesSection(InvoiceModel invoice) {
    if (invoice.notes == null || invoice.notes!.trim().isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      width: double.infinity,

      padding: const pw.EdgeInsets.all(16),

      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,

        border: pw.Border.all(color: PdfColors.grey300),

        borderRadius: pw.BorderRadius.circular(8),
      ),

      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('NOTES', style: _sectionTitleStyle),

          pw.SizedBox(height: 10),

          pw.Text(invoice.notes!, style: _bodyStyle.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  // ===========================================================================
  // Footer
  // ===========================================================================

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),

        pw.SizedBox(height: 18),

        pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          'We appreciate your trust in our services.',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),

        pw.SizedBox(height: 18),

        pw.Text(
          'This is a computer-generated invoice and does not require a signature.',
          textAlign: pw.TextAlign.center,
          style: _smallStyle.copyWith(fontSize: 9),
        ),

        pw.SizedBox(height: 12),

        pw.Text(
          'Generated by StoreMate • Smart Retail Management',
          style: _smallStyle,
        ),
      ],
    );
  }
}
