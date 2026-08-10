// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'returnable_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReturnableItemModel _$ReturnableItemModelFromJson(Map<String, dynamic> json) =>
    _ReturnableItemModel(
      invoiceItemId: json['invoice_item_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      soldQuantity: (json['sold_quantity'] as num).toInt(),
      returnedQuantity: (json['returned_quantity'] as num).toInt(),
      remainingQuantity: (json['remaining_quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
    );

Map<String, dynamic> _$ReturnableItemModelToJson(
  _ReturnableItemModel instance,
) => <String, dynamic>{
  'invoice_item_id': instance.invoiceItemId,
  'product_id': instance.productId,
  'product_name': instance.productName,
  'sold_quantity': instance.soldQuantity,
  'returned_quantity': instance.returnedQuantity,
  'remaining_quantity': instance.remainingQuantity,
  'unit_price': instance.unitPrice,
};
