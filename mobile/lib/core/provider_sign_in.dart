import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'provider_sign_in.freezed.dart';

/// The identity providers the app offers (§5.1).
enum AuthProvider {
  /// Sign in with Apple.
  apple,

  /// Sign in with Google.
  google,
}

/// The name the server knows the provider by.
extension AuthProviderName on AuthProvider {
  /// The wire name of the provider.
  String get wireName => switch (this) {
    AuthProvider.apple => 'apple',
    AuthProvider.google => 'google',
  };
}

/// What a provider hands back: a token the server validates, and what it knows about the
/// reader.
@freezed
abstract class ProviderCredential with _$ProviderCredential {
  const factory ProviderCredential({
    /// The provider that was asked.
    required AuthProvider provider,

    /// The token the server validates.
    required String idToken,

    /// The address the provider knows, when it tells us.
    String? email,

    /// The name the provider knows, when it tells us.
    String? displayName,
  }) = _ProviderCredential;
}

/// Signs in with Apple or Google.
///
/// The device never decides who the reader is: it asks the provider for a token and the
/// server validates it (§7.2).
class ProviderSignInService {
  ProviderSignInService({
    required this.googleClientId,
    required this.googleServerClientId,
    required this.appleWebClientId,
  });

  /// The web client id Google asks for on iOS.
  final String googleClientId;

  /// The web client id Google asks for on Android.
  final String googleServerClientId;

  /// The service id Apple asks for on the platforms that are not Apple's own.
  final String appleWebClientId;

  Future<void>? _googleReady;

  /// Signs in with [provider].
  Future<Result<ProviderCredential>> signIn(AuthProvider provider) async {
    try {
      return switch (provider) {
        AuthProvider.apple => await _signInWithApple(),
        AuthProvider.google => await _signInWithGoogle(),
      };
    } on AppError catch (error) {
      return Result.failure(error);
    } catch (_) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.providerUnavailable),
      );
    }
  }

  Future<Result<ProviderCredential>> _signInWithApple() async {
    if (!await SignInWithApple.isAvailable()) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.providerUnavailable),
      );
    }

    final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
          scopes: const <AppleIDAuthorizationScopes>[
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          webAuthenticationOptions: appleWebClientId.isEmpty
              ? null
              : WebAuthenticationOptions(
                  clientId: appleWebClientId,
                  redirectUri: Uri.parse('https://$appleWebClientId/callback'),
                ),
        );

    final String? identityToken = credential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.providerCancelled),
      );
    }

    final String? givenName = credential.givenName;
    final String? familyName = credential.familyName;
    final String? displayName = (givenName == null && familyName == null)
        ? null
        : <String?>[givenName, familyName].whereType<String>().join(' ');

    return Result.success(
      ProviderCredential(
        provider: AuthProvider.apple,
        idToken: identityToken,
        email: credential.email,
        displayName: displayName,
      ),
    );
  }

  Future<Result<ProviderCredential>> _signInWithGoogle() async {
    if (googleClientId.isEmpty && googleServerClientId.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.providerUnavailable),
      );
    }

    _googleReady ??= GoogleSignIn.instance.initialize(
      clientId: googleClientId.isEmpty ? null : googleClientId,
      serverClientId: googleServerClientId.isEmpty
          ? null
          : googleServerClientId,
    );
    await _googleReady;

    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate();
    final String? idToken = account.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      return Result.failure(
        const AppError.client(ClientErrorCodes.providerCancelled),
      );
    }

    return Result.success(
      ProviderCredential(
        provider: AuthProvider.google,
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
      ),
    );
  }
}

/// The identity providers the app offers.
///
/// The identifiers come from the build, so that no environment is baked into the app:
/// `AROEL_GOOGLE_CLIENT_ID`, `AROEL_GOOGLE_SERVER_CLIENT_ID` and
/// `AROEL_APPLE_SERVICE_ID`.
final Provider<ProviderSignInService> providerSignInServiceProvider =
    Provider<ProviderSignInService>(
      (Ref ref) => ProviderSignInService(
        googleClientId: const String.fromEnvironment('AROEL_GOOGLE_CLIENT_ID'),
        googleServerClientId: const String.fromEnvironment(
          'AROEL_GOOGLE_SERVER_CLIENT_ID',
        ),
        appleWebClientId: const String.fromEnvironment(
          'AROEL_APPLE_SERVICE_ID',
        ),
      ),
    );
