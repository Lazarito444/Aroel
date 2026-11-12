import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dto.freezed.dart';
part 'auth_dto.g.dart';

/// The tokens of a session, as the server sends them (§7.2).
///
/// The access token lives fifteen minutes; the refresh token lives sixty days and is
/// replaced every time it is used.
@freezed
abstract class TokenDto with _$TokenDto {
  const factory TokenDto({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
  }) = _TokenDto;

  factory TokenDto.fromJson(Map<String, dynamic> json) =>
      _$TokenDtoFromJson(json);
}

/// The journal profile of an account, as the server sends it (§4.2).
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String displayName,
    required String timeZone,
    required String locale,
    @Default(false) bool emailVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

/// What registration, sign-in and provider sign-in answer with.
@freezed
abstract class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required UserDto user,
    required TokenDto tokens,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}

/// What registration asks for.
@freezed
abstract class RegisterRequestDto with _$RegisterRequestDto {
  const factory RegisterRequestDto({
    required String userId,
    required String email,
    required String password,
    required String displayName,
    required String timeZone,
    required String locale,
  }) = _RegisterRequestDto;

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestDtoFromJson(json);
}

/// What sign-in asks for.
@freezed
abstract class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

/// What a provider sign-in asks for.
///
/// The token is validated on the server; the device never decides who the reader is.
@freezed
abstract class OAuthRequestDto with _$OAuthRequestDto {
  const factory OAuthRequestDto({
    required String provider,
    required String idToken,
    required String userId,
    required String timeZone,
    required String locale,
    String? displayName,
  }) = _OAuthRequestDto;

  factory OAuthRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthRequestDtoFromJson(json);
}

/// What the token exchange asks for.
@freezed
abstract class RefreshRequestDto with _$RefreshRequestDto {
  const factory RefreshRequestDto({required String refreshToken}) =
      _RefreshRequestDto;

  factory RefreshRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestDtoFromJson(json);
}

/// What a password change asks for.
@freezed
abstract class PasswordChangeDto with _$PasswordChangeDto {
  const factory PasswordChangeDto({
    required String currentPassword,
    required String newPassword,
  }) = _PasswordChangeDto;

  factory PasswordChangeDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeDtoFromJson(json);
}
