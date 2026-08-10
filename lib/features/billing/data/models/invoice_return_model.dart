import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_return_model.freezed.dart';
part 'invoice_return_model.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ReturnType {
  refund,
  exchange,
  replacement,
}

@freezed
abstract class InvoiceReturnModel with _$InvoiceReturnModel {
  const factory InvoiceReturnModel({
    /// Primary Key
    required String id,

    /// Store ID
    @JsonKey(name: 'store_id')
    required String storeId,

    /// Original Invoice ID
    @JsonKey(name: 'invoice_id')
    required String invoiceId,

    /// Return Number (e.g. RET-000001)
    @JsonKey(name: 'return_number')
    required String returnNumber,

    /// Return Type
    @JsonKey(name: 'return_type')
    required ReturnType returnType,

    /// Total Refund Amount
    @JsonKey(name: 'refund_amount')
    required double refundAmount,

    /// Optional Notes
    String? notes,

    /// User who processed the return
    @JsonKey(name: 'created_by')
    required String createdBy,

    /// Creation Timestamp
    @JsonKey(name: 'created_at')
    required DateTime createdAt,

    /// Last Updated Timestamp
    @JsonKey(name: 'updated_at')
    required DateTime updatedAt,
  }) = _InvoiceReturnModel;

  factory InvoiceReturnModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceReturnModelFromJson(json);
}