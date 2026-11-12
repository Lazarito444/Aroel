import 'package:aroel/core/account.dart';
import 'package:aroel/core/app_error.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('creating an account', () {
    test(
      'adopts the identifier the device already writes its rows under',
      () async {
        String requestedId = '';
        final FakeServer server = FakeServer((RequestOptions options) {
          requestedId =
              (options.data as Map<String, dynamic>)['userId'] as String;
          return authResponse(userId: requestedId);
        });
        final AccountHarness harness = AccountHarness(server: server);
        addTearDown(harness.close);

        final result = await harness.repository.register(
          email: 'ada@example.com',
          password: '12345678',
        );

        expect(result.isSuccess, isTrue);

        final LocalUser? profile = await harness.database.findProfile();
        expect(profile, isNotNull);
        expect(profile!.id, requestedId);
        expect(profile.accountUserId, requestedId);

        final AccountSnapshot snapshot = result.valueOrNull!;
        expect(snapshot.localUserId, requestedId);
        expect(snapshot.accountUserId, requestedId);
        expect(snapshot.localJournalIsSeparate, isFalse);
      },
    );

    test('never sends a password that is too short', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) => authResponse(userId: 'x'),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      final result = await harness.repository.register(
        email: 'ada@example.com',
        password: 'short',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, ClientErrorCodes.passwordTooShort);
      expect(server.requests, isEmpty);
    });

    test('never sends an address that is not an address', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) => authResponse(userId: 'x'),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      final result = await harness.repository.register(
        email: 'ada@example',
        password: '12345678',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, ClientErrorCodes.emailInvalid);
      expect(server.requests, isEmpty);
    });

    test('says so when the address already has an account', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) => const FakeFailure(409, <String, Object?>{
          'code': 'auth.email_taken',
        }),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      final result = await harness.repository.register(
        email: 'ada@example.com',
        password: '12345678',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, AuthErrorCodes.emailTaken);
    });

    test('says so when the account is paused', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) => const FakeFailure(429, <String, Object?>{
          'code': 'auth.rate_limited',
        }),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      final result = await harness.repository.register(
        email: 'ada@example.com',
        password: '12345678',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, AuthErrorCodes.rateLimited);
    });

    test(
      'leaves the journal alone when the server cannot be reached',
      () async {
        final FakeServer server = FakeServer((RequestOptions options) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        });
        final AccountHarness harness = AccountHarness(server: server);
        addTearDown(harness.close);

        final result = await harness.repository.register(
          email: 'ada@example.com',
          password: '12345678',
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull!.code, ClientErrorCodes.networkUnavailable);
        expect(await harness.database.findProfile(), isNotNull);
      },
    );
  });

  group('signing in', () {
    test(
      'adopts the identifier of the account on a device with no journal',
      () async {
        final FakeServer server = FakeServer(
          (RequestOptions options) =>
              authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000aa'),
        );
        final AccountHarness harness = AccountHarness(server: server);
        addTearDown(harness.close);

        final result = await harness.repository.login(
          email: 'ada@example.com',
          password: '12345678',
        );

        expect(result.isSuccess, isTrue);

        final AccountSnapshot snapshot = result.valueOrNull!;
        expect(snapshot.localUserId, snapshot.accountUserId);
        expect(snapshot.localJournalIsSeparate, isFalse);

        final LocalUser? profile = await harness.database.findProfile();
        expect(profile!.id, snapshot.accountUserId);
      },
    );

    test('never re-keys a row on a device that has a journal', () async {
      const String accountId = '0192f3a4-5b6c-7d8e-9f0a-0000000000bb';
      final FakeServer server = FakeServer(
        (RequestOptions options) => authResponse(userId: accountId),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.database.ensureLocalProfile(
        id: harness.nextId(),
        timeZone: 'Europe/Madrid',
        locale: 'en-GB',
        now: harness.clock.nowUtc(),
      );
      await harness.database.markJournalStarted(harness.clock.nowUtc());

      final LocalUser before = (await harness.database.findProfile())!;
      final result = await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      expect(result.isSuccess, isTrue);

      final AccountSnapshot snapshot = result.valueOrNull!;
      expect(snapshot.accountUserId, accountId);
      expect(snapshot.localUserId, before.id);
      expect(snapshot.localJournalIsSeparate, isTrue);

      final LocalUser after = (await harness.database.findProfile())!;
      expect(after.id, before.id);
      expect(after.hasLocalJournal, isTrue);
    });

    test('keeps the session in the keychain, not in the database', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) =>
            authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000cc'),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      expect(harness.storage.values.values, contains('access-1'));
      expect(
        await harness.database.readPreference('session.access_token'),
        isNull,
      );
    });
  });

  group('the session', () {
    test('replaces the refresh token every time it is used', () async {
      final FakeServer server = FakeServer((RequestOptions options) {
        if (options.uri.path.endsWith('/auth/refresh')) {
          return tokenResponse(
            accessToken: 'access-2',
            refreshToken: 'refresh-2',
          );
        }
        return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000dd');
      });
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      final result = await harness.repository.refreshSession();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.refreshToken, 'refresh-2');

      final stored = await harness.sessionStore.read();
      expect(stored!.refreshToken, 'refresh-2');
      expect(server.requestsFor('/v1/auth/refresh').length, 1);
    });

    test('is ended when a refresh token is presented twice', () async {
      final FakeServer server = FakeServer((RequestOptions options) {
        if (options.uri.path.endsWith('/auth/refresh')) {
          return const FakeFailure(401, <String, Object?>{
            'code': 'refresh_token.reused',
          });
        }
        return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000ee');
      });
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      final result = await harness.repository.refreshSession();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, ServerErrorCodes.refreshTokenReused);
      expect(await harness.sessionStore.read(), isNull);
    });

    test('is ended when the refresh token has expired', () async {
      final FakeServer server = FakeServer((RequestOptions options) {
        if (options.uri.path.endsWith('/auth/refresh')) {
          return const FakeFailure(401, <String, Object?>{
            'code': 'refresh_token.expired',
          });
        }
        return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000ff');
      });
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      final result = await harness.repository.refreshSession();

      expect(result.isFailure, isTrue);
      expect(await harness.sessionStore.read(), isNull);
    });
  });

  group('signing out', () {
    test('keeps the journal on the device', () async {
      final FakeServer server = FakeServer(
        (RequestOptions options) =>
            authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000aa'),
      );
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      final result = await harness.repository.signOut();

      expect(result.isSuccess, isTrue);
      expect(await harness.sessionStore.read(), isNull);
      expect(await harness.database.findProfile(), isNotNull);
    });
  });

  group('deleting the account', () {
    test(
      'wipes the device at once and asks the server to wipe its copy',
      () async {
        final FakeServer server = FakeServer((RequestOptions options) {
          if (options.method == 'DELETE') {
            return <String, Object?>{};
          }
          return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000aa');
        });
        final AccountHarness harness = AccountHarness(server: server);
        addTearDown(harness.close);

        await harness.repository.login(
          email: 'ada@example.com',
          password: '12345678',
        );

        final result = await harness.repository.deleteAccount();

        expect(result.isSuccess, isTrue);

        // The journal is gone at once. The device keeps nothing of the account, and the
        // app carries on with an empty profile of its own.
        final LocalUser? profile = await harness.database.findProfile();
        expect(profile?.accountUserId, isNull);
        expect(profile?.hasLocalJournal, isFalse);
        expect(await harness.sessionStore.read(), isNull);
        expect(server.requestsFor('/v1/me').length, 1);
      },
    );

    test(
      'keeps the preferences, which are about the reader and not the journal',
      () async {
        final FakeServer server = FakeServer((RequestOptions options) {
          if (options.method == 'DELETE') {
            return <String, Object?>{};
          }
          return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000aa');
        });
        final AccountHarness harness = AccountHarness(server: server);
        addTearDown(harness.close);

        await harness.database.writePreference(
          'onboarding.intent',
          'slow_down',
        );
        await harness.repository.login(
          email: 'ada@example.com',
          password: '12345678',
        );

        await harness.repository.deleteAccount();

        expect(
          await harness.database.readPreference('onboarding.intent'),
          'slow_down',
        );
      },
    );

    test('keeps the promise when the server cannot be reached', () async {
      final FakeServer server = FakeServer((RequestOptions options) {
        if (options.method == 'DELETE') {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return authResponse(userId: '0192f3a4-5b6c-7d8e-9f0a-0000000000aa');
      });
      final AccountHarness harness = AccountHarness(server: server);
      addTearDown(harness.close);

      await harness.repository.login(
        email: 'ada@example.com',
        password: '12345678',
      );

      final result = await harness.repository.deleteAccount();

      expect(result.isSuccess, isTrue);
      final LocalUser? profile = await harness.database.findProfile();
      expect(profile?.accountUserId, isNull);
      expect(await harness.sessionStore.pendingDeletionToken(), isNotNull);
    });
  });
}
