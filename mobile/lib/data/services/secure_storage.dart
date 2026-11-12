import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The keychain the session lives in.
///
/// The app talks to this, not to the plugin, so that the rules about what is kept where
/// are testable and the platform stays behind an interface.
abstract interface class SecureStorage {
  /// Reads a value, when it is there.
  Future<String?> read(String key);

  /// Writes a value.
  Future<void> write(String key, String value);

  /// Removes a value.
  Future<void> delete(String key);

  /// Removes every value.
  Future<void> deleteAll();

  /// Reads every value.
  Future<Map<String, String>> readAll();
}

/// The keychain of the platform.
class PlatformSecureStorage implements SecureStorage {
  const PlatformSecureStorage([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();
}

/// A keychain that keeps everything in memory, for tests.
class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> deleteAll() async => values.clear();

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.of(values);
}
