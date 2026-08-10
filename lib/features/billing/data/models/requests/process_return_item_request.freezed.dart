// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'process_return_item_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProcessReturnItemRequest {

@JsonKey(name: 'invoice_item_id') String get invoiceItemId; int get quantity;
/// Create a copy of ProcessReturnItemRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessReturnItemRequestCopyWith<ProcessReturnItemRequest> get copyWith => _$ProcessReturnItemRequestCopyWithImpl<ProcessReturnItemRequest>(this as ProcessReturnItemRequest, _$identity);

  /// Serializes this ProcessReturnItemRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessReturnItemRequest&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceItemId,quantity);

@override
String toString() {
  return 'ProcessReturnItemRequest(invoiceItemId: $invoiceItemId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $ProcessReturnItemRequestCopyWith<$Res>  {
  factory $ProcessReturnItemRequestCopyWith(ProcessReturnItemRequest value, $Res Function(ProcessReturnItemRequest) _then) = _$ProcessReturnItemRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'invoice_item_id') String invoiceItemId, int quantity
});




}
/// @nodoc
class _$ProcessReturnItemRequestCopyWithImpl<$Res>
    implements $ProcessReturnItemRequestCopyWith<$Res> {
  _$ProcessReturnItemRequestCopyWithImpl(this._self, this._then);

  final ProcessReturnItemRequest _self;
  final $Res Function(ProcessReturnItemRequest) _then;

/// Create a copy of ProcessReturnItemRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoiceItemId = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessReturnItemRequest].
extension ProcessReturnItemRequestPatterns on ProcessReturnItemRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessReturnItemRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessReturnItemRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessReturnItemRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProcessReturnItemRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessReturnItemRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessReturnItemRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessReturnItemRequest() when $default != null:
return $default(_that.invoiceItemId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _ProcessReturnItemRequest():
return $default(_that.invoiceItemId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'invoice_item_id')  String invoiceItemId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _ProcessReturnItemRequest() when $default != null:
return $default(_that.invoiceItemId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessReturnItemRequest implements ProcessReturnItemRequest {
  const _ProcessReturnItemRequest({@JsonKey(name: 'invoice_item_id') required this.invoiceItemId, required this.quantity});
  factory _ProcessReturnItemRequest.fromJson(Map<String, dynamic> json) => _$ProcessReturnItemRequestFromJson(json);

@override@JsonKey(name: 'invoice_item_id') final  String invoiceItemId;
@override final  int quantity;

/// Create a copy of ProcessReturnItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessReturnItemRequestCopyWith<_ProcessReturnItemRequest> get copyWith => __$ProcessReturnItemRequestCopyWithImpl<_ProcessReturnItemRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessReturnItemRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessReturnItemRequest&&(identical(other.invoiceItemId, invoiceItemId) || other.invoiceItemId == invoiceItemId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceItemId,quantity);

@override
String toString() {
  return 'ProcessReturnItemRequest(invoiceItemId: $invoiceItemId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ProcessReturnItemRequestCopyWith<$Res> implements $ProcessReturnItemRequestCopyWith<$Res> {
  factory _$ProcessReturnItemRequestCopyWith(_ProcessReturnItemRequest value, $Res Function(_ProcessReturnItemRequest) _then) = __$ProcessReturnItemRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'invoice_item_id') String invoiceItemId, int quantity
});




}
/// @nodoc
class __$ProcessReturnItemRequestCopyWithImpl<$Res>
    implements _$ProcessReturnItemRequestCopyWith<$Res> {
  __$ProcessReturnItemRequestCopyWithImpl(this._self, this._then);

  final _ProcessReturnItemRequest _self;
  final $Res Function(_ProcessReturnItemRequest) _then;

/// Create a copy of ProcessReturnItemRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoiceItemId = null,Object? quantity = null,}) {
  return _then(_ProcessReturnItemRequest(
invoiceItemId: null == invoiceItemId ? _self.invoiceItemId : invoiceItemId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
