// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenDto _$TokenDtoFromJson(Map<String, dynamic> json) => _TokenDto(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt'] as String),
  refreshTokenExpiresAt: DateTime.parse(
    json['refreshTokenExpiresAt'] as String,
  ),
);

Map<String, dynamic> _$TokenDtoToJson(_TokenDto instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'accessTokenExpiresAt': instance.accessTokenExpiresAt.toIso8601String(),
  'refreshTokenExpiresAt': instance.refreshTokenExpiresAt.toIso8601String(),
};

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  timeZone: json['timeZone'] as String,
  locale: json['locale'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  emailVerified: json['emailVerified'] as bool? ?? false,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'timeZone': instance.timeZone,
  'locale': instance.locale,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'emailVerified': instance.emailVerified,
};

_AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) => _AuthResponseDto(
  user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
  tokens: TokenDto.fromJson(json['tokens'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseDtoToJson(_AuthResponseDto instance) => <String, dynamic>{'user': instance.user, 'tokens': instance.tokens};

_RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) => _RegisterRequestDto(
  userId: json['userId'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  displayName: json['displayName'] as String,
  timeZone: json['timeZone'] as String,
  locale: json['locale'] as String,
);

Map<String, dynamic> _$RegisterRequestDtoToJson(_RegisterRequestDto instance) => <String, dynamic>{
  'userId': instance.userId,
  'email': instance.email,
  'password': instance.password,
  'displayName': instance.displayName,
  'timeZone': instance.timeZone,
  'locale': instance.locale,
};

_LoginRequestDto _$LoginRequestDtoFromJson(Map<String, dynamic> json) => _LoginRequestDto(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestDtoToJson(_LoginRequestDto instance) => <String, dynamic>{'email': instance.email, 'password': instance.password};

_OAuthRequestDto _$OAuthRequestDtoFromJson(Map<String, dynamic> json) => _OAuthRequestDto(
  provider: json['provider'] as String,
  idToken: json['idToken'] as String,
  userId: json['userId'] as String,
  timeZone: json['timeZone'] as String,
  locale: json['locale'] as String,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$OAuthRequestDtoToJson(_OAuthRequestDto instance) => <String, dynamic>{
  'provider': instance.provider,
  'idToken': instance.idToken,
  'userId': instance.userId,
  'timeZone': instance.timeZone,
  'locale': instance.locale,
  'displayName': instance.displayName,
};

_RefreshRequestDto _$RefreshRequestDtoFromJson(Map<String, dynamic> json) => _RefreshRequestDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshRequestDtoToJson(_RefreshRequestDto instance) => <String, dynamic>{'refreshToken': instance.refreshToken};

_PasswordChangeDto _$PasswordChangeDtoFromJson(Map<String, dynamic> json) => _PasswordChangeDto(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordChangeDtoToJson(_PasswordChangeDto instance) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
