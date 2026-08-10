// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'process_invoice_return_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProcessInvoiceReturnRequest {

@JsonKey(name: 'p_invoice_id') String get invoiceId;@JsonKey(name: 'p_store_id') String get storeId;@JsonKey(name: 'p_return_reason') String get returnReason;@JsonKey(name: 'p_notes') String? get notes;@JsonKey(name: 'p_return_items') List<ProcessReturnItemRequest> get returnItems;
/// Create a copy of ProcessInvoiceReturnRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessInvoiceReturnRequestCopyWith<ProcessInvoiceReturnRequest> get copyWith => _$ProcessInvoiceReturnRequestCopyWithImpl<ProcessInvoiceReturnRequest>(this as ProcessInvoiceReturnRequest, _$identity);

  /// Serializes this ProcessInvoiceReturnRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessInvoiceReturnRequest&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.returnReason, returnReason) || other.returnReason == returnReason)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.returnItems, returnItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,storeId,returnReason,notes,const DeepCollectionEquality().hash(returnItems));

@override
String toString() {
  return 'ProcessInvoiceReturnRequest(invoiceId: $invoiceId, storeId: $storeId, returnReason: $returnReason, notes: $notes, returnItems: $returnItems)';
}


}

/// @nodoc
abstract mixin class $ProcessInvoiceReturnRequestCopyWith<$Res>  {
  factory $ProcessInvoiceReturnRequestCopyWith(ProcessInvoiceReturnRequest value, $Res Function(ProcessInvoiceReturnRequest) _then) = _$ProcessInvoiceReturnRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'p_invoice_id') String invoiceId,@JsonKey(name: 'p_store_id') String storeId,@JsonKey(name: 'p_return_reason') String returnReason,@JsonKey(name: 'p_notes') String? notes,@JsonKey(name: 'p_return_items') List<ProcessReturnItemRequest> returnItems
});




}
/// @nodoc
class _$ProcessInvoiceReturnRequestCopyWithImpl<$Res>
    implements $ProcessInvoiceReturnRequestCopyWith<$Res> {
  _$ProcessInvoiceReturnRequestCopyWithImpl(this._self, this._then);

  final ProcessInvoiceReturnRequest _self;
  final $Res Function(ProcessInvoiceReturnRequest) _then;

/// Create a copy of ProcessInvoiceReturnRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoiceId = null,Object? storeId = null,Object? returnReason = null,Object? notes = freezed,Object? returnItems = null,}) {
  return _then(_self.copyWith(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,returnReason: null == returnReason ? _self.returnReason : returnReason // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,returnItems: null == returnItems ? _self.returnItems : returnItems // ignore: cast_nullable_to_non_nullable
as List<ProcessReturnItemRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessInvoiceReturnRequest].
extension ProcessInvoiceReturnRequestPatterns on ProcessInvoiceReturnRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProcessInvoiceReturnRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProcessInvoiceReturnRequest value)  $default,){
final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProcessInvoiceReturnRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'p_invoice_id')  String invoiceId, @JsonKey(name: 'p_store_id')  String storeId, @JsonKey(name: 'p_return_reason')  String returnReason, @JsonKey(name: 'p_notes')  String? notes, @JsonKey(name: 'p_return_items')  List<ProcessReturnItemRequest> returnItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest() when $default != null:
return $default(_that.invoiceId,_that.storeId,_that.returnReason,_that.notes,_that.returnItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'p_invoice_id')  String invoiceId, @JsonKey(name: 'p_store_id')  String storeId, @JsonKey(name: 'p_return_reason')  String returnReason, @JsonKey(name: 'p_notes')  String? notes, @JsonKey(name: 'p_return_items')  List<ProcessReturnItemRequest> returnItems)  $default,) {final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest():
return $default(_that.invoiceId,_that.storeId,_that.returnReason,_that.notes,_that.returnItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'p_invoice_id')  String invoiceId, @JsonKey(name: 'p_store_id')  String storeId, @JsonKey(name: 'p_return_reason')  String returnReason, @JsonKey(name: 'p_notes')  String? notes, @JsonKey(name: 'p_return_items')  List<ProcessReturnItemRequest> returnItems)?  $default,) {final _that = this;
switch (_that) {
case _ProcessInvoiceReturnRequest() when $default != null:
return $default(_that.invoiceId,_that.storeId,_that.returnReason,_that.notes,_that.returnItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProcessInvoiceReturnRequest implements ProcessInvoiceReturnRequest {
  const _ProcessInvoiceReturnRequest({@JsonKey(name: 'p_invoice_id') required this.invoiceId, @JsonKey(name: 'p_store_id') required this.storeId, @JsonKey(name: 'p_return_reason') required this.returnReason, @JsonKey(name: 'p_notes') this.notes, @JsonKey(name: 'p_return_items') required final  List<ProcessReturnItemRequest> returnItems}): _returnItems = returnItems;
  factory _ProcessInvoiceReturnRequest.fromJson(Map<String, dynamic> json) => _$ProcessInvoiceReturnRequestFromJson(json);

@override@JsonKey(name: 'p_invoice_id') final  String invoiceId;
@override@JsonKey(name: 'p_store_id') final  String storeId;
@override@JsonKey(name: 'p_return_reason') final  String returnReason;
@override@JsonKey(name: 'p_notes') final  String? notes;
 final  List<ProcessReturnItemRequest> _returnItems;
@override@JsonKey(name: 'p_return_items') List<ProcessReturnItemRequest> get returnItems {
  if (_returnItems is EqualUnmodifiableListView) return _returnItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_returnItems);
}


/// Create a copy of ProcessInvoiceReturnRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProcessInvoiceReturnRequestCopyWith<_ProcessInvoiceReturnRequest> get copyWith => __$ProcessInvoiceReturnRequestCopyWithImpl<_ProcessInvoiceReturnRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProcessInvoiceReturnRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProcessInvoiceReturnRequest&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.returnReason, returnReason) || other.returnReason == returnReason)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._returnItems, _returnItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,storeId,returnReason,notes,const DeepCollectionEquality().hash(_returnItems));

@override
String toString() {
  return 'ProcessInvoiceReturnRequest(invoiceId: $invoiceId, storeId: $storeId, returnReason: $returnReason, notes: $notes, returnItems: $returnItems)';
}


}

/// @nodoc
abstract mixin class _$ProcessInvoiceReturnRequestCopyWith<$Res> implements $ProcessInvoiceReturnRequestCopyWith<$Res> {
  factory _$ProcessInvoiceReturnRequestCopyWith(_ProcessInvoiceReturnRequest value, $Res Function(_ProcessInvoiceReturnRequest) _then) = __$ProcessInvoiceReturnRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'p_invoice_id') String invoiceId,@JsonKey(name: 'p_store_id') String storeId,@JsonKey(name: 'p_return_reason') String returnReason,@JsonKey(name: 'p_notes') String? notes,@JsonKey(name: 'p_return_items') List<ProcessReturnItemRequest> returnItems
});




}
/// @nodoc
class __$ProcessInvoiceReturnRequestCopyWithImpl<$Res>
    implements _$ProcessInvoiceReturnRequestCopyWith<$Res> {
  __$ProcessInvoiceReturnRequestCopyWithImpl(this._self, this._then);

  final _ProcessInvoiceReturnRequest _self;
  final $Res Function(_ProcessInvoiceReturnRequest) _then;

/// Create a copy of ProcessInvoiceReturnRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? storeId = null,Object? returnReason = null,Object? notes = freezed,Object? returnItems = null,}) {
  return _then(_ProcessInvoiceReturnRequest(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,returnReason: null == returnReason ? _self.returnReason : returnReason // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,returnItems: null == returnItems ? _self._returnItems : returnItems // ignore: cast_nullable_to_non_nullable
as List<ProcessReturnItemRequest>,
  ));
}


}

// dart format on
