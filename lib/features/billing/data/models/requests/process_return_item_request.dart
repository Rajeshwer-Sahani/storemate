import 'package:freezed_annotation/freezed_annotation.dart';

part 'process_return_item_request.freezed.dart';
part 'process_return_item_request.g.dart';

@freezed
abstract class ProcessReturnItemRequest with _$ProcessReturnItemRequest {
  const factory ProcessReturnItemRequest({
    @JsonKey(name: 'invoice_item_id') required String invoiceItemId,

    required int quantity,

    @Default(<String>[])
    @JsonKey(name: 'product_unit_ids')
    List<String> productUnitIds,
  }) = _ProcessReturnItemRequest;

  factory ProcessReturnItemRequest.fromJson(Map<String, dynamic> json) =>
      _$ProcessReturnItemRequestFromJson(json);
}
