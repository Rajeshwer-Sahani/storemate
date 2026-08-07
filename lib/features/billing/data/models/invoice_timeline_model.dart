import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_timeline_model.freezed.dart';
part 'invoice_timeline_model.g.dart';

@freezed
abstract class InvoiceTimelineModel with _$InvoiceTimelineModel {
  const factory InvoiceTimelineModel({
    required String id,

    @JsonKey(name: 'store_id')
    required String storeId,

    @JsonKey(name: 'invoice_id')
    required String invoiceId,

    @JsonKey(name: 'event_type')
    required String eventType,

    @JsonKey(name: 'event_title')
    required String eventTitle,

    @JsonKey(name: 'event_description')
    required String eventDescription,

    double? amount,

    @JsonKey(name: 'payment_method')
    String? paymentMethod,

    @JsonKey(name: 'created_at')
    required DateTime createdAt,

    @JsonKey(name: 'updated_at')
    required DateTime updatedAt,
  }) = _InvoiceTimelineModel;

  factory InvoiceTimelineModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceTimelineModelFromJson(json);
}