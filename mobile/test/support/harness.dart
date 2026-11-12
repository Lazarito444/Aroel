import 'dart:convert';
import 'dart:typed_data';

import 'package:aroel/app/providers.dart';
import 'package:aroel/core/account.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:aroel/data/repositories/account_repository.dart';
import 'package:aroel/data/services/secure_storage.dart';
import 'package:aroel/data/services/session_store.dart';
import 'package:aroel/features/settings/theme_controller.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/misc.dart' show Override;

/// A server that answers with what the test tells it to.
class FakeServer {
  FakeServer(this.handler);

  /// What the server answers, given the request it was sent.
  final Object? Function(RequestOptions options) handler;

  /// Every request the server was sent, in order.
  final List<RequestOptions> requests = <RequestOptions>[];

  /// The requests for a path, with the `/v1` prefix the server is reached under.
  List<RequestOptions> requestsFor(String path) => requests.where((RequestOptions options) => options.uri.path == path).toList();

  /// A dio that talks to this server.
  Dio get dio {
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://aroel.test/v1'));
    dio.httpClientAdapter = _FakeAdapter(this);
    return dio;
  }
}

/// An answer the server gives with a status code of its own.
class FakeFailure {
  const FakeFailure(this.statusCode, [this.body = const <String, Object?>{}]);

  /// The status code of the answer.
  final int statusCode;

  /// The body of the answer.
  final Map<String, Object?> body;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.server);

  final FakeServer server;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    server.requests.add(options);
    final Object? answer = server.handler(options);

    if (answer is FakeFailure) {
      return ResponseBody.fromString(
        jsonEncode(answer.body),
        answer.statusCode,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode(answer ?? <String, Object?>{}),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// The account of a device, wired the way the app wires it.
class AccountHarness {
  AccountHarness({required this.server}) {
    database = AppDatabase(NativeDatabase.memory());
    storage = InMemorySecureStorage();
    sessionStore = SessionStore(storage);
    clock = FixedClock(DateTime.utc(2026, 11, 12, 9));

    final SessionHolder sessionHolder = SessionHolder();
    holder = sessionHolder;
    api = AuthApi(server.dio, session: sessionHolder);
    repository = AccountRepository(
      api: api,
      database: database,
      sessionStore: sessionStore,
      clock: clock,
      newId: nextId,
      deviceTimeZone: 'Europe/Madrid',
      deviceLocale: 'en-GB',
    );
    holder.refresh = repository.refreshSession;
  }

  /// The server the account talks to.
  final FakeServer server;

  /// The device's own store.
  late final AppDatabase database;

  /// The keychain.
  late final InMemorySecureStorage storage;

  /// The session in the keychain.
  late final SessionStore sessionStore;

  /// The moment the account believes it is.
  late final FixedClock clock;

  /// The session the transport presents.
  late final SessionHolder holder;

  /// The account half of the API.
  late final AuthApi api;

  /// The account of the device.
  late final AccountRepository repository;

  int _counter = 0;

  /// The next identifier the device makes, in the shape of a `uuid7`.
  String nextId() {
    _counter++;
    final String tail = _counter.toRadixString(16).padLeft(12, '0');
    return '0192f3a4-5b6c-7d8e-9f0a-$tail';
  }

  /// The overrides a widget test needs to run the app on this device.
  List<Override> overrides({
    AccountSnapshot? account,
    OnboardingState? onboarding,
  }) => <Override>[
    databaseProvider.overrideWithValue(database),
    sessionStoreProvider.overrideWithValue(sessionStore),
    sessionHolderProvider.overrideWithValue(holder),
    authApiProvider.overrideWithValue(api),
    accountRepositoryProvider.overrideWithValue(repository),
    accountServiceProvider.overrideWithValue(repository),
    preferencesStoreProvider.overrideWithValue(database),
    initialAccountProvider.overrideWithValue(
      account ??
          const AccountSnapshot(
            status: AccountStatus.localOnly,
            localUserId: '0192f3a4-5b6c-7d8e-9f0a-000000000001',
          ),
    ),
    initialOnboardingProvider.overrideWithValue(
      onboarding ?? const OnboardingState(),
    ),
    initialThemeModeProvider.overrideWithValue(ThemeMode.light),
  ];

  /// Closes what the harness opened.
  Future<void> close() => database.close();
}

/// The body the server answers an account request with.
Map<String, Object?> authResponse({
  required String userId,
  String email = 'ada@example.com',
  bool emailVerified = false,
  String accessToken = 'access-1',
  String refreshToken = 'refresh-1',
  DateTime? accessExpiresAt,
  DateTime? refreshExpiresAt,
}) => <String, Object?>{
  'user': <String, Object?>{
    'id': userId,
    'email': email,
    'displayName': 'ada',
    'timeZone': 'Europe/Madrid',
    'locale': 'en-GB',
    'emailVerified': emailVerified,
    'createdAt': '2026-11-12T09:00:00Z',
    'updatedAt': '2026-11-12T09:00:00Z',
  },
  'tokens': <String, Object?>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': (accessExpiresAt ?? DateTime.utc(2026, 11, 12, 9, 15)).toIso8601String(),
    'refreshTokenExpiresAt': (refreshExpiresAt ?? DateTime.utc(2026, 12, 11, 9)).toIso8601String(),
  },
};

/// The body the server answers a token exchange with.
Map<String, Object?> tokenResponse({
  String accessToken = 'access-2',
  String refreshToken = 'refresh-2',
}) => <String, Object?>{
  'accessToken': accessToken,
  'refreshToken': refreshToken,
  'accessTokenExpiresAt': DateTime.utc(2026, 11, 12, 9, 15).toIso8601String(),
  'refreshTokenExpiresAt': DateTime.utc(2026, 12, 11, 9).toIso8601String(),
};
