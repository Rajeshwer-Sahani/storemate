import 'package:freezed_annotation/freezed_annotation.dart';

part 'returnable_item_model.freezed.dart';
part 'returnable_item_model.g.dart';

@freezed
 abstract class ReturnableItemModel with _$ReturnableItemModel {
  const factory ReturnableItemModel({
    @JsonKey(name: 'invoice_item_id')
    required String invoiceItemId,

    @JsonKey(name: 'product_id')
    required String productId,

    @JsonKey(name: 'product_name')
    required String productName,

    @JsonKey(name: 'sold_quantity')
    required int soldQuantity,

    @JsonKey(name: 'returned_quantity')
    required int returnedQuantity,

    @JsonKey(name: 'remaining_quantity')
    required int remainingQuantity,

    @JsonKey(name: 'unit_price')
    required double unitPrice,
  }) = _ReturnableItemModel;

  factory ReturnableItemModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ReturnableItemModelFromJson(json);
}