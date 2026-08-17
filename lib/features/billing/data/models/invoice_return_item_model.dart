import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_return_item_model.freezed.dart';
part 'invoice_return_item_model.g.dart';

@JsonEnum(alwaysCreate: true)
enum ReturnReason {
  @JsonValue('damaged')
  damaged,

  @JsonValue('wrong_item')
  wrongItem,

  @JsonValue('customer_changed_mind')
  customerChangedMind,

  @JsonValue('defective')
  defective,

  @JsonValue('other')
  other,
}

/// PostgreSQL value for each return reason.
extension ReturnReasonExtension on ReturnReason {
  String get dbValue {
    switch (this) {
      case ReturnReason.damaged:
        return 'damaged';

      case ReturnReason.wrongItem:
        return 'wrong_item';

      case ReturnReason.customerChangedMind:
        return 'customer_changed_mind';

      case ReturnReason.defective:
        return 'defective';

      case ReturnReason.other:
        return 'other';
    }
  }
}

@freezed
abstract class InvoiceReturnItemModel with _$InvoiceReturnItemModel {
  const factory InvoiceReturnItemModel({
    required String id,

    @JsonKey(name: 'return_id') required String returnId,

    @JsonKey(name: 'invoice_item_id') required String invoiceItemId,

    @JsonKey(name: 'product_id') required String productId,

    required int quantity,

    @JsonKey(name: 'unit_price') required double unitPrice,

    @JsonKey(name: 'total_price') required double totalPrice,

    required ReturnReason reason,

    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _InvoiceReturnItemModel;

  factory InvoiceReturnItemModel.fromJson(Map<String, dynamic> json) =>
      _$InvoiceReturnItemModelFromJson(json);
}
