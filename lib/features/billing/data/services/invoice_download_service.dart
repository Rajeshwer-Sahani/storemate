import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceDownloadService {
  const InvoiceDownloadService();

  //==========================================================================
  // Save PDF
  //==========================================================================

  Future<File> saveInvoicePdf({
    required Uint8List pdfBytes,
    required String invoiceNumber,
  }) async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/$invoiceNumber.pdf',
    );

    await file.writeAsBytes(pdfBytes);

    return file;
  }

  //==========================================================================
  // Open PDF
  //==========================================================================

  Future<void> openPdf(File file) async {
    final result = await OpenFilex.open(file.path);

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  //==========================================================================
  // Share PDF
  //==========================================================================

  Future<void> sharePdf(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Invoice',
      ),
    );
  }
}