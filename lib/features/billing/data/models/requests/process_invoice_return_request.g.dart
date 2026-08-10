// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_invoice_return_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProcessInvoiceReturnRequest _$ProcessInvoiceReturnRequestFromJson(
  Map<String, dynamic> json,
) => _ProcessInvoiceReturnRequest(
  invoiceId: json['p_invoice_id'] as String,
  storeId: json['p_store_id'] as String,
  returnReason: json['p_return_reason'] as String,
  notes: json['p_notes'] as String?,
  returnItems: (json['p_return_items'] as List<dynamic>)
      .map((e) => ProcessReturnItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProcessInvoiceReturnRequestToJson(
  _ProcessInvoiceReturnRequest instance,
) => <String, dynamic>{
  'p_invoice_id': instance.invoiceId,
  'p_store_id': instance.storeId,
  'p_return_reason': instance.returnReason,
  'p_notes': instance.notes,
  'p_return_items': instance.returnItems,
};
