/// Where the client finds the server, and how it is allowed to behave.
///
/// The values come from `--dart-define` so that no environment is baked into the build:
///
/// ```
/// flutter run --dart-define=AROEL_API_BASE_URL=https://localhost:5001/v1
/// ```
class AroelConfig {
  const AroelConfig({
    required this.apiBaseUrl,
    this.requestTimeout = const Duration(seconds: 20),
  });

  /// The configuration the running app uses.
  factory AroelConfig.fromEnvironment() => const AroelConfig(
    apiBaseUrl: String.fromEnvironment(
      'AROEL_API_BASE_URL',
      defaultValue: 'https://10.0.2.2:5001/v1',
    ),
  );

  /// The base address of the API, including the `/v1` prefix.
  final String apiBaseUrl;

  /// How long a single request may take before it is given up on.
  final Duration requestTimeout;

  /// Whether the app is pointed at a server at all.
  ///
  /// The journal works without one; only the account needs it.
  bool get hasServer => apiBaseUrl.trim().isNotEmpty;
}
