import 'package:flutter/services.dart';
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
    final regularFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'))
          .buffer
          .asByteData(),
    );
    final semiboldFont = pw.Font.ttf(
      (await rootBundle.load('assets/fonts/NotoSans-SemiBold.ttf'))
          .buffer
          .asByteData(),
    );
    final theme = _buildTheme(regularFont, semiboldFont);
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 34, 38, 42),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : _buildContinuationHeader(),
        footer: (context) => _buildPageFooter(context),
        build: (context) => [
          _buildHeader(store, invoice),
          pw.SizedBox(height: 18),
          _buildCustomerSection(invoice),
          pw.SizedBox(height: 20),
          _sectionHeading('ITEMS'),
          pw.SizedBox(height: 8),
          _buildProductsTable(items),
          pw.SizedBox(height: 18),
          _buildFinancialSection(invoice),
          if (invoice.notes != null && invoice.notes!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _buildNotesSection(invoice.notes!),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  pw.ThemeData _buildTheme(pw.Font regular, pw.Font semibold) {
    return pw.ThemeData.withFont(
      base: regular,
      bold: semibold,
      italic: regular,
      boldItalic: semibold,
    );
  }

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20b9',
    decimalDigits: 2,
  );
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  static const _navy = PdfColor.fromInt(0xff17324d);
  static const _blue = PdfColor.fromInt(0xff2f6f9f);
  static const _ink = PdfColor.fromInt(0xff1f2933);
  static const _muted = PdfColor.fromInt(0xff66727d);
  static const _line = PdfColor.fromInt(0xffd9e0e5);
  static const _pale = PdfColor.fromInt(0xfff5f8fa);
  static const _green = PdfColor.fromInt(0xff1d8050);
  static const _red = PdfColor.fromInt(0xffb54747);

  pw.TextStyle _text({
    double size = 9.5,
    PdfColor color = _ink,
    pw.FontWeight weight = pw.FontWeight.normal,
  }) {
    return pw.TextStyle(fontSize: size, color: color, fontWeight: weight);
  }

  pw.TextStyle _label() => _text(size: 8, color: _muted, weight: pw.FontWeight.bold);

  pw.Widget _buildHeader(StoreModel store, InvoiceModel invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 6,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('STOREMATE', style: _text(size: 15, color: _blue, weight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text('Smart Retail Management', style: _text(size: 8, color: _muted)),
                  pw.SizedBox(height: 16),
                  pw.Text(store.storeName, style: _text(size: 17, weight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(store.storeAddress, style: _text(size: 9, color: _muted)),
                  pw.SizedBox(height: 3),
                  pw.Text('Phone: ${store.ownerPhone}', style: _text(size: 9, color: _muted)),
                  if (store.gstNumber != null && store.gstNumber!.trim().isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text('GSTIN: ${store.gstNumber}', style: _text(size: 9, color: _muted)),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 28),
            pw.Expanded(
              flex: 4,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TAX INVOICE', style: _text(size: 19, color: _navy, weight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 13),
                  _metaRow('Invoice Number', invoice.invoiceNumber),
                  _metaRow('Invoice Date', _dateFormatter.format(invoice.invoiceDate)),
                  _metaRow('Payment Method', invoice.paymentMethod),
                  _metaRow('Payment Status', invoice.paymentStatus.toUpperCase()),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(height: 3, color: _blue),
      ],
    );
  }

  pw.Widget _buildContinuationHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _line))),
      child: pw.Text('STOREMATE  |  TAX INVOICE', style: _text(size: 8, color: _muted, weight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _metaRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$title  ', style: _label()),
          pw.SizedBox(width: 4),
          pw.Container(width: 104, child: pw.Text(value, style: _text(size: 9, weight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  pw.Widget _sectionHeading(String title) {
    return pw.Text(title, style: _text(size: 8.5, color: _blue, weight: pw.FontWeight.bold));
  }

  pw.Widget _buildCustomerSection(InvoiceModel invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: pw.BoxDecoration(
        color: _pale,
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionHeading('BILL TO'),
                pw.SizedBox(height: 6),
                pw.Text(invoice.customerName, style: _text(size: 12, weight: pw.FontWeight.bold)),
                if (invoice.customerPhone != null && invoice.customerPhone!.trim().isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: pw.Text(invoice.customerPhone!, style: _text(size: 9, color: _muted)),
                  ),
              ],
            ),
          ),
          pw.Text('Thank you for choosing StoreMate', style: _text(size: 8, color: _muted)),
        ],
      ),
    );
  }

  pw.Widget _buildProductsTable(List<InvoiceItemModel> items) {
    final rows = <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: _navy),
        children: [
          _tableHeader('PRODUCT'),
          _tableHeader('QTY', align: pw.TextAlign.center),
          _tableHeader('UNIT PRICE', align: pw.TextAlign.right),
          _tableHeader('TOTAL', align: pw.TextAlign.right),
        ],
      ),
      ...items.asMap().entries.map((entry) => _productRow(entry.key, entry.value)),
    ];

    return pw.Table(
      columnWidths: const {
        0: pw.FlexColumnWidth(5.5),
        1: pw.FlexColumnWidth(1.1),
        2: pw.FlexColumnWidth(2.3),
        3: pw.FlexColumnWidth(2.5),
      },
      border: pw.TableBorder(
        left: const pw.BorderSide(color: _line),
        right: const pw.BorderSide(color: _line),
        bottom: const pw.BorderSide(color: _line),
        horizontalInside: const pw.BorderSide(color: _line, width: .5),
      ),
      children: rows,
    );
  }

  pw.Widget _tableHeader(String value, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: pw.Text(value, textAlign: align, style: _text(size: 7.5, color: PdfColors.white, weight: pw.FontWeight.bold)),
    );
  }

  pw.TableRow _productRow(int index, InvoiceItemModel item) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: index.isEven ? PdfColors.white : _pale),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(item.productName, style: _text(size: 9.5, weight: pw.FontWeight.bold)),
              if (item.productCategory != null && item.productCategory!.trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(item.productCategory!, style: _text(size: 7.5, color: _muted)),
                ),
            ],
          ),
        ),
        _tableCell(item.quantity.toString(), align: pw.TextAlign.center),
        _tableCell(_money(item.sellingPrice), align: pw.TextAlign.right),
        _tableCell(_money(item.lineTotal), align: pw.TextAlign.right, bold: true),
      ],
    );
  }

  pw.Widget _tableCell(String value, {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(value, textAlign: align, style: _text(size: 9, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  pw.Widget _buildFinancialSection(InvoiceModel invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _buildPaymentSection(invoice)),
        pw.SizedBox(width: 18),
        pw.SizedBox(width: 235, child: _buildSummarySection(invoice)),
      ],
    );
  }

  pw.Widget _buildSummarySection(InvoiceModel invoice) {
    return _card(
      title: 'INVOICE SUMMARY',
      child: pw.Column(
        children: [
          _amountRow('Subtotal', _money(invoice.subtotal)),
          _amountRow('Discount', '- ${_money(invoice.discount)}', color: _red),
          _amountRow('Tax', '+ ${_money(invoice.tax)}', color: _blue),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Divider(color: _line),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(4)),
            child: _amountRow('GRAND TOTAL', _money(invoice.grandTotal), bold: true, color: _navy),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentSection(InvoiceModel invoice) {
    return _card(
      title: 'PAYMENT DETAILS',
      child: pw.Column(
        children: [
          _amountRow('Paid Amount', _money(invoice.paidAmount), color: _green),
          _amountRow('Due Amount', _money(invoice.dueAmount), color: invoice.dueAmount > 0 ? _red : _green),
          _amountRow('Payment Method', invoice.paymentMethod),
          _amountRow('Payment Status', invoice.paymentStatus.toUpperCase()),
        ],
      ),
    );
  }

  pw.Widget _card({required String title, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _pale,
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionHeading(title),
          pw.SizedBox(height: 9),
          child,
        ],
      ),
    );
  }

  pw.Widget _amountRow(String title, String value, {PdfColor? color, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: _text(size: bold ? 9.5 : 8.5, color: bold ? _ink : _muted, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal))),
          pw.Text(value, style: _text(size: bold ? 12 : 9, color: color ?? _ink, weight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildNotesSection(String notes) {
    return _card(
      title: 'NOTES',
      child: pw.Text(notes, style: _text(size: 9, color: _muted)),
    );
  }

  pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 7, bottom: 2),
      decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _line))),
      child: pw.Column(
        children: [
          pw.Text('Thank you for your business!', style: _text(size: 9, weight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text('We appreciate your trust in our services.', style: _text(size: 7.5, color: _muted)),
          pw.SizedBox(height: 4),
          pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            textAlign: pw.TextAlign.center,
            style: _text(size: 7, color: _muted),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('STOREMATE  |  Smart Retail Management', style: _text(size: 7.5, color: _muted)),
              pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: _text(size: 7.5, color: _muted)),
            ],
          ),
        ],
      ),
    );
  }

  String _money(num value) => _currencyFormatter.format(value);
}
