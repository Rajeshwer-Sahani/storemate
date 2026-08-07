// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_timeline_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InvoiceTimelineModel {

 String get id;@JsonKey(name: 'store_id') String get storeId;@JsonKey(name: 'invoice_id') String get invoiceId;@JsonKey(name: 'event_type') String get eventType;@JsonKey(name: 'event_title') String get eventTitle;@JsonKey(name: 'event_description') String get eventDescription; double? get amount;@JsonKey(name: 'payment_method') String? get paymentMethod;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of InvoiceTimelineModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceTimelineModelCopyWith<InvoiceTimelineModel> get copyWith => _$InvoiceTimelineModelCopyWithImpl<InvoiceTimelineModel>(this as InvoiceTimelineModel, _$identity);

  /// Serializes this InvoiceTimelineModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvoiceTimelineModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.eventTitle, eventTitle) || other.eventTitle == eventTitle)&&(identical(other.eventDescription, eventDescription) || other.eventDescription == eventDescription)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,invoiceId,eventType,eventTitle,eventDescription,amount,paymentMethod,createdAt,updatedAt);

@override
String toString() {
  return 'InvoiceTimelineModel(id: $id, storeId: $storeId, invoiceId: $invoiceId, eventType: $eventType, eventTitle: $eventTitle, eventDescription: $eventDescription, amount: $amount, paymentMethod: $paymentMethod, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvoiceTimelineModelCopyWith<$Res>  {
  factory $InvoiceTimelineModelCopyWith(InvoiceTimelineModel value, $Res Function(InvoiceTimelineModel) _then) = _$InvoiceTimelineModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'event_title') String eventTitle,@JsonKey(name: 'event_description') String eventDescription, double? amount,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$InvoiceTimelineModelCopyWithImpl<$Res>
    implements $InvoiceTimelineModelCopyWith<$Res> {
  _$InvoiceTimelineModelCopyWithImpl(this._self, this._then);

  final InvoiceTimelineModel _self;
  final $Res Function(InvoiceTimelineModel) _then;

/// Create a copy of InvoiceTimelineModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? invoiceId = null,Object? eventType = null,Object? eventTitle = null,Object? eventDescription = null,Object? amount = freezed,Object? paymentMethod = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,eventTitle: null == eventTitle ? _self.eventTitle : eventTitle // ignore: cast_nullable_to_non_nullable
as String,eventDescription: null == eventDescription ? _self.eventDescription : eventDescription // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InvoiceTimelineModel].
extension InvoiceTimelineModelPatterns on InvoiceTimelineModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvoiceTimelineModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvoiceTimelineModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvoiceTimelineModel value)  $default,){
final _that = this;
switch (_that) {
case _InvoiceTimelineModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvoiceTimelineModel value)?  $default,){
final _that = this;
switch (_that) {
case _InvoiceTimelineModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'event_title')  String eventTitle, @JsonKey(name: 'event_description')  String eventDescription,  double? amount, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvoiceTimelineModel() when $default != null:
return $default(_that.id,_that.storeId,_that.invoiceId,_that.eventType,_that.eventTitle,_that.eventDescription,_that.amount,_that.paymentMethod,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'event_title')  String eventTitle, @JsonKey(name: 'event_description')  String eventDescription,  double? amount, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _InvoiceTimelineModel():
return $default(_that.id,_that.storeId,_that.invoiceId,_that.eventType,_that.eventTitle,_that.eventDescription,_that.amount,_that.paymentMethod,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'store_id')  String storeId, @JsonKey(name: 'invoice_id')  String invoiceId, @JsonKey(name: 'event_type')  String eventType, @JsonKey(name: 'event_title')  String eventTitle, @JsonKey(name: 'event_description')  String eventDescription,  double? amount, @JsonKey(name: 'payment_method')  String? paymentMethod, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _InvoiceTimelineModel() when $default != null:
return $default(_that.id,_that.storeId,_that.invoiceId,_that.eventType,_that.eventTitle,_that.eventDescription,_that.amount,_that.paymentMethod,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvoiceTimelineModel implements InvoiceTimelineModel {
  const _InvoiceTimelineModel({required this.id, @JsonKey(name: 'store_id') required this.storeId, @JsonKey(name: 'invoice_id') required this.invoiceId, @JsonKey(name: 'event_type') required this.eventType, @JsonKey(name: 'event_title') required this.eventTitle, @JsonKey(name: 'event_description') required this.eventDescription, this.amount, @JsonKey(name: 'payment_method') this.paymentMethod, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _InvoiceTimelineModel.fromJson(Map<String, dynamic> json) => _$InvoiceTimelineModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'store_id') final  String storeId;
@override@JsonKey(name: 'invoice_id') final  String invoiceId;
@override@JsonKey(name: 'event_type') final  String eventType;
@override@JsonKey(name: 'event_title') final  String eventTitle;
@override@JsonKey(name: 'event_description') final  String eventDescription;
@override final  double? amount;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of InvoiceTimelineModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceTimelineModelCopyWith<_InvoiceTimelineModel> get copyWith => __$InvoiceTimelineModelCopyWithImpl<_InvoiceTimelineModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceTimelineModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvoiceTimelineModel&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.eventTitle, eventTitle) || other.eventTitle == eventTitle)&&(identical(other.eventDescription, eventDescription) || other.eventDescription == eventDescription)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,invoiceId,eventType,eventTitle,eventDescription,amount,paymentMethod,createdAt,updatedAt);

@override
String toString() {
  return 'InvoiceTimelineModel(id: $id, storeId: $storeId, invoiceId: $invoiceId, eventType: $eventType, eventTitle: $eventTitle, eventDescription: $eventDescription, amount: $amount, paymentMethod: $paymentMethod, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvoiceTimelineModelCopyWith<$Res> implements $InvoiceTimelineModelCopyWith<$Res> {
  factory _$InvoiceTimelineModelCopyWith(_InvoiceTimelineModel value, $Res Function(_InvoiceTimelineModel) _then) = __$InvoiceTimelineModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'store_id') String storeId,@JsonKey(name: 'invoice_id') String invoiceId,@JsonKey(name: 'event_type') String eventType,@JsonKey(name: 'event_title') String eventTitle,@JsonKey(name: 'event_description') String eventDescription, double? amount,@JsonKey(name: 'payment_method') String? paymentMethod,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$InvoiceTimelineModelCopyWithImpl<$Res>
    implements _$InvoiceTimelineModelCopyWith<$Res> {
  __$InvoiceTimelineModelCopyWithImpl(this._self, this._then);

  final _InvoiceTimelineModel _self;
  final $Res Function(_InvoiceTimelineModel) _then;

/// Create a copy of InvoiceTimelineModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? invoiceId = null,Object? eventType = null,Object? eventTitle = null,Object? eventDescription = null,Object? amount = freezed,Object? paymentMethod = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_InvoiceTimelineModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,eventTitle: null == eventTitle ? _self.eventTitle : eventTitle // ignore: cast_nullable_to_non_nullable
as String,eventDescription: null == eventDescription ? _self.eventDescription : eventDescription // ignore: cast_nullable_to_non_nullable
as String,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
