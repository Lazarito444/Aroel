// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenDto {

 String get accessToken; String get refreshToken; DateTime get accessTokenExpiresAt; DateTime get refreshTokenExpiresAt;
/// Create a copy of TokenDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenDtoCopyWith<TokenDto> get copyWith => _$TokenDtoCopyWithImpl<TokenDto>(this as TokenDto, _$identity);

  /// Serializes this TokenDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt)&&(identical(other.refreshTokenExpiresAt, refreshTokenExpiresAt) || other.refreshTokenExpiresAt == refreshTokenExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,accessTokenExpiresAt,refreshTokenExpiresAt);

@override
String toString() {
  return 'TokenDto(accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt)';
}


}

/// @nodoc
abstract mixin class $TokenDtoCopyWith<$Res>  {
  factory $TokenDtoCopyWith(TokenDto value, $Res Function(TokenDto) _then) = _$TokenDtoCopyWithImpl;
@useResult
$Res call({
 String accessToken, String refreshToken, DateTime accessTokenExpiresAt, DateTime refreshTokenExpiresAt
});




}
/// @nodoc
class _$TokenDtoCopyWithImpl<$Res>
    implements $TokenDtoCopyWith<$Res> {
  _$TokenDtoCopyWithImpl(this._self, this._then);

  final TokenDto _self;
  final $Res Function(TokenDto) _then;

/// Create a copy of TokenDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? accessTokenExpiresAt = null,Object? refreshTokenExpiresAt = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,refreshTokenExpiresAt: null == refreshTokenExpiresAt ? _self.refreshTokenExpiresAt : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenDto].
extension TokenDtoPatterns on TokenDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenDto value)  $default,){
final _that = this;
switch (_that) {
case _TokenDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenDto value)?  $default,){
final _that = this;
switch (_that) {
case _TokenDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  DateTime accessTokenExpiresAt,  DateTime refreshTokenExpiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.refreshTokenExpiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accessToken,  String refreshToken,  DateTime accessTokenExpiresAt,  DateTime refreshTokenExpiresAt)  $default,) {final _that = this;
switch (_that) {
case _TokenDto():
return $default(_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.refreshTokenExpiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accessToken,  String refreshToken,  DateTime accessTokenExpiresAt,  DateTime refreshTokenExpiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TokenDto() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.accessTokenExpiresAt,_that.refreshTokenExpiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenDto implements TokenDto {
  const _TokenDto({required this.accessToken, required this.refreshToken, required this.accessTokenExpiresAt, required this.refreshTokenExpiresAt});
  factory _TokenDto.fromJson(Map<String, dynamic> json) => _$TokenDtoFromJson(json);

@override final  String accessToken;
@override final  String refreshToken;
@override final  DateTime accessTokenExpiresAt;
@override final  DateTime refreshTokenExpiresAt;

/// Create a copy of TokenDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenDtoCopyWith<_TokenDto> get copyWith => __$TokenDtoCopyWithImpl<_TokenDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenDto&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.accessTokenExpiresAt, accessTokenExpiresAt) || other.accessTokenExpiresAt == accessTokenExpiresAt)&&(identical(other.refreshTokenExpiresAt, refreshTokenExpiresAt) || other.refreshTokenExpiresAt == refreshTokenExpiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,accessTokenExpiresAt,refreshTokenExpiresAt);

@override
String toString() {
  return 'TokenDto(accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt)';
}


}

/// @nodoc
abstract mixin class _$TokenDtoCopyWith<$Res> implements $TokenDtoCopyWith<$Res> {
  factory _$TokenDtoCopyWith(_TokenDto value, $Res Function(_TokenDto) _then) = __$TokenDtoCopyWithImpl;
@override @useResult
$Res call({
 String accessToken, String refreshToken, DateTime accessTokenExpiresAt, DateTime refreshTokenExpiresAt
});




}
/// @nodoc
class __$TokenDtoCopyWithImpl<$Res>
    implements _$TokenDtoCopyWith<$Res> {
  __$TokenDtoCopyWithImpl(this._self, this._then);

  final _TokenDto _self;
  final $Res Function(_TokenDto) _then;

/// Create a copy of TokenDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? accessTokenExpiresAt = null,Object? refreshTokenExpiresAt = null,}) {
  return _then(_TokenDto(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,accessTokenExpiresAt: null == accessTokenExpiresAt ? _self.accessTokenExpiresAt : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,refreshTokenExpiresAt: null == refreshTokenExpiresAt ? _self.refreshTokenExpiresAt : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserDto {

 String get id; String get email; String get displayName; String get timeZone; String get locale; DateTime get createdAt; DateTime get updatedAt; bool get emailVerified;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,timeZone,locale,createdAt,updatedAt,emailVerified);

@override
String toString() {
  return 'UserDto(id: $id, email: $email, displayName: $displayName, timeZone: $timeZone, locale: $locale, createdAt: $createdAt, updatedAt: $updatedAt, emailVerified: $emailVerified)';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 String id, String email, String displayName, String timeZone, String locale, DateTime createdAt, DateTime updatedAt, bool emailVerified
});




}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? timeZone = null,Object? locale = null,Object? createdAt = null,Object? updatedAt = null,Object? emailVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String displayName,  String timeZone,  String locale,  DateTime createdAt,  DateTime updatedAt,  bool emailVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.timeZone,_that.locale,_that.createdAt,_that.updatedAt,_that.emailVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String displayName,  String timeZone,  String locale,  DateTime createdAt,  DateTime updatedAt,  bool emailVerified)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.id,_that.email,_that.displayName,_that.timeZone,_that.locale,_that.createdAt,_that.updatedAt,_that.emailVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String displayName,  String timeZone,  String locale,  DateTime createdAt,  DateTime updatedAt,  bool emailVerified)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.timeZone,_that.locale,_that.createdAt,_that.updatedAt,_that.emailVerified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto implements UserDto {
  const _UserDto({required this.id, required this.email, required this.displayName, required this.timeZone, required this.locale, required this.createdAt, required this.updatedAt, this.emailVerified = false});
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

@override final  String id;
@override final  String email;
@override final  String displayName;
@override final  String timeZone;
@override final  String locale;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool emailVerified;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,timeZone,locale,createdAt,updatedAt,emailVerified);

@override
String toString() {
  return 'UserDto(id: $id, email: $email, displayName: $displayName, timeZone: $timeZone, locale: $locale, createdAt: $createdAt, updatedAt: $updatedAt, emailVerified: $emailVerified)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String displayName, String timeZone, String locale, DateTime createdAt, DateTime updatedAt, bool emailVerified
});




}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = null,Object? timeZone = null,Object? locale = null,Object? createdAt = null,Object? updatedAt = null,Object? emailVerified = null,}) {
  return _then(_UserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AuthResponseDto {

 UserDto get user; TokenDto get tokens;
/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseDtoCopyWith<AuthResponseDto> get copyWith => _$AuthResponseDtoCopyWithImpl<AuthResponseDto>(this as AuthResponseDto, _$identity);

  /// Serializes this AuthResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponseDto&&(identical(other.user, user) || other.user == user)&&(identical(other.tokens, tokens) || other.tokens == tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,tokens);

@override
String toString() {
  return 'AuthResponseDto(user: $user, tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class $AuthResponseDtoCopyWith<$Res>  {
  factory $AuthResponseDtoCopyWith(AuthResponseDto value, $Res Function(AuthResponseDto) _then) = _$AuthResponseDtoCopyWithImpl;
@useResult
$Res call({
 UserDto user, TokenDto tokens
});


$UserDtoCopyWith<$Res> get user;$TokenDtoCopyWith<$Res> get tokens;

}
/// @nodoc
class _$AuthResponseDtoCopyWithImpl<$Res>
    implements $AuthResponseDtoCopyWith<$Res> {
  _$AuthResponseDtoCopyWithImpl(this._self, this._then);

  final AuthResponseDto _self;
  final $Res Function(AuthResponseDto) _then;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? tokens = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as TokenDto,
  ));
}
/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res> get user {
  
  return $UserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenDtoCopyWith<$Res> get tokens {
  
  return $TokenDtoCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResponseDto].
extension AuthResponseDtoPatterns on AuthResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserDto user,  TokenDto tokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that.user,_that.tokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserDto user,  TokenDto tokens)  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDto():
return $default(_that.user,_that.tokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserDto user,  TokenDto tokens)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponseDto() when $default != null:
return $default(_that.user,_that.tokens);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponseDto implements AuthResponseDto {
  const _AuthResponseDto({required this.user, required this.tokens});
  factory _AuthResponseDto.fromJson(Map<String, dynamic> json) => _$AuthResponseDtoFromJson(json);

@override final  UserDto user;
@override final  TokenDto tokens;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseDtoCopyWith<_AuthResponseDto> get copyWith => __$AuthResponseDtoCopyWithImpl<_AuthResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponseDto&&(identical(other.user, user) || other.user == user)&&(identical(other.tokens, tokens) || other.tokens == tokens));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,tokens);

@override
String toString() {
  return 'AuthResponseDto(user: $user, tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseDtoCopyWith<$Res> implements $AuthResponseDtoCopyWith<$Res> {
  factory _$AuthResponseDtoCopyWith(_AuthResponseDto value, $Res Function(_AuthResponseDto) _then) = __$AuthResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 UserDto user, TokenDto tokens
});


@override $UserDtoCopyWith<$Res> get user;@override $TokenDtoCopyWith<$Res> get tokens;

}
/// @nodoc
class __$AuthResponseDtoCopyWithImpl<$Res>
    implements _$AuthResponseDtoCopyWith<$Res> {
  __$AuthResponseDtoCopyWithImpl(this._self, this._then);

  final _AuthResponseDto _self;
  final $Res Function(_AuthResponseDto) _then;

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? tokens = null,}) {
  return _then(_AuthResponseDto(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDto,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as TokenDto,
  ));
}

/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDtoCopyWith<$Res> get user {
  
  return $UserDtoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenDtoCopyWith<$Res> get tokens {
  
  return $TokenDtoCopyWith<$Res>(_self.tokens, (value) {
    return _then(_self.copyWith(tokens: value));
  });
}
}


/// @nodoc
mixin _$RegisterRequestDto {

 String get userId; String get email; String get password; String get displayName; String get timeZone; String get locale;
/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestDtoCopyWith<RegisterRequestDto> get copyWith => _$RegisterRequestDtoCopyWithImpl<RegisterRequestDto>(this as RegisterRequestDto, _$identity);

  /// Serializes this RegisterRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequestDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,password,displayName,timeZone,locale);

@override
String toString() {
  return 'RegisterRequestDto(userId: $userId, email: $email, password: $password, displayName: $displayName, timeZone: $timeZone, locale: $locale)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestDtoCopyWith<$Res>  {
  factory $RegisterRequestDtoCopyWith(RegisterRequestDto value, $Res Function(RegisterRequestDto) _then) = _$RegisterRequestDtoCopyWithImpl;
@useResult
$Res call({
 String userId, String email, String password, String displayName, String timeZone, String locale
});




}
/// @nodoc
class _$RegisterRequestDtoCopyWithImpl<$Res>
    implements $RegisterRequestDtoCopyWith<$Res> {
  _$RegisterRequestDtoCopyWithImpl(this._self, this._then);

  final RegisterRequestDto _self;
  final $Res Function(RegisterRequestDto) _then;

/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? email = null,Object? password = null,Object? displayName = null,Object? timeZone = null,Object? locale = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequestDto].
extension RegisterRequestDtoPatterns on RegisterRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String email,  String password,  String displayName,  String timeZone,  String locale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
return $default(_that.userId,_that.email,_that.password,_that.displayName,_that.timeZone,_that.locale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String email,  String password,  String displayName,  String timeZone,  String locale)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestDto():
return $default(_that.userId,_that.email,_that.password,_that.displayName,_that.timeZone,_that.locale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String email,  String password,  String displayName,  String timeZone,  String locale)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequestDto() when $default != null:
return $default(_that.userId,_that.email,_that.password,_that.displayName,_that.timeZone,_that.locale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterRequestDto implements RegisterRequestDto {
  const _RegisterRequestDto({required this.userId, required this.email, required this.password, required this.displayName, required this.timeZone, required this.locale});
  factory _RegisterRequestDto.fromJson(Map<String, dynamic> json) => _$RegisterRequestDtoFromJson(json);

@override final  String userId;
@override final  String email;
@override final  String password;
@override final  String displayName;
@override final  String timeZone;
@override final  String locale;

/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestDtoCopyWith<_RegisterRequestDto> get copyWith => __$RegisterRequestDtoCopyWithImpl<_RegisterRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequestDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,email,password,displayName,timeZone,locale);

@override
String toString() {
  return 'RegisterRequestDto(userId: $userId, email: $email, password: $password, displayName: $displayName, timeZone: $timeZone, locale: $locale)';
}


}

/// @nodoc
abstract mixin class _$RegisterRequestDtoCopyWith<$Res> implements $RegisterRequestDtoCopyWith<$Res> {
  factory _$RegisterRequestDtoCopyWith(_RegisterRequestDto value, $Res Function(_RegisterRequestDto) _then) = __$RegisterRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, String email, String password, String displayName, String timeZone, String locale
});




}
/// @nodoc
class __$RegisterRequestDtoCopyWithImpl<$Res>
    implements _$RegisterRequestDtoCopyWith<$Res> {
  __$RegisterRequestDtoCopyWithImpl(this._self, this._then);

  final _RegisterRequestDto _self;
  final $Res Function(_RegisterRequestDto) _then;

/// Create a copy of RegisterRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? email = null,Object? password = null,Object? displayName = null,Object? timeZone = null,Object? locale = null,}) {
  return _then(_RegisterRequestDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoginRequestDto {

 String get email; String get password;
/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginRequestDtoCopyWith<LoginRequestDto> get copyWith => _$LoginRequestDtoCopyWithImpl<LoginRequestDto>(this as LoginRequestDto, _$identity);

  /// Serializes this LoginRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginRequestDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginRequestDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class $LoginRequestDtoCopyWith<$Res>  {
  factory $LoginRequestDtoCopyWith(LoginRequestDto value, $Res Function(LoginRequestDto) _then) = _$LoginRequestDtoCopyWithImpl;
@useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class _$LoginRequestDtoCopyWithImpl<$Res>
    implements $LoginRequestDtoCopyWith<$Res> {
  _$LoginRequestDtoCopyWithImpl(this._self, this._then);

  final LoginRequestDto _self;
  final $Res Function(LoginRequestDto) _then;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginRequestDto].
extension LoginRequestDtoPatterns on LoginRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _LoginRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String password)  $default,) {final _that = this;
switch (_that) {
case _LoginRequestDto():
return $default(_that.email,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String password)?  $default,) {final _that = this;
switch (_that) {
case _LoginRequestDto() when $default != null:
return $default(_that.email,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginRequestDto implements LoginRequestDto {
  const _LoginRequestDto({required this.email, required this.password});
  factory _LoginRequestDto.fromJson(Map<String, dynamic> json) => _$LoginRequestDtoFromJson(json);

@override final  String email;
@override final  String password;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginRequestDtoCopyWith<_LoginRequestDto> get copyWith => __$LoginRequestDtoCopyWithImpl<_LoginRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginRequestDto&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,email,password);

@override
String toString() {
  return 'LoginRequestDto(email: $email, password: $password)';
}


}

/// @nodoc
abstract mixin class _$LoginRequestDtoCopyWith<$Res> implements $LoginRequestDtoCopyWith<$Res> {
  factory _$LoginRequestDtoCopyWith(_LoginRequestDto value, $Res Function(_LoginRequestDto) _then) = __$LoginRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String email, String password
});




}
/// @nodoc
class __$LoginRequestDtoCopyWithImpl<$Res>
    implements _$LoginRequestDtoCopyWith<$Res> {
  __$LoginRequestDtoCopyWithImpl(this._self, this._then);

  final _LoginRequestDto _self;
  final $Res Function(_LoginRequestDto) _then;

/// Create a copy of LoginRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,}) {
  return _then(_LoginRequestDto(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OAuthRequestDto {

 String get provider; String get idToken; String get userId; String get timeZone; String get locale; String? get displayName;
/// Create a copy of OAuthRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OAuthRequestDtoCopyWith<OAuthRequestDto> get copyWith => _$OAuthRequestDtoCopyWithImpl<OAuthRequestDto>(this as OAuthRequestDto, _$identity);

  /// Serializes this OAuthRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OAuthRequestDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,idToken,userId,timeZone,locale,displayName);

@override
String toString() {
  return 'OAuthRequestDto(provider: $provider, idToken: $idToken, userId: $userId, timeZone: $timeZone, locale: $locale, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $OAuthRequestDtoCopyWith<$Res>  {
  factory $OAuthRequestDtoCopyWith(OAuthRequestDto value, $Res Function(OAuthRequestDto) _then) = _$OAuthRequestDtoCopyWithImpl;
@useResult
$Res call({
 String provider, String idToken, String userId, String timeZone, String locale, String? displayName
});




}
/// @nodoc
class _$OAuthRequestDtoCopyWithImpl<$Res>
    implements $OAuthRequestDtoCopyWith<$Res> {
  _$OAuthRequestDtoCopyWithImpl(this._self, this._then);

  final OAuthRequestDto _self;
  final $Res Function(OAuthRequestDto) _then;

/// Create a copy of OAuthRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? idToken = null,Object? userId = null,Object? timeZone = null,Object? locale = null,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OAuthRequestDto].
extension OAuthRequestDtoPatterns on OAuthRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OAuthRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OAuthRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OAuthRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _OAuthRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OAuthRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _OAuthRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String idToken,  String userId,  String timeZone,  String locale,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OAuthRequestDto() when $default != null:
return $default(_that.provider,_that.idToken,_that.userId,_that.timeZone,_that.locale,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String idToken,  String userId,  String timeZone,  String locale,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _OAuthRequestDto():
return $default(_that.provider,_that.idToken,_that.userId,_that.timeZone,_that.locale,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String idToken,  String userId,  String timeZone,  String locale,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _OAuthRequestDto() when $default != null:
return $default(_that.provider,_that.idToken,_that.userId,_that.timeZone,_that.locale,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OAuthRequestDto implements OAuthRequestDto {
  const _OAuthRequestDto({required this.provider, required this.idToken, required this.userId, required this.timeZone, required this.locale, this.displayName});
  factory _OAuthRequestDto.fromJson(Map<String, dynamic> json) => _$OAuthRequestDtoFromJson(json);

@override final  String provider;
@override final  String idToken;
@override final  String userId;
@override final  String timeZone;
@override final  String locale;
@override final  String? displayName;

/// Create a copy of OAuthRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OAuthRequestDtoCopyWith<_OAuthRequestDto> get copyWith => __$OAuthRequestDtoCopyWithImpl<_OAuthRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OAuthRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OAuthRequestDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,idToken,userId,timeZone,locale,displayName);

@override
String toString() {
  return 'OAuthRequestDto(provider: $provider, idToken: $idToken, userId: $userId, timeZone: $timeZone, locale: $locale, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$OAuthRequestDtoCopyWith<$Res> implements $OAuthRequestDtoCopyWith<$Res> {
  factory _$OAuthRequestDtoCopyWith(_OAuthRequestDto value, $Res Function(_OAuthRequestDto) _then) = __$OAuthRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider, String idToken, String userId, String timeZone, String locale, String? displayName
});




}
/// @nodoc
class __$OAuthRequestDtoCopyWithImpl<$Res>
    implements _$OAuthRequestDtoCopyWith<$Res> {
  __$OAuthRequestDtoCopyWithImpl(this._self, this._then);

  final _OAuthRequestDto _self;
  final $Res Function(_OAuthRequestDto) _then;

/// Create a copy of OAuthRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? idToken = null,Object? userId = null,Object? timeZone = null,Object? locale = null,Object? displayName = freezed,}) {
  return _then(_OAuthRequestDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RefreshRequestDto {

 String get refreshToken;
/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshRequestDtoCopyWith<RefreshRequestDto> get copyWith => _$RefreshRequestDtoCopyWithImpl<RefreshRequestDto>(this as RefreshRequestDto, _$identity);

  /// Serializes this RefreshRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class $RefreshRequestDtoCopyWith<$Res>  {
  factory $RefreshRequestDtoCopyWith(RefreshRequestDto value, $Res Function(RefreshRequestDto) _then) = _$RefreshRequestDtoCopyWithImpl;
@useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class _$RefreshRequestDtoCopyWithImpl<$Res>
    implements $RefreshRequestDtoCopyWith<$Res> {
  _$RefreshRequestDtoCopyWithImpl(this._self, this._then);

  final RefreshRequestDto _self;
  final $Res Function(RefreshRequestDto) _then;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? refreshToken = null,}) {
  return _then(_self.copyWith(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RefreshRequestDto].
extension RefreshRequestDtoPatterns on RefreshRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RefreshRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RefreshRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RefreshRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String refreshToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String refreshToken)  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestDto():
return $default(_that.refreshToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String refreshToken)?  $default,) {final _that = this;
switch (_that) {
case _RefreshRequestDto() when $default != null:
return $default(_that.refreshToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RefreshRequestDto implements RefreshRequestDto {
  const _RefreshRequestDto({required this.refreshToken});
  factory _RefreshRequestDto.fromJson(Map<String, dynamic> json) => _$RefreshRequestDtoFromJson(json);

@override final  String refreshToken;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshRequestDtoCopyWith<_RefreshRequestDto> get copyWith => __$RefreshRequestDtoCopyWithImpl<_RefreshRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RefreshRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshRequestDto&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,refreshToken);

@override
String toString() {
  return 'RefreshRequestDto(refreshToken: $refreshToken)';
}


}

/// @nodoc
abstract mixin class _$RefreshRequestDtoCopyWith<$Res> implements $RefreshRequestDtoCopyWith<$Res> {
  factory _$RefreshRequestDtoCopyWith(_RefreshRequestDto value, $Res Function(_RefreshRequestDto) _then) = __$RefreshRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 String refreshToken
});




}
/// @nodoc
class __$RefreshRequestDtoCopyWithImpl<$Res>
    implements _$RefreshRequestDtoCopyWith<$Res> {
  __$RefreshRequestDtoCopyWithImpl(this._self, this._then);

  final _RefreshRequestDto _self;
  final $Res Function(_RefreshRequestDto) _then;

/// Create a copy of RefreshRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? refreshToken = null,}) {
  return _then(_RefreshRequestDto(
refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PasswordChangeDto {

 String get currentPassword; String get newPassword;
/// Create a copy of PasswordChangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordChangeDtoCopyWith<PasswordChangeDto> get copyWith => _$PasswordChangeDtoCopyWithImpl<PasswordChangeDto>(this as PasswordChangeDto, _$identity);

  /// Serializes this PasswordChangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordChangeDto&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword);

@override
String toString() {
  return 'PasswordChangeDto(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class $PasswordChangeDtoCopyWith<$Res>  {
  factory $PasswordChangeDtoCopyWith(PasswordChangeDto value, $Res Function(PasswordChangeDto) _then) = _$PasswordChangeDtoCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class _$PasswordChangeDtoCopyWithImpl<$Res>
    implements $PasswordChangeDtoCopyWith<$Res> {
  _$PasswordChangeDtoCopyWithImpl(this._self, this._then);

  final PasswordChangeDto _self;
  final $Res Function(PasswordChangeDto) _then;

/// Create a copy of PasswordChangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(_self.copyWith(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordChangeDto].
extension PasswordChangeDtoPatterns on PasswordChangeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordChangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordChangeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordChangeDto value)  $default,){
final _that = this;
switch (_that) {
case _PasswordChangeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordChangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordChangeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordChangeDto() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword)  $default,) {final _that = this;
switch (_that) {
case _PasswordChangeDto():
return $default(_that.currentPassword,_that.newPassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPassword,  String newPassword)?  $default,) {final _that = this;
switch (_that) {
case _PasswordChangeDto() when $default != null:
return $default(_that.currentPassword,_that.newPassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordChangeDto implements PasswordChangeDto {
  const _PasswordChangeDto({required this.currentPassword, required this.newPassword});
  factory _PasswordChangeDto.fromJson(Map<String, dynamic> json) => _$PasswordChangeDtoFromJson(json);

@override final  String currentPassword;
@override final  String newPassword;

/// Create a copy of PasswordChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordChangeDtoCopyWith<_PasswordChangeDto> get copyWith => __$PasswordChangeDtoCopyWithImpl<_PasswordChangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordChangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordChangeDto&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword);

@override
String toString() {
  return 'PasswordChangeDto(currentPassword: $currentPassword, newPassword: $newPassword)';
}


}

/// @nodoc
abstract mixin class _$PasswordChangeDtoCopyWith<$Res> implements $PasswordChangeDtoCopyWith<$Res> {
  factory _$PasswordChangeDtoCopyWith(_PasswordChangeDto value, $Res Function(_PasswordChangeDto) _then) = __$PasswordChangeDtoCopyWithImpl;
@override @useResult
$Res call({
 String currentPassword, String newPassword
});




}
/// @nodoc
class __$PasswordChangeDtoCopyWithImpl<$Res>
    implements _$PasswordChangeDtoCopyWith<$Res> {
  __$PasswordChangeDtoCopyWithImpl(this._self, this._then);

  final _PasswordChangeDto _self;
  final $Res Function(_PasswordChangeDto) _then;

/// Create a copy of PasswordChangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,}) {
  return _then(_PasswordChangeDto(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
