import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/remote/auth_dto.dart';
import 'package:dio/dio.dart';

/// The session the client is currently holding.
///
/// The API reads the bearer token from here, and the repository writes to it. It is a
/// small seam rather than a circular dependency: the repository owns the session, the
/// transport borrows it.
class SessionHolder {
  /// The access token to present, when there is one.
  String? accessToken;

  /// Exchanges the refresh token for a new pair, when the session can be renewed.
  Future<Result<AuthSession>> Function()? refresh;

  /// Whether the client should try to renew the session.
  bool get canRefresh => refresh != null;
}

/// The live session of a signed-in reader.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.emailVerified,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  /// The account the session belongs to.
  final String userId;

  /// The address of the account.
  final String email;

  /// Whether the address has been confirmed. Sync waits for it; writing does not.
  final bool emailVerified;

  /// The bearer token.
  final String accessToken;

  /// The token that buys a new bearer token, replaced on every use.
  final String refreshToken;

  /// When the bearer token stops being accepted.
  final DateTime accessTokenExpiresAt;

  /// When the refresh token stops being accepted.
  final DateTime refreshTokenExpiresAt;

  /// The session as the tokens of the API.
  TokenDto toDto() => TokenDto(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
    refreshTokenExpiresAt: refreshTokenExpiresAt,
  );
}

/// The account half of the API (§7.2).
///
/// Every method answers with a [Result]: a failure is a value the screen can show, never
/// an exception it has to remember to catch.
class AuthApi {
  AuthApi(this._dio, {SessionHolder? session})
    : _session = session ?? SessionHolder();

  final Dio _dio;
  final SessionHolder _session;

  /// The holder the transport reads the bearer token from.
  SessionHolder get session => _session;

  /// Registers an account under the identifier the device already uses (§4.2).
  Future<Result<AuthResponseDto>> register(RegisterRequestDto request) =>
      _guard(() async {
        final Response<dynamic> response = await _dio.post<dynamic>(
          '/auth/register',
          data: request.toJson(),
        );
        return AuthResponseDto.fromJson(_asMap(response.data));
      });

  /// Signs in with an address and a password.
  Future<Result<AuthResponseDto>> login(LoginRequestDto request) =>
      _guard(() async {
        final Response<dynamic> response = await _dio.post<dynamic>(
          '/auth/login',
          data: request.toJson(),
        );
        return AuthResponseDto.fromJson(_asMap(response.data));
      });

  /// Signs in with a provider token, which the server validates (§5.1).
  Future<Result<AuthResponseDto>> oauth(OAuthRequestDto request) =>
      _guard(() async {
        final Response<dynamic> response = await _dio.post<dynamic>(
          '/auth/oauth',
          data: request.toJson(),
        );
        return AuthResponseDto.fromJson(_asMap(response.data));
      });

  /// Exchanges a refresh token for a new pair, rotating the refresh token.
  Future<Result<TokenDto>> refresh(RefreshRequestDto request) =>
      _guard(() async {
        final Response<dynamic> response = await _dio.post<dynamic>(
          '/auth/refresh',
          data: request.toJson(),
        );
        return TokenDto.fromJson(_asMap(response.data));
      });

  /// Ends the session on the server.
  Future<Result<void>> logout() => _guardVoid(() async {
    await _dio.post<dynamic>('/auth/logout');
  });

  /// Changes the password of the signed-in account.
  Future<Result<void>> changePassword(PasswordChangeDto request) =>
      _guardVoid(() async {
        await _dio.post<dynamic>('/auth/password', data: request.toJson());
      });

  /// Asks the server to send the verification email again.
  Future<Result<void>> sendVerificationEmail() => _guardVoid(() async {
    await _dio.post<dynamic>('/auth/email-verification');
  });

  /// Reads the profile of the signed-in account.
  Future<Result<UserDto>> me() => _guard(() async {
    final Response<dynamic> response = await _dio.get<dynamic>('/me');
    return UserDto.fromJson(_asMap(response.data));
  });

  /// Changes the display name or the timezone of the signed-in account.
  Future<Result<UserDto>> updateMe({String? displayName, String? timeZone}) =>
      _guard(() async {
        final Response<dynamic> response = await _dio.patch<dynamic>(
          '/me',
          data: <String, dynamic>{
            'displayName': ?displayName,
            'timeZone': ?timeZone,
          },
        );
        return UserDto.fromJson(_asMap(response.data));
      });

  /// Deletes the account and everything the server holds for it.
  Future<Result<void>> deleteMe() => _guardVoid(() async {
    await _dio.delete<dynamic>('/me');
  });

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result<T>.success(await call());
    } on DioException catch (error) {
      return Result<T>.failure(_mapError(error));
    } catch (_) {
      return Result<T>.failure(
        const AppError.client(ClientErrorCodes.unexpected),
      );
    }
  }

  Future<Result<void>> _guardVoid(Future<void> Function() call) async {
    try {
      await call();
      return Result<void>.success(null);
    } on DioException catch (error) {
      return Result<void>.failure(_mapError(error));
    } catch (_) {
      return Result<void>.failure(
        const AppError.client(ClientErrorCodes.unexpected),
      );
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) =>
      data is Map<String, dynamic> ? data : <String, dynamic>{};

  /// Turns a transport failure into a code the screen can explain.
  static AppError _mapError(DioException error) {
    final int? status = error.response?.statusCode;
    final String? code = _codeOf(error.response?.data);

    if (status == null) {
      return const AppError.client(ClientErrorCodes.networkUnavailable);
    }

    if (code != null && code.isNotEmpty) {
      return AppError.server(code);
    }

    return switch (status) {
      401 => const AppError.server(AuthErrorCodes.invalidCredentials),
      403 => const AppError.server(AuthErrorCodes.emailNotVerified),
      409 => const AppError.server(AuthErrorCodes.emailTaken),
      429 => const AppError.server(AuthErrorCodes.rateLimited),
      >= 500 => const AppError.client(ClientErrorCodes.serverUnavailable),
      _ => const AppError.client(ClientErrorCodes.unexpected),
    };
  }

  static String? _codeOf(dynamic data) {
    if (data is Map && data['code'] is String) {
      return data['code'] as String;
    }
    return null;
  }
}
