// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_return_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceReturnHistoryModel _$InvoiceReturnHistoryModelFromJson(
  Map<String, dynamic> json,
) => _InvoiceReturnHistoryModel(
  returnId: json['return_id'] as String,
  returnNumber: json['return_number'] as String,
  returnType: $enumDecode(_$ReturnTypeEnumMap, json['return_type']),
  refundAmount: (json['refund_amount'] as num).toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InvoiceReturnHistoryModelToJson(
  _InvoiceReturnHistoryModel instance,
) => <String, dynamic>{
  'return_id': instance.returnId,
  'return_number': instance.returnNumber,
  'return_type': _$ReturnTypeEnumMap[instance.returnType]!,
  'refund_amount': instance.refundAmount,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$ReturnTypeEnumMap = {
  ReturnType.refund: 'refund',
  ReturnType.exchange: 'exchange',
  ReturnType.replacement: 'replacement',
};
