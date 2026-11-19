// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayState {

/// The record of today.
 DayRecord get record;/// Whether the record of today is still loading.
 bool get loading;/// The streak as it stands.
 StreakSnapshot get streak;/// The most recently used tags, for the row on Today.
 List<DayTagView> get recentTags;/// The two most recent entries with something on them.
 List<RecentEntry> get recentEntries;/// The sentence explaining the last failure, when there was one.
 String? get errorMessage;
/// Create a copy of DayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayStateCopyWith<DayState> get copyWith => _$DayStateCopyWithImpl<DayState>(this as DayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayState&&(identical(other.record, _this.record) || other.record == _this.record)&&(identical(other.loading, _this.loading) || other.loading == _this.loading)&&(identical(other.streak, _this.streak) || other.streak == _this.streak)&&const DeepCollectionEquality().equals(other.recentTags, _this.recentTags)&&const DeepCollectionEquality().equals(other.recentEntries, _this.recentEntries)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as DayState;
  return Object.hash(runtimeType,_this.record,_this.loading,_this.streak,const DeepCollectionEquality().hash(_this.recentTags),const DeepCollectionEquality().hash(_this.recentEntries),_this.errorMessage);
}

@override
String toString() {
  final _this = this as DayState;
  return 'DayState(record: ${_this.record}, loading: ${_this.loading}, streak: ${_this.streak}, recentTags: ${_this.recentTags}, recentEntries: ${_this.recentEntries}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $DayStateCopyWith<$Res>  {
  factory $DayStateCopyWith(DayState value, $Res Function(DayState) _then) = _$DayStateCopyWithImpl;
@useResult
$Res call({
 DayRecord record, bool loading, StreakSnapshot streak, List<DayTagView> recentTags, List<RecentEntry> recentEntries, String? errorMessage
});




}
/// @nodoc
class _$DayStateCopyWithImpl<$Res>
    implements $DayStateCopyWith<$Res> {
  _$DayStateCopyWithImpl(this._self, this._then);

  final DayState _self;
  final $Res Function(DayState) _then;

/// Create a copy of DayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? record = null,Object? loading = null,Object? streak = null,Object? recentTags = null,Object? recentEntries = null,Object? errorMessage = freezed,}) {
  return _then(DayState(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as DayRecord,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakSnapshot,recentTags: null == recentTags ? _self.recentTags : recentTags // ignore: cast_nullable_to_non_nullable
as List<DayTagView>,recentEntries: null == recentEntries ? _self.recentEntries : recentEntries // ignore: cast_nullable_to_non_nullable
as List<RecentEntry>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DayState].
extension DayStatePatterns on DayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayState value)  $default,){
final _that = this;
switch (_that) {
case _DayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayState value)?  $default,){
final _that = this;
switch (_that) {
case _DayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DayRecord record,  bool loading,  StreakSnapshot streak,  List<DayTagView> recentTags,  List<RecentEntry> recentEntries,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayState() when $default != null:
return $default(_that.record,_that.loading,_that.streak,_that.recentTags,_that.recentEntries,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DayRecord record,  bool loading,  StreakSnapshot streak,  List<DayTagView> recentTags,  List<RecentEntry> recentEntries,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DayState():
return $default(_that.record,_that.loading,_that.streak,_that.recentTags,_that.recentEntries,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DayRecord record,  bool loading,  StreakSnapshot streak,  List<DayTagView> recentTags,  List<RecentEntry> recentEntries,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DayState() when $default != null:
return $default(_that.record,_that.loading,_that.streak,_that.recentTags,_that.recentEntries,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DayState implements DayState {
  const _DayState({required this.record, this.loading = true, this.streak = const StreakSnapshot(current: 0, longest: 0, graceRemaining: 1, lastKeptDate: null, recoveredDates: <String>[]),  List<DayTagView> recentTags = const <DayTagView>[],  List<RecentEntry> recentEntries = const <RecentEntry>[], this.errorMessage}): _recentTags = recentTags,_recentEntries = recentEntries;
  

/// The record of today.
@override final  DayRecord record;
/// Whether the record of today is still loading.
@override@JsonKey() final  bool loading;
/// The streak as it stands.
@override@JsonKey() final  StreakSnapshot streak;
/// The most recently used tags, for the row on Today.
 final  List<DayTagView> _recentTags;
/// The most recently used tags, for the row on Today.
@override@JsonKey() List<DayTagView> get recentTags {
  if (_recentTags is EqualUnmodifiableListView) return _recentTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTags);
}

/// The two most recent entries with something on them.
 final  List<RecentEntry> _recentEntries;
/// The two most recent entries with something on them.
@override@JsonKey() List<RecentEntry> get recentEntries {
  if (_recentEntries is EqualUnmodifiableListView) return _recentEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentEntries);
}

/// The sentence explaining the last failure, when there was one.
@override final  String? errorMessage;

/// Create a copy of DayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayStateCopyWith<_DayState> get copyWith => __$DayStateCopyWithImpl<_DayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayState&&(identical(other.record, record) || other.record == record)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.streak, streak) || other.streak == streak)&&const DeepCollectionEquality().equals(other.recentTags, _recentTags)&&const DeepCollectionEquality().equals(other.recentEntries, _recentEntries)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,record,loading,streak,const DeepCollectionEquality().hash(_recentTags),const DeepCollectionEquality().hash(_recentEntries),errorMessage);
}

@override
String toString() {
    return 'DayState(record: $record, loading: $loading, streak: $streak, recentTags: $recentTags, recentEntries: $recentEntries, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DayStateCopyWith<$Res> implements $DayStateCopyWith<$Res> {
  factory _$DayStateCopyWith(_DayState value, $Res Function(_DayState) _then) = __$DayStateCopyWithImpl;
@override @useResult
$Res call({
 DayRecord record, bool loading, StreakSnapshot streak, List<DayTagView> recentTags, List<RecentEntry> recentEntries, String? errorMessage
});




}
/// @nodoc
class __$DayStateCopyWithImpl<$Res>
    implements _$DayStateCopyWith<$Res> {
  __$DayStateCopyWithImpl(this._self, this._then);

  final _DayState _self;
  final $Res Function(_DayState) _then;

/// Create a copy of DayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? record = null,Object? loading = null,Object? streak = null,Object? recentTags = null,Object? recentEntries = null,Object? errorMessage = freezed,}) {
  return _then(_DayState(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as DayRecord,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakSnapshot,recentTags: null == recentTags ? _self._recentTags : recentTags // ignore: cast_nullable_to_non_nullable
as List<DayTagView>,recentEntries: null == recentEntries ? _self._recentEntries : recentEntries // ignore: cast_nullable_to_non_nullable
as List<RecentEntry>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
