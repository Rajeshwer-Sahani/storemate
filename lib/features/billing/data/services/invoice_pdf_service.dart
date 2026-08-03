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
              style: const pw.TextStyle(fontSize: 9),
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
  // Header
  // ===========================================================================

  pw.Widget _buildHeader(StoreModel store, InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'STOREMATE',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue700,
                      letterSpacing: 2,
                    ),
                  ),

                  pw.SizedBox(height: 4),

                  pw.Text(
                    'Smart Retail Management',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),

                  pw.SizedBox(height: 18),

                  pw.Text(
                    store.storeName,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    store.storeAddress,
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    'Phone: ${store.ownerPhone}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),

                  if (store.gstNumber != null &&
                      store.gstNumber!.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        'GSTIN: ${store.gstNumber}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(width: 32),

            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue700,
                      ),
                    ),

                    pw.SizedBox(height: 16),

                    _headerRow('Invoice No', invoice.invoiceNumber),

                    pw.SizedBox(height: 8),

                    _headerRow(
                      'Invoice Date',
                      _dateFormatter.format(invoice.invoiceDate),
                    ),

                    pw.SizedBox(height: 8),

                    _headerRow('Payment', invoice.paymentMethod),

                    pw.SizedBox(height: 8),

                    _headerRow('Status', invoice.paymentStatus.toUpperCase()),
                  ],
                ),
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 20),

        pw.Divider(thickness: 1, color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _headerRow(String title, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
        ),
        pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Customer
  // ===========================================================================

  pw.Widget _buildCustomerSection(InvoiceModel invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
              letterSpacing: 1.2,
            ),
          ),

          pw.SizedBox(height: 14),

          _customerInfoRow(title: 'Customer Name', value: invoice.customerName),

          pw.SizedBox(height: 10),

          _customerInfoRow(
            title: 'Phone Number',
            value: invoice.customerPhone?.isNotEmpty == true
                ? invoice.customerPhone!
                : '-',
          ),
        ],
      ),
    );
  }

  pw.Widget _customerInfoRow({required String title, required String value}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
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
        pw.Text(
          'PRODUCTS',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
            letterSpacing: 1.2,
          ),
        ),

        pw.SizedBox(height: 12),

        _buildProductsHeader(),

        ...items.map(_buildProductRow),
      ],
    );
  }

  pw.Widget _buildProductsHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(6),
          topRight: pw.Radius.circular(6),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 5, child: _headerCell('Product')),
          pw.Expanded(child: _headerCell('Qty')),
          pw.Expanded(
            flex: 2,
            child: _headerCell('Rate', align: pw.TextAlign.right),
          ),
          pw.Expanded(
            flex: 2,
            child: _headerCell('Amount', align: pw.TextAlign.right),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProductRow(InvoiceItemModel item) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item.productName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),

                if (item.productCategory != null &&
                    item.productCategory!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: pw.Text(
                      item.productCategory!,
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          pw.Expanded(child: pw.Text(item.quantity.toString())),

          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(_currencyFormatter.format(item.sellingPrice)),
            ),
          ),

          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _currencyFormatter.format(item.lineTotal),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Spacer(),

        pw.Container(
          width: 250,
          padding: const pw.EdgeInsets.all(18),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
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
                child: pw.Divider(),
              ),

              _summaryRow(
                'GRAND TOTAL',
                _currencyFormatter.format(invoice.grandTotal),
                isGrandTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryRow(
    String title,
    String value, {
    bool isGrandTotal = false,
    PdfColor? valueColor,
  }) {
    final style = pw.TextStyle(
      fontSize: isGrandTotal ? 12 : 10,
      fontWeight: isGrandTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(title, style: style)),

        pw.Text(value, style: style.copyWith(color: valueColor)),
      ],
    );
  }

  // ===========================================================================
  // Payment
  // ===========================================================================

  pw.Widget _buildPaymentSection(InvoiceModel invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
              letterSpacing: 1.2,
            ),
          ),

          pw.SizedBox(height: 14),

          _paymentRow(
            'Paid Amount',
            _currencyFormatter.format(invoice.paidAmount),
            PdfColors.green700,
          ),

          pw.SizedBox(height: 10),

          _paymentRow(
            'Due Amount',
            _currencyFormatter.format(invoice.dueAmount),
            PdfColors.red700,
          ),

          pw.SizedBox(height: 10),

          _paymentRow('Method', invoice.paymentMethod),

          pw.SizedBox(height: 10),

          _paymentRow('Status', invoice.paymentStatus),
        ],
      ),
    );
  }

  pw.Widget _paymentRow(String title, String value, [PdfColor? color]) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
        ),

        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: color,
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
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NOTES',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
              letterSpacing: 1.2,
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Text(
            invoice.notes!,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 3),
          ),
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
        pw.Divider(color: PdfColors.grey400),

        pw.SizedBox(height: 18),

        pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Text(
          'We appreciate your trust and look forward to serving you again.',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),

        pw.SizedBox(height: 18),

        pw.Text(
          'This is a computer-generated invoice and does not require a signature.',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),

        pw.SizedBox(height: 20),

        pw.Text(
          'Generated by StoreMate',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
            fontSize: 10,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Text(
          'Smart Retail Management',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
