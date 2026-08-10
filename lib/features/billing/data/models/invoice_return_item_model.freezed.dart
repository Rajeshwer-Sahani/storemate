// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_return_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceReturnItemModel {

 String get id;@JsonKey(name: 'return_id') String get returnId;@JsonKey(name: 'invoice_item_id') String get invoiceItemId;@JsonKey(name: 'product_id') String get productId; int get quantity;@JsonKey(name: 'unit_price') double get unitPrice;@JsonKey(name: 'total_price') double get totalPrice; ReturnReason get reason;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of InvoiceReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceReturnItemModelCopyWith<InvoiceReturnItemModel> get copyWith => _$InvoiceReturnItemModelCopyWithImpl<InvoiceReturnItemModel>(this as InvoiceReturnItemModel, _$identity);

  /// Serializes this InvoiceReturnItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceReturnItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,returnId,invoiceItemId,productId,quantity,unitPrice,totalPrice,reason,createdAt);

@override
String toString() {
  return 'InvoiceReturnItemModel(id: $id, returnId: $returnId, invoiceItemId: $invoiceItemId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceReturnItemModelCopyWith<$Res>  {
  factory $InvoiceReturnItemModelCopyWith(InvoiceReturnItemModel value, $Res Function(InvoiceReturnItemModel) _then) = _$InvoiceReturnItemModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'return_id') String returnId,@JsonKey(name: 'invoice_item_id') String invoiceItemId,@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice, ReturnReason reason,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$InvoiceReturnItemModelCopyWithImpl<$Res>
    implements $InvoiceReturnItemModelCopyWith<$Res> {
  _$InvoiceReturnItemModelCopyWithImpl(this._self, this._then);

  final InvoiceReturnItemModel _self;
  final $Res Function(InvoiceReturnItemModel) _then;

/// Create a copy of InvoiceReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? returnId = null,Object? invoiceItemId = null,Object? productId = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? reason = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReturnReason,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceReturnItemModel].
extension InvoiceReturnItemModelPatterns on InvoiceReturnItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceReturnItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceReturnItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceReturnItemModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnItemModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceReturnItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice,  ReturnReason reason, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceReturnItemModel() when $default != null:
return $default(_that.id,_that.returnId,_that.invoiceItemId,_that.productId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.reason,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice,  ReturnReason reason, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnItemModel():
return $default(_that.id,_that.returnId,_that.invoiceItemId,_that.productId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.reason,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'unit_price')  double unitPrice, @JsonKey(name: 'total_price')  double totalPrice,  ReturnReason reason, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnItemModel() when $default != null:
return $default(_that.id,_that.returnId,_that.invoiceItemId,_that.productId,_that.quantity,_that.unitPrice,_that.totalPrice,_that.reason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceReturnItemModel implements InvoiceReturnItemModel {
  const _InvoiceReturnItemModel({required this.id, @JsonKey(name: 'return_id') required this.returnId, @JsonKey(name: 'invoice_item_id') required this.invoiceItemId, @JsonKey(name: 'product_id') required this.productId, required this.quantity, @JsonKey(name: 'unit_price') required this.unitPrice, @JsonKey(name: 'total_price') required this.totalPrice, required this.reason, @JsonKey(name: 'created_at') required this.createdAt});
  factory _InvoiceReturnItemModel.fromJson(Map<String, dynamic> json) => _$InvoiceReturnItemModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'return_id') final  String returnId;
@override@JsonKey(name: 'invoice_item_id') final  String invoiceItemId;
@override@JsonKey(name: 'product_id') final  String productId;
@override final  int quantity;
@override@JsonKey(name: 'unit_price') final  double unitPrice;
@override@JsonKey(name: 'total_price') final  double totalPrice;
@override final  ReturnReason reason;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of InvoiceReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceReturnItemModelCopyWith<_InvoiceReturnItemModel> get copyWith => __$InvoiceReturnItemModelCopyWithImpl<_InvoiceReturnItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceReturnItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceReturnItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,returnId,invoiceItemId,productId,quantity,unitPrice,totalPrice,reason,createdAt);

@override
String toString() {
  return 'InvoiceReturnItemModel(id: $id, returnId: $returnId, invoiceItemId: $invoiceItemId, productId: $productId, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceReturnItemModelCopyWith<$Res> implements $InvoiceReturnItemModelCopyWith<$Res> {
  factory _$InvoiceReturnItemModelCopyWith(_InvoiceReturnItemModel value, $Res Function(_InvoiceReturnItemModel) _then) = __$InvoiceReturnItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'return_id') String returnId,@JsonKey(name: 'invoice_item_id') String invoiceItemId,@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'unit_price') double unitPrice,@JsonKey(name: 'total_price') double totalPrice, ReturnReason reason,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$InvoiceReturnItemModelCopyWithImpl<$Res>
    implements _$InvoiceReturnItemModelCopyWith<$Res> {
  __$InvoiceReturnItemModelCopyWithImpl(this._self, this._then);

  final _InvoiceReturnItemModel _self;
  final $Res Function(_InvoiceReturnItemModel) _then;

/// Create a copy of InvoiceReturnItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? returnId = null,Object? invoiceItemId = null,Object? productId = null,Object? quantity = null,Object? unitPrice = null,Object? totalPrice = null,Object? reason = null,Object? createdAt = null,}) {
  return _then(_InvoiceReturnItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ReturnReason,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
