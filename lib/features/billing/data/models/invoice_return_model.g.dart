// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_return_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceReturnModel _$InvoiceReturnModelFromJson(Map<String, dynamic> json) =>
    _InvoiceReturnModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      invoiceId: json['invoice_id'] as String,
      returnNumber: json['return_number'] as String,
      returnType: $enumDecode(_$ReturnTypeEnumMap, json['return_type']),
      refundAmount: (json['refund_amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InvoiceReturnModelToJson(_InvoiceReturnModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'store_id': instance.storeId,
      'invoice_id': instance.invoiceId,
      'return_number': instance.returnNumber,
      'return_type': _$ReturnTypeEnumMap[instance.returnType]!,
      'refund_amount': instance.refundAmount,
      'notes': instance.notes,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ReturnTypeEnumMap = {
  ReturnType.refund: 'refund',
  ReturnType.exchange: 'exchange',
  ReturnType.replacement: 'replacement',
};
