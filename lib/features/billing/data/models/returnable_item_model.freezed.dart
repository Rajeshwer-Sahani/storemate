// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'returnable_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReturnableItemModel {

@JsonKey(name: 'invoice_item_id') String get invoiceItemId;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'product_name') String get productName;@JsonKey(name: 'sold_quantity') int get soldQuantity;@JsonKey(name: 'returned_quantity') int get returnedQuantity;@JsonKey(name: 'remaining_quantity') int get remainingQuantity;@JsonKey(name: 'unit_price') double get unitPrice;
/// Create a copy of ReturnableItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReturnableItemModelCopyWith<ReturnableItemModel> get copyWith => _$ReturnableItemModelCopyWithImpl<ReturnableItemModel>(this as ReturnableItemModel, _$identity);

  /// Serializes this ReturnableItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReturnableItemModel&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.soldQuantity, soldQuantity) || other.soldQuantity == soldQuantity)&&(identical(other.returnedQuantity, returnedQuantity) || other.returnedQuantity == returnedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceItemId,productId,productName,soldQuantity,returnedQuantity,remainingQuantity,unitPrice);

@override
String toString() {
  return 'ReturnableItemModel(invoiceItemId: $invoiceItemId, productId: $productId, productName: $productName, soldQuantity: $soldQuantity, returnedQuantity: $returnedQuantity, remainingQuantity: $remainingQuantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class $ReturnableItemModelCopyWith<$Res>  {
  factory $ReturnableItemModelCopyWith(ReturnableItemModel value, $Res Function(ReturnableItemModel) _then) = _$ReturnableItemModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'invoice_item_id') String invoiceItemId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'sold_quantity') int soldQuantity,@JsonKey(name: 'returned_quantity') int returnedQuantity,@JsonKey(name: 'remaining_quantity') int remainingQuantity,@JsonKey(name: 'unit_price') double unitPrice
});




}
/// @nodoc
class _$ReturnableItemModelCopyWithImpl<$Res>
    implements $ReturnableItemModelCopyWith<$Res> {
  _$ReturnableItemModelCopyWithImpl(this._self, this._then);

  final ReturnableItemModel _self;
  final $Res Function(ReturnableItemModel) _then;

/// Create a copy of ReturnableItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoiceItemId = null,Object? productId = null,Object? productName = null,Object? soldQuantity = null,Object? returnedQuantity = null,Object? remainingQuantity = null,Object? unitPrice = null,}) {
  return _then(_self.copyWith(
invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,soldQuantity: null == soldQuantity ? _self.soldQuantity : soldQuantity // ignore: cast_nullable_to_non_nullable
as int,returnedQuantity: null == returnedQuantity ? _self.returnedQuantity : returnedQuantity // ignore: cast_nullable_to_non_nullable
as int,remainingQuantity: null == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ReturnableItemModel].
extension ReturnableItemModelPatterns on ReturnableItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReturnableItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReturnableItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReturnableItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ReturnableItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReturnableItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReturnableItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'sold_quantity')  int soldQuantity, @JsonKey(name: 'returned_quantity')  int returnedQuantity, @JsonKey(name: 'remaining_quantity')  int remainingQuantity, @JsonKey(name: 'unit_price')  double unitPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReturnableItemModel() when $default != null:
return $default(_that.invoiceItemId,_that.productId,_that.productName,_that.soldQuantity,_that.returnedQuantity,_that.remainingQuantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'sold_quantity')  int soldQuantity, @JsonKey(name: 'returned_quantity')  int returnedQuantity, @JsonKey(name: 'remaining_quantity')  int remainingQuantity, @JsonKey(name: 'unit_price')  double unitPrice)  $default,) {final _that = this;
switch (_that) {
case _ReturnableItemModel():
return $default(_that.invoiceItemId,_that.productId,_that.productName,_that.soldQuantity,_that.returnedQuantity,_that.remainingQuantity,_that.unitPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'product_name')  String productName, @JsonKey(name: 'sold_quantity')  int soldQuantity, @JsonKey(name: 'returned_quantity')  int returnedQuantity, @JsonKey(name: 'remaining_quantity')  int remainingQuantity, @JsonKey(name: 'unit_price')  double unitPrice)?  $default,) {final _that = this;
switch (_that) {
case _ReturnableItemModel() when $default != null:
return $default(_that.invoiceItemId,_that.productId,_that.productName,_that.soldQuantity,_that.returnedQuantity,_that.remainingQuantity,_that.unitPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReturnableItemModel implements ReturnableItemModel {
  const _ReturnableItemModel({@JsonKey(name: 'invoice_item_id') required this.invoiceItemId, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'product_name') required this.productName, @JsonKey(name: 'sold_quantity') required this.soldQuantity, @JsonKey(name: 'returned_quantity') required this.returnedQuantity, @JsonKey(name: 'remaining_quantity') required this.remainingQuantity, @JsonKey(name: 'unit_price') required this.unitPrice});
  factory _ReturnableItemModel.fromJson(Map<String, dynamic> json) => _$ReturnableItemModelFromJson(json);

@override@JsonKey(name: 'invoice_item_id') final  String invoiceItemId;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'product_name') final  String productName;
@override@JsonKey(name: 'sold_quantity') final  int soldQuantity;
@override@JsonKey(name: 'returned_quantity') final  int returnedQuantity;
@override@JsonKey(name: 'remaining_quantity') final  int remainingQuantity;
@override@JsonKey(name: 'unit_price') final  double unitPrice;

/// Create a copy of ReturnableItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReturnableItemModelCopyWith<_ReturnableItemModel> get copyWith => __$ReturnableItemModelCopyWithImpl<_ReturnableItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReturnableItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReturnableItemModel&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.soldQuantity, soldQuantity) || other.soldQuantity == soldQuantity)&&(identical(other.returnedQuantity, returnedQuantity) || other.returnedQuantity == returnedQuantity)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceItemId,productId,productName,soldQuantity,returnedQuantity,remainingQuantity,unitPrice);

@override
String toString() {
  return 'ReturnableItemModel(invoiceItemId: $invoiceItemId, productId: $productId, productName: $productName, soldQuantity: $soldQuantity, returnedQuantity: $returnedQuantity, remainingQuantity: $remainingQuantity, unitPrice: $unitPrice)';
}


}

/// @nodoc
abstract mixin class _$ReturnableItemModelCopyWith<$Res> implements $ReturnableItemModelCopyWith<$Res> {
  factory _$ReturnableItemModelCopyWith(_ReturnableItemModel value, $Res Function(_ReturnableItemModel) _then) = __$ReturnableItemModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'invoice_item_id') String invoiceItemId,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'product_name') String productName,@JsonKey(name: 'sold_quantity') int soldQuantity,@JsonKey(name: 'returned_quantity') int returnedQuantity,@JsonKey(name: 'remaining_quantity') int remainingQuantity,@JsonKey(name: 'unit_price') double unitPrice
});




}
/// @nodoc
class __$ReturnableItemModelCopyWithImpl<$Res>
    implements _$ReturnableItemModelCopyWith<$Res> {
  __$ReturnableItemModelCopyWithImpl(this._self, this._then);

  final _ReturnableItemModel _self;
  final $Res Function(_ReturnableItemModel) _then;

/// Create a copy of ReturnableItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoiceItemId = null,Object? productId = null,Object? productName = null,Object? soldQuantity = null,Object? returnedQuantity = null,Object? remainingQuantity = null,Object? unitPrice = null,}) {
  return _then(_ReturnableItemModel(
invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,soldQuantity: null == soldQuantity ? _self.soldQuantity : soldQuantity // ignore: cast_nullable_to_non_nullable
as int,returnedQuantity: null == returnedQuantity ? _self.returnedQuantity : returnedQuantity // ignore: cast_nullable_to_non_nullable
as int,remainingQuantity: null == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
