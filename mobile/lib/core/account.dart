import 'package:aroel/core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

/// What kind of account the reader has, if any (§5.1).
enum AccountStatus {
  /// No account has ever been linked on this device. This is the default, and it is a
  /// complete app, not a degraded one.
  localOnly,

  /// An account is linked and the session is live.
  signedIn,

  /// An account was linked and the reader signed out. The journal stayed on the device.
  signedOut,
}

/// What the app knows about the account at this moment.
@freezed
abstract class AccountSnapshot with _$AccountSnapshot {
  const factory AccountSnapshot({
    /// The kind of account.
    required AccountStatus status,

    /// The identifier this device writes its rows under.
    required String localUserId,

    /// The identifier of the linked account, when there is one.
    String? accountUserId,

    /// The address of the linked account.
    String? email,

    /// The name shown in the app.
    @Default('') String displayName,

    /// The timezone the days are counted in.
    @Default('') String timeZone,

    /// Whether the address has been confirmed.
    @Default(false) bool emailVerified,

    /// Whether the journal on this device lives under an identifier of its own.
    ///
    /// It happens when a reader with a journal on the device signs in to an account that
    /// was made elsewhere: the journal stays here, because a row is never re-keyed (§4.2).
    @Default(false) bool localJournalIsSeparate,

    /// When the bearer token stops being accepted.
    DateTime? accessTokenExpiresAt,
  }) = _AccountSnapshot;

  const AccountSnapshot._();

  /// Whether there is an account to talk to.
  bool get hasAccount => status == AccountStatus.signedIn;

  /// Whether the journal may be sent to the server.
  ///
  /// Verification is required before the first sync, and never before writing (§5.1).
  bool get canSync => status == AccountStatus.signedIn && emailVerified;

  /// Whether the reader is signed in but has not confirmed the address.
  bool get needsVerification => status == AccountStatus.signedIn && !emailVerified;
}

/// What the account module needs from the server and from the device's store.
///
/// The port lives here so that the rules of the account do not depend on how the account
/// is reached; the data layer implements it, and the app wires the two together.
abstract interface class AccountService {
  /// Reads the account as it stands.
  Future<AccountSnapshot> load();

  /// Creates an account and adopts the journal already on the device.
  Future<Result<AccountSnapshot>> register({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs in with an address and a password.
  Future<Result<AccountSnapshot>> login({
    required String email,
    required String password,
  });

  /// Signs in with a provider token, which the server validates.
  Future<Result<AccountSnapshot>> loginWithProvider({
    required String provider,
    required String idToken,
    String? displayName,
  });

  /// Ends the session. The journal stays on the device.
  Future<Result<void>> signOut();

  /// Changes the password of the signed-in account.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Changes the display name or the timezone of the signed-in account.
  Future<Result<AccountSnapshot>> updateProfile({
    String? displayName,
    String? timeZone,
  });

  /// Asks the server to send the verification email again.
  Future<Result<void>> sendVerificationEmail();

  /// Deletes the account and everything it holds.
  Future<Result<void>> deleteAccount();
}

/// The account of this device.
///
/// The app wires the real service at launch; until it does, the account is not there.
final Provider<AccountService> accountServiceProvider = Provider<AccountService>(
  (Ref ref) => throw StateError(
    'The account has to be wired before the app starts.',
  ),
);

/// The account as it was read at launch.
final Provider<AccountSnapshot> initialAccountProvider = Provider<AccountSnapshot>(
  (Ref ref) => throw StateError('The account has to be read before the app starts.'),
);
