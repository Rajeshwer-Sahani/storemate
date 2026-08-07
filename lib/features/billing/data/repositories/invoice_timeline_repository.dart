import '../models/invoice_timeline_model.dart';

abstract class InvoiceTimelineRepository {
  Future<List<InvoiceTimelineModel>> getInvoiceTimeline(
    String invoiceId,
  );
}