// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_return_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceReturnItemModel _$InvoiceReturnItemModelFromJson(
  Map<String, dynamic> json,
) => _InvoiceReturnItemModel(
  id: json['id'] as String,
  returnId: json['return_id'] as String,
  invoiceItemId: json['invoice_item_id'] as String,
  productId: json['product_id'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unit_price'] as num).toDouble(),
  totalPrice: (json['total_price'] as num).toDouble(),
  reason: $enumDecode(_$ReturnReasonEnumMap, json['reason']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InvoiceReturnItemModelToJson(
  _InvoiceReturnItemModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'return_id': instance.returnId,
  'invoice_item_id': instance.invoiceItemId,
  'product_id': instance.productId,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'total_price': instance.totalPrice,
  'reason': _$ReturnReasonEnumMap[instance.reason]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$ReturnReasonEnumMap = {
  ReturnReason.damaged: 'damaged',
  ReturnReason.wrongItem: 'wrong_item',
  ReturnReason.customerChangedMind: 'customer_changed_mind',
  ReturnReason.defective: 'defective',
  ReturnReason.other: 'other',
};
