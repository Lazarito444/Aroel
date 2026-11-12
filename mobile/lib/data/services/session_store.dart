import 'package:aroel/data/services/secure_storage.dart';

/// The session as it is kept on the device.
///
/// The tokens live in the keychain, never in the database and never in the logs.
class StoredSession {
  const StoredSession({
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

  /// Whether the address has been confirmed.
  final bool emailVerified;

  /// The bearer token.
  final String accessToken;

  /// The token that buys a new bearer token.
  final String refreshToken;

  /// When the bearer token stops being accepted.
  final DateTime accessTokenExpiresAt;

  /// When the refresh token stops being accepted.
  final DateTime refreshTokenExpiresAt;

  /// Whether the session can still be renewed at [now].
  bool canRefreshAt(DateTime now) => refreshTokenExpiresAt.isAfter(now);
}

/// Keeps the session in the platform's secure storage.
class SessionStore {
  SessionStore(this._storage);

  /// The secure storage of the platform.
  final SecureStorage _storage;

  static const String _accessTokenKey = 'session.access_token';
  static const String _refreshTokenKey = 'session.refresh_token';
  static const String _accessExpiresKey = 'session.access_expires_at';
  static const String _refreshExpiresKey = 'session.refresh_expires_at';
  static const String _userIdKey = 'session.user_id';
  static const String _emailKey = 'session.email';
  static const String _verifiedKey = 'session.email_verified';
  static const String _pendingDeletionKey = 'account.pending_deletion_token';

  /// Reads the session, when there is one.
  Future<StoredSession?> read() async {
    final Map<String, String> values = await _storage.readAll();
    final String? accessToken = values[_accessTokenKey];
    final String? refreshToken = values[_refreshTokenKey];
    final String? userId = values[_userIdKey];
    if (accessToken == null || refreshToken == null || userId == null) {
      return null;
    }

    return StoredSession(
      userId: userId,
      email: values[_emailKey] ?? '',
      emailVerified: values[_verifiedKey] == 'true',
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt:
          DateTime.tryParse(values[_accessExpiresKey] ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      refreshTokenExpiresAt:
          DateTime.tryParse(values[_refreshExpiresKey] ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// Writes the session.
  Future<void> write(StoredSession session) async {
    final Map<String, String> values = <String, String>{
      _accessTokenKey: session.accessToken,
      _refreshTokenKey: session.refreshToken,
      _accessExpiresKey: session.accessTokenExpiresAt.toUtc().toIso8601String(),
      _refreshExpiresKey: session.refreshTokenExpiresAt
          .toUtc()
          .toIso8601String(),
      _userIdKey: session.userId,
      _emailKey: session.email,
      _verifiedKey: session.emailVerified ? 'true' : 'false',
    };

    for (final MapEntry<String, String> entry in values.entries) {
      await _storage.write(entry.key, entry.value);
    }
  }

  /// Forgets the session. The journal stays where it is.
  Future<void> clear() => _storage.deleteAll();

  /// Keeps the token of an account whose deletion has not reached the server yet.
  ///
  /// The journal is wiped at once; this one value is kept until the server confirms, so
  /// that the promise on the deletion screen can be kept.
  Future<void> rememberPendingDeletion(String accessToken) =>
      _storage.write(_pendingDeletionKey, accessToken);

  /// The token of a deletion that has not reached the server yet.
  Future<String?> pendingDeletionToken() => _storage.read(_pendingDeletionKey);

  /// Forgets a pending deletion.
  Future<void> forgetPendingDeletion() => _storage.delete(_pendingDeletionKey);
}
