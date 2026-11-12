/// The rules the account forms enforce before the network is asked.
///
/// They mirror the server's own rules — `Aroel.Core.Domain.ValueObjects.EmailAddress`
/// and `IdentitySetup.MinimumPasswordLength` — so that a mistake is caught on the
/// device, in the same sentence the server would have used.
abstract final class Validators {
  /// The shortest password the app accepts (§5.1: eight characters, no composition rules).
  static const int minimumPasswordLength = 8;

  /// The longest email address the app accepts, per RFC 5321.
  static const int maximumEmailLength = 254;

  static final RegExp _emailShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Normalizes an address the way the server does: trimmed and lowercased.
  static String normalizeEmail(String value) => value.trim().toLowerCase();

  /// Whether [value] is an address the server would accept.
  static bool isValidEmail(String value) {
    String normalized = normalizeEmail(value);
    if (normalized.isEmpty || normalized.length > maximumEmailLength) {
      return false;
    }

    int separator = normalized.indexOf('@');
    if (separator <= 0 || separator != normalized.lastIndexOf('@')) {
      return false;
    }

    String domain = normalized.substring(separator + 1);
    if (domain.startsWith('.') || domain.endsWith('.')) {
      return false;
    }

    return _emailShape.hasMatch(normalized);
  }

  /// Whether [value] is a password the server would accept.
  ///
  /// Length is the only rule. There are no composition rules, so there is no message
  /// beyond the length check.
  static bool isValidPassword(String value) =>
      value.length >= minimumPasswordLength;
}
