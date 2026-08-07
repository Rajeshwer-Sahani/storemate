// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_timeline_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceTimelineModel _$InvoiceTimelineModelFromJson(
  Map<String, dynamic> json,
) => _InvoiceTimelineModel(
  id: json['id'] as String,
  storeId: json['store_id'] as String,
  invoiceId: json['invoice_id'] as String,
  eventType: json['event_type'] as String,
  eventTitle: json['event_title'] as String,
  eventDescription: json['event_description'] as String,
  amount: (json['amount'] as num?)?.toDouble(),
  paymentMethod: json['payment_method'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$InvoiceTimelineModelToJson(
  _InvoiceTimelineModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'store_id': instance.storeId,
  'invoice_id': instance.invoiceId,
  'event_type': instance.eventType,
  'event_title': instance.eventTitle,
  'event_description': instance.eventDescription,
  'amount': instance.amount,
  'payment_method': instance.paymentMethod,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
