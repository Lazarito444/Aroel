import 'package:aroel/app/providers.dart';
import 'package:aroel/core/account.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/config.dart';
import 'package:aroel/core/ids.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:aroel/data/remote/session_interceptor.dart';
import 'package:aroel/data/repositories/account_repository.dart';
import 'package:aroel/data/services/secure_storage.dart';
import 'package:aroel/data/services/session_store.dart';
import 'package:aroel/features/settings/theme_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod/misc.dart' show Override;

/// Reads what the app needs before it shows anything.
///
/// The journal works without a server, so nothing here waits on the network: the local
/// profile is made, the account is read from the keychain, and the onboarding is read
/// from the device's own store.
Future<List<Override>> bootstrapAroel() async {
  final AroelConfig config = AroelConfig.fromEnvironment();
  const Clock clock = SystemClock();
  final AppDatabase database = AppDatabase.open();
  final SessionStore sessionStore = SessionStore(const PlatformSecureStorage());
  final SessionHolder holder = SessionHolder();

  final String timeZone = await _deviceTimeZone();
  final String locale = _deviceLocale();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.requestTimeout,
      receiveTimeout: config.requestTimeout,
      sendTimeout: config.requestTimeout,
      headers: <String, Object>{'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(SessionInterceptor(dio, holder));

  final AuthApi api = AuthApi(dio, session: holder);
  final AccountRepository repository = AccountRepository(
    api: api,
    database: database,
    sessionStore: sessionStore,
    clock: clock,
    newId: Ids.uuid7,
    deviceTimeZone: timeZone,
    deviceLocale: locale,
  );
  holder.refresh = repository.refreshSession;

  final AccountSnapshot account = await repository.load();
  final OnboardingState onboarding = await _readOnboarding(database);
  final ThemeMode themeMode = await _readThemeMode(database);

  // A deletion that did not reach the server the first time is finished now.
  await repository.completePendingDeletion();

  return <Override>[
    configProvider.overrideWithValue(config),
    clockProvider.overrideWithValue(clock),
    databaseProvider.overrideWithValue(database),
    sessionStoreProvider.overrideWithValue(sessionStore),
    sessionHolderProvider.overrideWithValue(holder),
    deviceTimeZoneProvider.overrideWithValue(timeZone),
    deviceLocaleProvider.overrideWithValue(locale),
    accountRepositoryProvider.overrideWithValue(repository),
    accountServiceProvider.overrideWithValue(repository),
    preferencesStoreProvider.overrideWithValue(database),
    initialAccountProvider.overrideWithValue(account),
    initialOnboardingProvider.overrideWithValue(onboarding),
    initialThemeModeProvider.overrideWithValue(themeMode),
  ];
}

Future<String> _deviceTimeZone() async {
  try {
    final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  } catch (_) {
    return 'UTC';
  }
}

String _deviceLocale() {
  final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
  return locale.toLanguageTag();
}

Future<OnboardingState> _readOnboarding(AppDatabase database) async {
  final String? completed = await database.readPreference(
    PreferenceKeys.onboardingCompleted,
  );
  final String? intent = await database.readPreference(
    PreferenceKeys.onboardingIntent,
  );
  final String? rating = await database.readPreference(
    PreferenceKeys.onboardingFirstRating,
  );

  return OnboardingState(
    completed: completed == 'true',
    intent: intent == null ? null : OnboardingIntentCopy.fromWireName(intent),
    firstRating: rating == null ? null : int.tryParse(rating),
  );
}

Future<ThemeMode> _readThemeMode(AppDatabase database) async {
  final String? mode = await database.readPreference(AppearanceKeys.themeMode);
  return switch (mode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
