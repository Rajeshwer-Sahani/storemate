import 'package:freezed_annotation/freezed_annotation.dart';

import 'process_return_item_request.dart';

part 'process_invoice_return_request.freezed.dart';
part 'process_invoice_return_request.g.dart';

@freezed
abstract class ProcessInvoiceReturnRequest with _$ProcessInvoiceReturnRequest {
  const factory ProcessInvoiceReturnRequest({
    @JsonKey(name: 'p_invoice_id') required String invoiceId,

    @JsonKey(name: 'p_store_id') required String storeId,

    @JsonKey(name: 'p_return_reason') required String returnReason,

    @JsonKey(name: 'p_notes') String? notes,

    @JsonKey(name: 'p_return_items')
    required List<ProcessReturnItemRequest> returnItems,
  }) = _ProcessInvoiceReturnRequest;

  factory ProcessInvoiceReturnRequest.fromJson(Map<String, dynamic> json) =>
      _$ProcessInvoiceReturnRequestFromJson(json);
}
