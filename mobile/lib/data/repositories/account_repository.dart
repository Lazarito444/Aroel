import 'package:aroel/core/account.dart';
import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/core/validators.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/auth_api.dart';
import 'package:aroel/data/remote/auth_dto.dart';
import 'package:aroel/data/services/session_store.dart';
import 'package:drift/drift.dart';

/// The account, as the device sees it.
///
/// The rules live here rather than in the screens: what a password may be, what an
/// account is called, when a session has to be renewed, and what deleting an account
/// means for the journal on the device.
class AccountRepository implements AccountService {
  AccountRepository({
    required AuthApi api,
    required AppDatabase database,
    required SessionStore sessionStore,
    required Clock clock,
    required String Function() newId,
    required String deviceTimeZone,
    required String deviceLocale,
  }) : _api = api,
       _database = database,
       _sessionStore = sessionStore,
       _clock = clock,
       _newId = newId,
       _deviceTimeZone = deviceTimeZone,
       _deviceLocale = deviceLocale;

  final AuthApi _api;
  final AppDatabase _database;
  final SessionStore _sessionStore;
  final Clock _clock;
  final String Function() _newId;
  final String _deviceTimeZone;
  final String _deviceLocale;

  AuthSession? _session;

  /// The live session, when there is one.
  AuthSession? get session => _session;

  /// The bearer token to present, when there is one.
  String? get accessToken => _session?.accessToken;

  /// Reads the account as it stands, creating the local profile if this is the first
  /// launch.
  @override
  Future<AccountSnapshot> load() async {
    final LocalUser profile = await _ensureProfile();
    final StoredSession? stored = await _sessionStore.read();
    if (stored == null) {
      _session = null;
      _api.session.accessToken = null;
      return AccountSnapshot(
        status: AccountStatus.localOnly,
        localUserId: profile.id,
        displayName: profile.displayName,
        timeZone: profile.timeZone,
      );
    }

    _session = AuthSession(
      userId: stored.userId,
      email: stored.email,
      emailVerified: stored.emailVerified,
      accessToken: stored.accessToken,
      refreshToken: stored.refreshToken,
      accessTokenExpiresAt: stored.accessTokenExpiresAt,
      refreshTokenExpiresAt: stored.refreshTokenExpiresAt,
    );
    _api.session.accessToken = stored.accessToken;

    final bool expired = !stored.canRefreshAt(_clock.nowUtc());
    if (expired) {
      await _sessionStore.clear();
      _session = null;
      _api.session.accessToken = null;
      return AccountSnapshot(
        status: AccountStatus.signedOut,
        localUserId: profile.id,
        email: stored.email,
        displayName: profile.displayName,
        timeZone: profile.timeZone,
      );
    }

    return AccountSnapshot(
      status: AccountStatus.signedIn,
      localUserId: profile.id,
      accountUserId: profile.accountUserId,
      email: stored.email,
      displayName: profile.displayName,
      timeZone: profile.timeZone,
      emailVerified: stored.emailVerified,
      localJournalIsSeparate:
          profile.accountUserId != null && profile.accountUserId != profile.id,
      accessTokenExpiresAt: stored.accessTokenExpiresAt,
    );
  }

  /// Creates an account and adopts the journal already on the device (§4.2).
  ///
  /// The identifier the device writes its rows under is sent with the registration, so
  /// not one row has to be re-keyed. The server rejects an identifier that is taken.
  @override
  Future<Result<AccountSnapshot>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final String normalized = Validators.normalizeEmail(email);
    if (normalized.isEmpty) {
      return Result.failure(const AppError.client(ClientErrorCodes.emailEmpty));
    }
    if (!Validators.isValidEmail(normalized)) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.emailInvalid),
      );
    }
    if (password.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.passwordEmpty),
      );
    }
    if (!Validators.isValidPassword(password)) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.passwordTooShort),
      );
    }

    final LocalUser profile = await _ensureProfile();

    final Result<AuthResponseDto> response = await _api.register(
      RegisterRequestDto(
        userId: profile.id,
        email: normalized,
        password: password,
        displayName: displayName?.trim().isNotEmpty == true
            ? displayName!.trim()
            : _defaultDisplayName(normalized),
        timeZone: profile.timeZone,
        locale: profile.locale,
      ),
    );

    return response.fold(
      (AuthResponseDto body) => _adopt(body),
      (AppError error) => Result.failure(error),
    );
  }

  /// Signs in with an address and a password.
  @override
  Future<Result<AccountSnapshot>> login({
    required String email,
    required String password,
  }) async {
    final String normalized = Validators.normalizeEmail(email);
    if (normalized.isEmpty) {
      return Result.failure(const AppError.client(ClientErrorCodes.emailEmpty));
    }
    if (!Validators.isValidEmail(normalized)) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.emailInvalid),
      );
    }
    if (password.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.passwordEmpty),
      );
    }

    final Result<AuthResponseDto> response = await _api.login(
      LoginRequestDto(email: normalized, password: password),
    );

    return response.fold(
      (AuthResponseDto body) => _adopt(body),
      (AppError error) => Result.failure(error),
    );
  }

  /// Signs in with a provider token, which the server validates (§5.1).
  @override
  Future<Result<AccountSnapshot>> loginWithProvider({
    required String provider,
    required String idToken,
    String? displayName,
  }) async {
    final LocalUser profile = await _ensureProfile();

    final Result<AuthResponseDto> response = await _api.oauth(
      OAuthRequestDto(
        provider: provider,
        idToken: idToken,
        userId: profile.id,
        timeZone: profile.timeZone,
        locale: profile.locale,
        displayName: displayName,
      ),
    );

    return response.fold(
      (AuthResponseDto body) => _adopt(body),
      (AppError error) => Result.failure(error),
    );
  }

  /// Exchanges the refresh token for a new pair, rotating the refresh token (§7.2).
  ///
  /// A refresh token that is presented twice means it leaked: the whole family is
  /// revoked, and the reader is signed out.
  Future<Result<AuthSession>> refreshSession() async {
    final StoredSession? stored = await _sessionStore.read();
    if (stored == null) {
      return Result.failure(const AppError.client(ClientErrorCodes.unexpected));
    }

    final Result<TokenDto> response = await _api.refresh(
      RefreshRequestDto(refreshToken: stored.refreshToken),
    );

    if (response.isFailure) {
      final String code = response.errorOrNull!.code;
      if (code == ServerErrorCodes.refreshTokenReused ||
          code == ServerErrorCodes.refreshTokenExpired) {
        await _forgetSession();
      }
      return Result.failure(response.errorOrNull!);
    }

    final TokenDto tokens = response.valueOrNull!;
    final StoredSession rotated = StoredSession(
      userId: stored.userId,
      email: stored.email,
      emailVerified: stored.emailVerified,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      accessTokenExpiresAt: tokens.accessTokenExpiresAt,
      refreshTokenExpiresAt: tokens.refreshTokenExpiresAt,
    );
    await _sessionStore.write(rotated);

    _session = AuthSession(
      userId: rotated.userId,
      email: rotated.email,
      emailVerified: rotated.emailVerified,
      accessToken: rotated.accessToken,
      refreshToken: rotated.refreshToken,
      accessTokenExpiresAt: rotated.accessTokenExpiresAt,
      refreshTokenExpiresAt: rotated.refreshTokenExpiresAt,
    );
    _api.session.accessToken = rotated.accessToken;

    return Result.success(_session!);
  }

  /// Ends the session. The journal stays on the device.
  ///
  /// The server is told, but the reader is not held up: signing out while offline has to
  /// work.
  @override
  Future<Result<void>> signOut() async {
    await _api.logout();
    await _forgetSession();
    return Result.success(null);
  }

  /// Changes the password of the signed-in account.
  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.passwordEmpty),
      );
    }
    if (!Validators.isValidPassword(newPassword)) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.passwordTooShort),
      );
    }

    final Result<void> response = await _api.changePassword(
      PasswordChangeDto(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    return response;
  }

  /// Changes the display name or the timezone of the signed-in account.
  @override
  Future<Result<AccountSnapshot>> updateProfile({
    String? displayName,
    String? timeZone,
  }) async {
    final Result<UserDto> response = await _api.updateMe(
      displayName: displayName,
      timeZone: timeZone,
    );

    if (response.isFailure) {
      return Result.failure(response.errorOrNull!);
    }

    final UserDto user = response.valueOrNull!;
    final LocalUser profile = await _ensureProfile();
    await _database
        .update(_database.localUsers)
        .write(
          LocalUsersCompanion(
            displayName: Value(user.displayName),
            timeZone: Value(user.timeZone),
            updatedAt: Value(_clock.nowUtc()),
          ),
        );

    return Result.success(
      AccountSnapshot(
        status: AccountStatus.signedIn,
        localUserId: profile.id,
        accountUserId: profile.accountUserId ?? user.id,
        email: user.email,
        displayName: user.displayName,
        timeZone: user.timeZone,
        emailVerified: user.emailVerified,
        localJournalIsSeparate:
            profile.accountUserId != null &&
            profile.accountUserId != profile.id,
        accessTokenExpiresAt: _session?.accessTokenExpiresAt,
      ),
    );
  }

  /// Asks the server to send the verification email again.
  @override
  Future<Result<void>> sendVerificationEmail() => _api.sendVerificationEmail();

  /// Deletes the account and everything it holds (§5.9, US-106).
  ///
  /// The journal on this device goes at once. The copy on the server is asked to go too,
  /// and the token that asks is kept until the server confirms, so the promise on the
  /// screen is a promise the app keeps.
  @override
  Future<Result<void>> deleteAccount() async {
    final String? token = _session?.accessToken;

    await _database.wipeLocalData();
    await _sessionStore.clear();
    _session = null;
    _api.session.accessToken = null;

    await _ensureProfile();

    if (token == null || token.isEmpty) {
      return Result.success(null);
    }

    await _sessionStore.rememberPendingDeletion(token);
    _api.session.accessToken = token;

    final Result<void> response = await _api.deleteMe();
    _api.session.accessToken = null;

    if (response.isSuccess) {
      await _sessionStore.forgetPendingDeletion();
    }

    return Result.success(null);
  }

  /// Finishes a deletion that did not reach the server the first time.
  Future<void> completePendingDeletion() async {
    final String? token = await _sessionStore.pendingDeletionToken();
    if (token == null || token.isEmpty) {
      return;
    }

    _api.session.accessToken = token;
    final Result<void> response = await _api.deleteMe();
    _api.session.accessToken = null;

    if (response.isSuccess) {
      await _sessionStore.forgetPendingDeletion();
    }
  }

  /// The identifier this device writes its rows under.
  Future<String> localUserId() async => (await _ensureProfile()).id;

  Future<LocalUser> _ensureProfile() async {
    final LocalUser? existing = await _database.findProfile();
    if (existing != null) {
      return existing;
    }

    return _database.ensureLocalProfile(
      id: _newId(),
      timeZone: _deviceTimeZone,
      locale: _deviceLocale,
      now: _clock.nowUtc(),
    );
  }

  /// Takes on the account the server answered with.
  Future<Result<AccountSnapshot>> _adopt(AuthResponseDto body) async {
    final LocalUser profile = await _ensureProfile();
    final DateTime now = _clock.nowUtc();

    final StoredSession session = StoredSession(
      userId: body.user.id,
      email: body.user.email,
      emailVerified: body.user.emailVerified,
      accessToken: body.tokens.accessToken,
      refreshToken: body.tokens.refreshToken,
      accessTokenExpiresAt: body.tokens.accessTokenExpiresAt,
      refreshTokenExpiresAt: body.tokens.refreshTokenExpiresAt,
    );
    await _sessionStore.write(session);

    _session = AuthSession(
      userId: session.userId,
      email: session.email,
      emailVerified: session.emailVerified,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
      refreshTokenExpiresAt: session.refreshTokenExpiresAt,
    );
    _api.session.accessToken = session.accessToken;

    final bool sameIdentifier = body.user.id == profile.id;
    final bool adoptIdentifier = !sameIdentifier && !profile.hasLocalJournal;

    await _database.linkAccount(
      body.user.id,
      adoptIdentifier: adoptIdentifier,
      now: now,
    );

    final LocalUser updated = await _database.findProfile() ?? profile;

    return Result.success(
      AccountSnapshot(
        status: AccountStatus.signedIn,
        localUserId: updated.id,
        accountUserId: body.user.id,
        email: body.user.email,
        displayName: body.user.displayName,
        timeZone: body.user.timeZone,
        emailVerified: body.user.emailVerified,
        localJournalIsSeparate: updated.id != body.user.id,
        accessTokenExpiresAt: session.accessTokenExpiresAt,
      ),
    );
  }

  Future<void> _forgetSession() async {
    await _sessionStore.clear();
    _session = null;
    _api.session.accessToken = null;
  }

  static String _defaultDisplayName(String email) {
    final int separator = email.indexOf('@');
    return separator > 0 ? email.substring(0, separator) : email;
  }
}
