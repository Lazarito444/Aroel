import 'package:aroel/core/clock.dart';
import 'package:aroel/core/config.dart';
import 'package:aroel/core/ids.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:aroel/data/remote/session_interceptor.dart';
import 'package:aroel/data/repositories/account_repository.dart';
import 'package:aroel/data/services/secure_storage.dart';
import 'package:aroel/data/services/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the client finds the server.
final Provider<AroelConfig> configProvider = Provider<AroelConfig>(
  (Ref ref) => AroelConfig.fromEnvironment(),
);

/// The source of the current moment.
final Provider<Clock> clockProvider = Provider<Clock>(
  (Ref ref) => const SystemClock(),
);

/// The store the app reads from and writes to.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((Ref ref) {
  final AppDatabase database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});

/// The keychain the session lives in.
final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (Ref ref) => SessionStore(const PlatformSecureStorage()),
);

/// The session the transport presents.
final Provider<SessionHolder> sessionHolderProvider = Provider<SessionHolder>(
  (Ref ref) => SessionHolder(),
);

/// The timezone the days of this device are counted in.
final Provider<String> deviceTimeZoneProvider = Provider<String>(
  (Ref ref) => 'UTC',
);

/// The culture the interface of this device is rendered in.
final Provider<String> deviceLocaleProvider = Provider<String>(
  (Ref ref) => 'en',
);

/// The transport.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final AroelConfig config = ref.watch(configProvider);
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.requestTimeout,
      receiveTimeout: config.requestTimeout,
      sendTimeout: config.requestTimeout,
      headers: <String, Object>{'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    SessionInterceptor(dio, ref.watch(sessionHolderProvider)),
  );
  return dio;
});

/// The account half of the API.
final Provider<AuthApi> authApiProvider = Provider<AuthApi>(
  (Ref ref) => AuthApi(
    ref.watch(dioProvider),
    session: ref.watch(sessionHolderProvider),
  ),
);

/// The account of this device.
///
/// The service the client talks to. The rules of the account live in `core`; this is
/// the adapter that reaches the server.
final Provider<AccountRepository> accountRepositoryProvider = Provider<AccountRepository>((Ref ref) {
  final AccountRepository repository = AccountRepository(
    api: ref.watch(authApiProvider),
    database: ref.watch(databaseProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    clock: ref.watch(clockProvider),
    newId: Ids.uuid7,
    deviceTimeZone: ref.watch(deviceTimeZoneProvider),
    deviceLocale: ref.watch(deviceLocaleProvider),
  );
  ref.read(sessionHolderProvider).refresh = repository.refreshSession;
  return repository;
});
