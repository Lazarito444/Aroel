// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_sign_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderCredential {

/// The provider that was asked.
 AuthProvider get provider;/// The token the server validates.
 String get idToken;/// The address the provider knows, when it tells us.
 String? get email;/// The name the provider knows, when it tells us.
 String? get displayName;
/// Create a copy of ProviderCredential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderCredentialCopyWith<ProviderCredential> get copyWith => _$ProviderCredentialCopyWithImpl<ProviderCredential>(this as ProviderCredential, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderCredential&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,provider,idToken,email,displayName);

@override
String toString() {
  return 'ProviderCredential(provider: $provider, idToken: $idToken, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $ProviderCredentialCopyWith<$Res>  {
  factory $ProviderCredentialCopyWith(ProviderCredential value, $Res Function(ProviderCredential) _then) = _$ProviderCredentialCopyWithImpl;
@useResult
$Res call({
 AuthProvider provider, String idToken, String? email, String? displayName
});




}
/// @nodoc
class _$ProviderCredentialCopyWithImpl<$Res>
    implements $ProviderCredentialCopyWith<$Res> {
  _$ProviderCredentialCopyWithImpl(this._self, this._then);

  final ProviderCredential _self;
  final $Res Function(ProviderCredential) _then;

/// Create a copy of ProviderCredential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? idToken = null,Object? email = freezed,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AuthProvider,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderCredential].
extension ProviderCredentialPatterns on ProviderCredential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderCredential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderCredential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderCredential value)  $default,){
final _that = this;
switch (_that) {
case _ProviderCredential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderCredential value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderCredential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthProvider provider,  String idToken,  String? email,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderCredential() when $default != null:
return $default(_that.provider,_that.idToken,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthProvider provider,  String idToken,  String? email,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _ProviderCredential():
return $default(_that.provider,_that.idToken,_that.email,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthProvider provider,  String idToken,  String? email,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _ProviderCredential() when $default != null:
return $default(_that.provider,_that.idToken,_that.email,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderCredential implements ProviderCredential {
  const _ProviderCredential({required this.provider, required this.idToken, this.email, this.displayName});
  

/// The provider that was asked.
@override final  AuthProvider provider;
/// The token the server validates.
@override final  String idToken;
/// The address the provider knows, when it tells us.
@override final  String? email;
/// The name the provider knows, when it tells us.
@override final  String? displayName;

/// Create a copy of ProviderCredential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderCredentialCopyWith<_ProviderCredential> get copyWith => __$ProviderCredentialCopyWithImpl<_ProviderCredential>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderCredential&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.idToken, idToken) || other.idToken == idToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,provider,idToken,email,displayName);

@override
String toString() {
  return 'ProviderCredential(provider: $provider, idToken: $idToken, email: $email, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$ProviderCredentialCopyWith<$Res> implements $ProviderCredentialCopyWith<$Res> {
  factory _$ProviderCredentialCopyWith(_ProviderCredential value, $Res Function(_ProviderCredential) _then) = __$ProviderCredentialCopyWithImpl;
@override @useResult
$Res call({
 AuthProvider provider, String idToken, String? email, String? displayName
});




}
/// @nodoc
class __$ProviderCredentialCopyWithImpl<$Res>
    implements _$ProviderCredentialCopyWith<$Res> {
  __$ProviderCredentialCopyWithImpl(this._self, this._then);

  final _ProviderCredential _self;
  final $Res Function(_ProviderCredential) _then;

/// Create a copy of ProviderCredential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? idToken = null,Object? email = freezed,Object? displayName = freezed,}) {
  return _then(_ProviderCredential(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as AuthProvider,idToken: null == idToken ? _self.idToken : idToken // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
