import 'package:freezed_annotation/freezed_annotation.dart';

import 'invoice_return_model.dart';

part 'invoice_return_history_model.freezed.dart';
part 'invoice_return_history_model.g.dart';

@freezed
abstract class InvoiceReturnHistoryModel with _$InvoiceReturnHistoryModel {
  const factory InvoiceReturnHistoryModel({
    @JsonKey(name: 'return_id')
    required String returnId,

    @JsonKey(name: 'return_number')
    required String returnNumber,

    @JsonKey(name: 'return_type')
    required ReturnType returnType,

    @JsonKey(name: 'refund_amount')
    required double refundAmount,

    String? notes,

    @JsonKey(name: 'created_at')
    required DateTime createdAt,
  }) = _InvoiceReturnHistoryModel;

  factory InvoiceReturnHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$InvoiceReturnHistoryModelFromJson(json);
}