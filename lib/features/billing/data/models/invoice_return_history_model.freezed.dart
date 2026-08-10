// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_return_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceReturnHistoryModel {

@JsonKey(name: 'return_id') String get returnId;@JsonKey(name: 'return_number') String get returnNumber;@JsonKey(name: 'return_type') ReturnType get returnType;@JsonKey(name: 'refund_amount') double get refundAmount; String? get notes;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of InvoiceReturnHistoryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceReturnHistoryModelCopyWith<InvoiceReturnHistoryModel> get copyWith => _$InvoiceReturnHistoryModelCopyWithImpl<InvoiceReturnHistoryModel>(this as InvoiceReturnHistoryModel, _$identity);

  /// Serializes this InvoiceReturnHistoryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceReturnHistoryModel&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.returnNumber, returnNumber) || other.returnNumber == returnNumber)&&(identical(other.returnType, returnType) || other.returnType == returnType)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnId,returnNumber,returnType,refundAmount,notes,createdAt);

@override
String toString() {
  return 'InvoiceReturnHistoryModel(returnId: $returnId, returnNumber: $returnNumber, returnType: $returnType, refundAmount: $refundAmount, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceReturnHistoryModelCopyWith<$Res>  {
  factory $InvoiceReturnHistoryModelCopyWith(InvoiceReturnHistoryModel value, $Res Function(InvoiceReturnHistoryModel) _then) = _$InvoiceReturnHistoryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'return_id') String returnId,@JsonKey(name: 'return_number') String returnNumber,@JsonKey(name: 'return_type') ReturnType returnType,@JsonKey(name: 'refund_amount') double refundAmount, String? notes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$InvoiceReturnHistoryModelCopyWithImpl<$Res>
    implements $InvoiceReturnHistoryModelCopyWith<$Res> {
  _$InvoiceReturnHistoryModelCopyWithImpl(this._self, this._then);

  final InvoiceReturnHistoryModel _self;
  final $Res Function(InvoiceReturnHistoryModel) _then;

/// Create a copy of InvoiceReturnHistoryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? returnId = null,Object? returnNumber = null,Object? returnType = null,Object? refundAmount = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,returnNumber: null == returnNumber ? _self.returnNumber : returnNumber // ignore: cast_nullable_to_non_nullable
as String,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ReturnType,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceReturnHistoryModel].
extension InvoiceReturnHistoryModelPatterns on InvoiceReturnHistoryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceReturnHistoryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceReturnHistoryModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceReturnHistoryModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'refund_amount')  double refundAmount,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel() when $default != null:
return $default(_that.returnId,_that.returnNumber,_that.returnType,_that.refundAmount,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'refund_amount')  double refundAmount,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel():
return $default(_that.returnId,_that.returnNumber,_that.returnType,_that.refundAmount,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'return_id')  String returnId, @JsonKey(name: 'return_number')  String returnNumber, @JsonKey(name: 'return_type')  ReturnType returnType, @JsonKey(name: 'refund_amount')  double refundAmount,  String? notes, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceReturnHistoryModel() when $default != null:
return $default(_that.returnId,_that.returnNumber,_that.returnType,_that.refundAmount,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceReturnHistoryModel implements InvoiceReturnHistoryModel {
  const _InvoiceReturnHistoryModel({@JsonKey(name: 'return_id') required this.returnId, @JsonKey(name: 'return_number') required this.returnNumber, @JsonKey(name: 'return_type') required this.returnType, @JsonKey(name: 'refund_amount') required this.refundAmount, this.notes, @JsonKey(name: 'created_at') required this.createdAt});
  factory _InvoiceReturnHistoryModel.fromJson(Map<String, dynamic> json) => _$InvoiceReturnHistoryModelFromJson(json);

@override@JsonKey(name: 'return_id') final  String returnId;
@override@JsonKey(name: 'return_number') final  String returnNumber;
@override@JsonKey(name: 'return_type') final  ReturnType returnType;
@override@JsonKey(name: 'refund_amount') final  double refundAmount;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of InvoiceReturnHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceReturnHistoryModelCopyWith<_InvoiceReturnHistoryModel> get copyWith => __$InvoiceReturnHistoryModelCopyWithImpl<_InvoiceReturnHistoryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceReturnHistoryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceReturnHistoryModel&&(identical(other.returnId, returnId) || other.returnId == returnId)&&(identical(other.returnNumber, returnNumber) || other.returnNumber == returnNumber)&&(identical(other.returnType, returnType) || other.returnType == returnType)&&(identical(other.refundAmount, refundAmount) || other.refundAmount == refundAmount)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,returnId,returnNumber,returnType,refundAmount,notes,createdAt);

@override
String toString() {
  return 'InvoiceReturnHistoryModel(returnId: $returnId, returnNumber: $returnNumber, returnType: $returnType, refundAmount: $refundAmount, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceReturnHistoryModelCopyWith<$Res> implements $InvoiceReturnHistoryModelCopyWith<$Res> {
  factory _$InvoiceReturnHistoryModelCopyWith(_InvoiceReturnHistoryModel value, $Res Function(_InvoiceReturnHistoryModel) _then) = __$InvoiceReturnHistoryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'return_id') String returnId,@JsonKey(name: 'return_number') String returnNumber,@JsonKey(name: 'return_type') ReturnType returnType,@JsonKey(name: 'refund_amount') double refundAmount, String? notes,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$InvoiceReturnHistoryModelCopyWithImpl<$Res>
    implements _$InvoiceReturnHistoryModelCopyWith<$Res> {
  __$InvoiceReturnHistoryModelCopyWithImpl(this._self, this._then);

  final _InvoiceReturnHistoryModel _self;
  final $Res Function(_InvoiceReturnHistoryModel) _then;

/// Create a copy of InvoiceReturnHistoryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? returnId = null,Object? returnNumber = null,Object? returnType = null,Object? refundAmount = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_InvoiceReturnHistoryModel(
returnId: null == returnId ? _self.returnId : returnId // ignore: cast_nullable_to_non_nullable
as String,returnNumber: null == returnNumber ? _self.returnNumber : returnNumber // ignore: cast_nullable_to_non_nullable
as String,returnType: null == returnType ? _self.returnType : returnType // ignore: cast_nullable_to_non_nullable
as ReturnType,refundAmount: null == refundAmount ? _self.refundAmount : refundAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
