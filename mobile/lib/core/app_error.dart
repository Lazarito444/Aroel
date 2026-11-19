/// A failure the app can explain.
///
/// Errors travel as codes, never as prose: the same vocabulary the server uses in
/// `Aroel.Core.Domain.Errors.ErrorCodes` — `email.invalid`, `account.creation_failed`,
/// `refresh_token.reused` — plus a small set of codes that only exist on the device
/// (`client.*`).
///
/// The message is resolved at the edge, in [_messageFor], so a screen never has to know
/// where a failure came from.
final class AppError {
  const AppError(this.code, {this.detail, this.isServer = false});

  /// A code the device raised on its own.
  const AppError.client(this.code, {this.detail}) : isServer = false;

  /// A code the server raised.
  const AppError.server(this.code, {this.detail}) : isServer = true;

  /// The stable code, e.g. `email.invalid`.
  final String code;

  /// The server's detail, when it sent one. Never shown raw to the reader.
  final String? detail;

  /// Whether the server raised this error.
  final bool isServer;

  /// The sentence shown to the reader.
  ///
  /// Second person, unhurried, no exclamation marks and no blame (§6.5).
  String get message => _messageFor(code);

  @override
  String toString() => 'AppError($code)';
}

/// Codes the device raises on its own, before the network is involved.
abstract final class ClientErrorCodes {
  static const String emailInvalid = 'client.email_invalid';
  static const String emailEmpty = 'client.email_empty';
  static const String passwordTooShort = 'client.password_too_short';
  static const String passwordEmpty = 'client.password_empty';
  static const String networkUnavailable = 'client.network_unavailable';
  static const String serverUnavailable = 'client.server_unavailable';
  static const String providerUnavailable = 'client.provider_unavailable';
  static const String providerCancelled = 'client.provider_cancelled';
  static const String unexpected = 'client.unexpected';
  static const String syncPartialFailure = 'client.sync_partial_failure';
}

/// Codes the day record raises on its own.
abstract final class DayErrorCodes {
  static const String tooManyTags = 'day.too_many_tags';
  static const String invalidGratitudePosition = 'day.invalid_gratitude_position';
  static const String invalidRating = 'day.invalid_rating';
  static const String tagLabelEmpty = 'day.tag_label_empty';
}

/// Codes the server raises, as declared in `Aroel.Core.Domain.Errors.ErrorCodes`.
abstract final class ServerErrorCodes {
  static const String emailEmpty = 'email.empty';
  static const String emailInvalid = 'email.invalid';
  static const String emailTooLong = 'email.too_long';
  static const String accountCreationFailed = 'account.creation_failed';
  static const String refreshTokenReused = 'refresh_token.reused';
  static const String refreshTokenExpired = 'refresh_token.expired';
}

/// The codes that mean something specific enough to name in a screen.
abstract final class AuthErrorCodes {
  static const String emailTaken = 'auth.email_taken';
  static const String userIdTaken = 'auth.user_id_taken';
  static const String invalidCredentials = 'auth.invalid_credentials';
  static const String accountLocked = 'auth.account_locked';
  static const String emailNotVerified = 'auth.email_not_verified';
  static const String rateLimited = 'auth.rate_limited';
  static const String weakPassword = 'auth.weak_password';
}

String _messageFor(String code) => switch (code) {
  DayErrorCodes.tooManyTags => 'Five tags is enough for one day. Remove one to add another.',
  DayErrorCodes.invalidGratitudePosition => 'A line belongs to one of the three positions.',
  DayErrorCodes.invalidRating => 'A rating runs from 0 to 5 in half steps.',
  DayErrorCodes.tagLabelEmpty => 'Give the tag a word.',
  ClientErrorCodes.emailInvalid => 'That does not look like an email address.',
  ClientErrorCodes.emailEmpty => 'Enter the email address you use.',
  ClientErrorCodes.passwordTooShort => 'Use at least eight characters. Nothing else is required.',
  ClientErrorCodes.passwordEmpty => 'Enter your password.',
  ClientErrorCodes.networkUnavailable => 'You are offline. Everything you write is saved here and will sync when you are back.',
  ClientErrorCodes.serverUnavailable => 'The account service is not answering right now. Your journal is safe on this device.',
  ClientErrorCodes.providerUnavailable => 'That sign-in option is not available on this device yet.',
  ClientErrorCodes.providerCancelled => 'Sign-in was cancelled.',
  ClientErrorCodes.unexpected => 'Something did not go through. Try again in a moment.',
  ClientErrorCodes.syncPartialFailure => 'Some changes have not reached the server yet. They will go with the next sync.',
  AuthErrorCodes.emailTaken => 'That address already has an account. Sign in instead.',
  AuthErrorCodes.userIdTaken => 'This device already belongs to an account. Sign in with the address you used.',
  AuthErrorCodes.invalidCredentials => 'That email and password do not match an account.',
  AuthErrorCodes.accountLocked => 'Too many attempts. This account is paused for five minutes.',
  AuthErrorCodes.emailNotVerified => 'Confirm your email address to turn on sync. Until then everything stays here.',
  AuthErrorCodes.rateLimited => 'Too many attempts. Give it a minute and try again.',
  AuthErrorCodes.weakPassword => 'Use at least eight characters for the password.',
  ServerErrorCodes.emailInvalid => 'That does not look like an email address.',
  ServerErrorCodes.emailTooLong => 'That email address is too long.',
  ServerErrorCodes.accountCreationFailed => 'The account could not be created. Try again in a moment.',
  ServerErrorCodes.refreshTokenReused => 'This session was ended for safety. Sign in again to carry on.',
  ServerErrorCodes.refreshTokenExpired => 'Your session has expired. Sign in again.',
  _ => 'Something did not go through. Try again in a moment.',
};
