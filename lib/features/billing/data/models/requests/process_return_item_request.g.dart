// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_return_item_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProcessReturnItemRequest _$ProcessReturnItemRequestFromJson(
  Map<String, dynamic> json,
) => _ProcessReturnItemRequest(
  invoiceItemId: json['invoice_item_id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  productUnitIds:
      (json['product_unit_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$ProcessReturnItemRequestToJson(
  _ProcessReturnItemRequest instance,
) => <String, dynamic>{
  'invoice_item_id': instance.invoiceItemId,
  'quantity': instance.quantity,
  'product_unit_ids': instance.productUnitIds,
};
