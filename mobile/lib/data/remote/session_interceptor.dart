import 'package:aroel/core/result.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:dio/dio.dart';

/// Presents the bearer token, and renews the session when the server says it is stale.
///
/// The access token lives fifteen minutes; when it runs out the server answers 401, this
/// interceptor exchanges the refresh token for a new pair, and the request is sent again
/// once (§7.2).
class SessionInterceptor extends Interceptor {
  SessionInterceptor(this._dio, this._session);

  final Dio _dio;
  final SessionHolder _session;

  static const String _retriedKey = 'aroel.session_retried';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _session.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final bool renewable =
        err.response?.statusCode == 401 &&
        _session.canRefresh &&
        err.requestOptions.extra[_retriedKey] != true;

    if (!renewable) {
      handler.next(err);
      return;
    }

    _session.refresh!().then((Result<AuthSession> result) {
      if (result.isFailure) {
        handler.next(err);
        return;
      }

      final RequestOptions options = err.requestOptions;
      options.extra[_retriedKey] = true;
      options.headers['Authorization'] =
          'Bearer ${result.valueOrNull!.accessToken}';

      _dio
          .fetch<dynamic>(options)
          .then(
            (Response<dynamic> response) => handler.resolve(response),
            onError: (Object failure) =>
                handler.next(failure is DioException ? failure : err),
          );
    }, onError: (Object _) => handler.next(err));
  }
}
