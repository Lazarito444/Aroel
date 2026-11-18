// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountSnapshot {

/// The kind of account.
 AccountStatus get status;/// The identifier this device writes its rows under.
 String get localUserId;/// The identifier of the linked account, when there is one.
 String? get accountUserId;/// The address of the linked account.
 String? get email;/// The name shown in the app.
 String get displayName;/// The timezone the days are counted in.
 String get timeZone;/// Whether the address has been confirmed.
 bool get emailVerified;/// Whether the journal on this device lives under an identifier of its own.
///
/// It happens when a reader with a journal on the device signs in to an account that
/// was made elsewhere: the journal stays here, because a row is never re-keyed (§4.2).
 bool get localJournalIsSeparate;/// When the bearer token stops being accepted.
 DateTime? get accessTokenExpiresAt;
/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountSnapshotCopyWith<AccountSnapshot> get copyWith => _$AccountSnapshotCopyWithImpl<AccountSnapshot>(this as AccountSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountSnapshot&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.localUserId, _this.localUserId) || other.localUserId == _this.localUserId)&&(identical(other.accountUserId, _this.accountUserId) || other.accountUserId == _this.accountUserId)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.localJournalIsSeparate, _this.localJournalIsSeparate) || other.localJournalIsSeparate == _this.localJournalIsSeparate)&&(identical(other.accessTokenExpiresAt, _this.accessTokenExpiresAt) || other.accessTokenExpiresAt == _this.accessTokenExpiresAt));
}


@override
int get hashCode {
  final _this = this as AccountSnapshot;
  return Object.hash(runtimeType,_this.status,_this.localUserId,_this.accountUserId,_this.email,_this.displayName,_this.timeZone,_this.emailVerified,_this.localJournalIsSeparate,_this.accessTokenExpiresAt);
}

@override
String toString() {
  final _this = this as AccountSnapshot;
  return 'AccountSnapshot(status: ${_this.status}, localUserId: ${_this.localUserId}, accountUserId: ${_this.accountUserId}, email: ${_this.email}, displayName: ${_this.displayName}, timeZone: ${_this.timeZone}, emailVerified: ${_this.emailVerified}, localJournalIsSeparate: ${_this.localJournalIsSeparate}, accessTokenExpiresAt: ${_this.accessTokenExpiresAt})';
}


}

/// @nodoc
abstract mixin class $AccountSnapshotCopyWith<$Res>  {
  factory $AccountSnapshotCopyWith(AccountSnapshot value, $Res Function(AccountSnapshot) _then) = _$AccountSnapshotCopyWithImpl;
@useResult
$Res call({
 AccountStatus status, String localUserId, String? accountUserId, String? email, String displayName, String timeZone, bool emailVerified, bool localJournalIsSeparate, DateTime? accessTokenExpiresAt
});




}
/// @nodoc
class _$AccountSnapshotCopyWithImpl<$Res>
    implements $AccountSnapshotCopyWith<$Res> {
  _$AccountSnapshotCopyWithImpl(this._self, this._then);

  final AccountSnapshot _self;
  final $Res Function(AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? localUserId = null,Object? accountUserId = freezed,Object? email = freezed,Object? displayName = null,Object? timeZone = null,Object? emailVerified = null,Object? localJournalIsSeparate = null,Object? accessTokenExpiresAt = freezed,}) {
  return _then(AccountSnapshot(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,localUserId: null == localUserId ? _self.localUserId : localUserId // ignore: cast_nullable_to_non_nullable
as String,accountUserId: freezed == accountUserId ? _self.accountUserId : accountUserId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,localJournalIsSeparate: null == localJournalIsSeparate ? _self.localJournalIsSeparate : localJournalIsSeparate // ignore: cast_nullable_to_non_nullable
as bool,accessTokenExpiresAt: freezed == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountSnapshot].
extension AccountSnapshotPatterns on AccountSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountStatus status,  String localUserId,  String? accountUserId,  String? email,  String displayName,  String timeZone,  bool emailVerified,  bool localJournalIsSeparate,  DateTime? accessTokenExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.status,_that.localUserId,_that.accountUserId,_that.email,_that.displayName,_that.timeZone,_that.emailVerified,_that.localJournalIsSeparate,_that.accessTokenExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountStatus status,  String localUserId,  String? accountUserId,  String? email,  String displayName,  String timeZone,  bool emailVerified,  bool localJournalIsSeparate,  DateTime? accessTokenExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot():
return $default(_that.status,_that.localUserId,_that.accountUserId,_that.email,_that.displayName,_that.timeZone,_that.emailVerified,_that.localJournalIsSeparate,_that.accessTokenExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountStatus status,  String localUserId,  String? accountUserId,  String? email,  String displayName,  String timeZone,  bool emailVerified,  bool localJournalIsSeparate,  DateTime? accessTokenExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.status,_that.localUserId,_that.accountUserId,_that.email,_that.displayName,_that.timeZone,_that.emailVerified,_that.localJournalIsSeparate,_that.accessTokenExpiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _AccountSnapshot extends AccountSnapshot {
  const _AccountSnapshot({required this.status, required this.localUserId, this.accountUserId, this.email, this.displayName = '', this.timeZone = '', this.emailVerified = false, this.localJournalIsSeparate = false, this.accessTokenExpiresAt}): super._();
  

/// The kind of account.
@override final  AccountStatus status;
/// The identifier this device writes its rows under.
@override final  String localUserId;
/// The identifier of the linked account, when there is one.
@override final  String? accountUserId;
/// The address of the linked account.
@override final  String? email;
/// The name shown in the app.
@override@JsonKey() final  String displayName;
/// The timezone the days are counted in.
@override@JsonKey() final  String timeZone;
/// Whether the address has been confirmed.
@override@JsonKey() final  bool emailVerified;
/// Whether the journal on this device lives under an identifier of its own.
///
/// It happens when a reader with a journal on the device signs in to an account that
/// was made elsewhere: the journal stays here, because a row is never re-keyed (§4.2).
@override@JsonKey() final  bool localJournalIsSeparate;
/// When the bearer token stops being accepted.
@override final  DateTime? accessTokenExpiresAt;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountSnapshotCopyWith<_AccountSnapshot> get copyWith => __$AccountSnapshotCopyWithImpl<_AccountSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountSnapshot&&(identical(other.status, status) || other.status == status)&&(identical(other.localUserId, localUserId) || other.localUserId == localUserId)&&(identical(other.accountUserId, accountUserId) || other.accountUserId == accountUserId)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.localJournalIsSeparate, localJournalIsSeparate) || other.localJournalIsSeparate == localJournalIsSeparate)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,localUserId,accountUserId,email,displayName,timeZone,emailVerified,localJournalIsSeparate,accessTokenExpiresAt);
}

@override
String toString() {
    return 'AccountSnapshot(status: $status, localUserId: $localUserId, accountUserId: $accountUserId, email: $email, displayName: $displayName, timeZone: $timeZone, emailVerified: $emailVerified, localJournalIsSeparate: $localJournalIsSeparate, accessTokenExpiresAt: $accessTokenExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$AccountSnapshotCopyWith<$Res> implements $AccountSnapshotCopyWith<$Res> {
  factory _$AccountSnapshotCopyWith(_AccountSnapshot value, $Res Function(_AccountSnapshot) _then) = __$AccountSnapshotCopyWithImpl;
@override @useResult
$Res call({
 AccountStatus status, String localUserId, String? accountUserId, String? email, String displayName, String timeZone, bool emailVerified, bool localJournalIsSeparate, DateTime? accessTokenExpiresAt
});




}
/// @nodoc
class __$AccountSnapshotCopyWithImpl<$Res>
    implements _$AccountSnapshotCopyWith<$Res> {
  __$AccountSnapshotCopyWithImpl(this._self, this._then);

  final _AccountSnapshot _self;
  final $Res Function(_AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? localUserId = null,Object? accountUserId = freezed,Object? email = freezed,Object? displayName = null,Object? timeZone = null,Object? emailVerified = null,Object? localJournalIsSeparate = null,Object? accessTokenExpiresAt = freezed,}) {
  return _then(_AccountSnapshot(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountStatus,localUserId: null == localUserId ? _self.localUserId : localUserId // ignore: cast_nullable_to_non_nullable
as String,accountUserId: freezed == accountUserId ? _self.accountUserId : accountUserId // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,localJournalIsSeparate: null == localJournalIsSeparate ? _self.localJournalIsSeparate : localJournalIsSeparate // ignore: cast_nullable_to_non_nullable
as bool,accessTokenExpiresAt: freezed == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
