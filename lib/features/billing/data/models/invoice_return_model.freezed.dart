// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_return_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceReturnModel {

/// Primary Key
 String get id;/// Store ID
@JsonKey(name: 'store_id') String get storeId;/// Original Invoice ID
@JsonKey(name: 'invoice_id') String get invoiceId;/// Return Number (e.g. RET-000001)
@JsonKey(name: 'return_number') String get returnNumber;/// Return Type
@JsonKey(name: 'return_type') ReturnType get returnType;/// Total amount associated with this return
@JsonKey(name: 'returned_amount') double get returnedAmount;/// Optional Notes
 String? get notes;/// User who processed the return
@JsonKey(name: 'created_by') String get createdBy;/// Creation Timestamp
@JsonKey(name: 'created_at') DateTime get createdAt;/// Last Updated Timestamp
@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of InvoiceReturnModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceReturnModelCopyWith<InvoiceReturnModel> get copyWith => _$InvoiceReturnModelCopyWithImpl<InvoiceReturnModel>(this as InvoiceReturnModel, _$identity);

  /// Serializes this InvoiceReturnModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceReturnModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.returnNumber, returnNumber) || other.returnNumber == returnNumber)&&(identical(other.returnType, returnType) || other.returnType == returnType)&&(identical(other.returnedAmount, returnedAmount) || other.returnedAmount == returnedAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,invoiceId,returnNumber,returnType,returnedAmount,notes,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'InvoiceReturnModel(id: $id, storeId: $storeId, invoiceId: $invoiceId, returnNumber: $returnNumber, returnType: $returnType, returnedAmount: $returnedAmount, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceReturnModelCopyWith<$Res>  {
  factory $InvoiceReturnModelCopyWith(InvoiceReturnModel value, $Res Function(InvoiceReturnModel) _then) = _$InvoiceReturnModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'return_number') String returnNumber,@JsonKey(name: 'return_type') ReturnType returnType,@JsonKey(name: 'returned_amount') double returnedAmount, String? notes,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$InvoiceReturnModelCopyWithImpl<$Res>
    implements $InvoiceReturnModelCopyWith<$Res> {
  _$InvoiceReturnModelCopyWithImpl(this._self, this._then);

  final InvoiceReturnModel _self;
  final $Res Function(InvoiceReturnModel) _then;

/// Create a copy of InvoiceReturnModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? invoiceId = null,Object? returnNumber = null,Object? returnType = null,Object? returnedAmount = null,Object? notes = freezed,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,returnNumber: null == returnNumber ? _self.returnNumber : returnNumber // ignore: cast_nullable_to_non_nullable
as String,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ReturnType,returnedAmount: null == returnedAmount ? _self.returnedAmount : returnedAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceReturnModel].
extension InvoiceReturnModelPatterns on InvoiceReturnModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceReturnModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceReturnModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceReturnModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceReturnModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'returned_amount')  double returnedAmount,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceReturnModel() when $default != null:
return $default(_that.id,_that.storeId,_that.invoiceId,_that.returnNumber,_that.returnType,_that.returnedAmount,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'returned_amount')  double returnedAmount,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnModel():
return $default(_that.id,_that.storeId,_that.invoiceId,_that.returnNumber,_that.returnType,_that.returnedAmount,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'returned_amount')  double returnedAmount,  String? notes, @JsonKey(name: 'created_by')  String createdBy, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnModel() when $default != null:
return $default(_that.id,_that.storeId,_that.invoiceId,_that.returnNumber,_that.returnType,_that.returnedAmount,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceReturnModel implements InvoiceReturnModel {
  const _InvoiceReturnModel({required this.id, @JsonKey(name: 'store_id') required this.storeId, @JsonKey(name: 'invoice_id') required this.invoiceId, @JsonKey(name: 'return_number') required this.returnNumber, @JsonKey(name: 'return_type') required this.returnType, @JsonKey(name: 'returned_amount') required this.returnedAmount, this.notes, @JsonKey(name: 'created_by') required this.createdBy, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _InvoiceReturnModel.fromJson(Map<String, dynamic> json) => _$InvoiceReturnModelFromJson(json);

/// Primary Key
@override final  String id;
/// Store ID
@override@JsonKey(name: 'store_id') final  String storeId;
/// Original Invoice ID
@override@JsonKey(name: 'invoice_id') final  String invoiceId;
/// Return Number (e.g. RET-000001)
@override@JsonKey(name: 'return_number') final  String returnNumber;
/// Return Type
@override@JsonKey(name: 'return_type') final  ReturnType returnType;
/// Total amount associated with this return
@override@JsonKey(name: 'returned_amount') final  double returnedAmount;
/// Optional Notes
@override final  String? notes;
/// User who processed the return
@override@JsonKey(name: 'created_by') final  String createdBy;
/// Creation Timestamp
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
/// Last Updated Timestamp
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of InvoiceReturnModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceReturnModelCopyWith<_InvoiceReturnModel> get copyWith => __$InvoiceReturnModelCopyWithImpl<_InvoiceReturnModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceReturnModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceReturnModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.returnNumber, returnNumber) || other.returnNumber == returnNumber)&&(identical(other.returnType, returnType) || other.returnType == returnType)&&(identical(other.returnedAmount, returnedAmount) || other.returnedAmount == returnedAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,invoiceId,returnNumber,returnType,returnedAmount,notes,createdBy,createdAt,updatedAt);

@override
String toString() {
  return 'InvoiceReturnModel(id: $id, storeId: $storeId, invoiceId: $invoiceId, returnNumber: $returnNumber, returnType: $returnType, returnedAmount: $returnedAmount, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceReturnModelCopyWith<$Res> implements $InvoiceReturnModelCopyWith<$Res> {
  factory _$InvoiceReturnModelCopyWith(_InvoiceReturnModel value, $Res Function(_InvoiceReturnModel) _then) = __$InvoiceReturnModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'return_number') String returnNumber,@JsonKey(name: 'return_type') ReturnType returnType,@JsonKey(name: 'returned_amount') double returnedAmount, String? notes,@JsonKey(name: 'created_by') String createdBy,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$InvoiceReturnModelCopyWithImpl<$Res>
    implements _$InvoiceReturnModelCopyWith<$Res> {
  __$InvoiceReturnModelCopyWithImpl(this._self, this._then);

  final _InvoiceReturnModel _self;
  final $Res Function(_InvoiceReturnModel) _then;

/// Create a copy of InvoiceReturnModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? invoiceId = null,Object? returnNumber = null,Object? returnType = null,Object? returnedAmount = null,Object? notes = freezed,Object? createdBy = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_InvoiceReturnModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,returnNumber: null == returnNumber ? _self.returnNumber : returnNumber // ignore: cast_nullable_to_non_nullable
as String,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ReturnType,returnedAmount: null == returnedAmount ? _self.returnedAmount : returnedAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
