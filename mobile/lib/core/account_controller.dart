import 'package:aroel/core/account.dart';
import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/provider_sign_in.dart';
import 'package:aroel/core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_controller.freezed.dart';

/// What the auth module knows and what it is doing.
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    /// The account as it stands.
    required AccountSnapshot account,

    /// Whether the module is waiting for the server.
    @Default(false) bool busy,

    /// The code of the last failure.
    String? errorCode,

    /// The sentence that explains the last failure, when there was one.
    String? errorMessage,
  }) = _AuthState;
}

/// The account of this device.
///
/// The controller is the only thing that changes the account; the screens ask it and
/// listen to it.
class AccountController extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState(account: ref.watch(initialAccountProvider));

  AccountService get _account => ref.read(accountServiceProvider);

  /// Signs in with an address and a password.
  Future<bool> signIn({required String email, required String password}) => _run(() => _account.login(email: email, password: password));

  /// Creates an account, adopting the journal already on the device.
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) => _run(
    () => _account.register(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  /// Signs in with Apple or Google.
  Future<bool> signInWithProvider(AuthProvider provider) async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final ProviderSignInService service = ref.read(
      providerSignInServiceProvider,
    );
    final Result<ProviderCredential> credential = await service.signIn(
      provider,
    );

    if (credential.isFailure) {
      final AppError error = credential.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    final ProviderCredential identity = credential.valueOrNull!;
    return _run(
      () => _account.loginWithProvider(
        provider: identity.provider.wireName,
        idToken: identity.idToken,
        displayName: identity.displayName,
      ),
    );
  }

  /// Ends the session. The journal stays on the device.
  Future<void> signOut() async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<void> result = await _account.signOut();
    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return;
    }

    final AccountSnapshot snapshot = await _account.load();
    state = AuthState(account: snapshot);
  }

  /// Changes the password of the signed-in account.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<void> result = await _account.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    state = state.copyWith(busy: false);
    return true;
  }

  /// Changes the display name or the timezone.
  Future<bool> updateProfile({String? displayName, String? timeZone}) async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<AccountSnapshot> result = await _account.updateProfile(
      displayName: displayName,
      timeZone: timeZone,
    );

    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    state = state.copyWith(account: result.valueOrNull!, busy: false);
    return true;
  }

  /// Asks the server to send the verification email again.
  Future<bool> sendVerificationEmail() async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<void> result = await _account.sendVerificationEmail();
    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    state = state.copyWith(busy: false);
    return true;
  }

  /// Deletes the account and everything it holds.
  Future<bool> deleteAccount() async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<void> result = await _account.deleteAccount();
    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    final AccountSnapshot snapshot = await _account.load();
    state = AuthState(account: snapshot);
    return true;
  }

  /// Clears the last failure.
  void clearError() {
    if (state.errorCode == null) {
      return;
    }
    state = state.copyWith(errorCode: null, errorMessage: null);
  }

  Future<bool> _run(Future<Result<AccountSnapshot>> Function() action) async {
    state = state.copyWith(busy: true, errorCode: null, errorMessage: null);

    final Result<AccountSnapshot> result = await action();

    if (result.isFailure) {
      final AppError error = result.errorOrNull!;
      state = state.copyWith(
        busy: false,
        errorCode: error.code,
        errorMessage: error.message,
      );
      return false;
    }

    state = AuthState(account: result.valueOrNull!);
    return true;
  }
}

/// The account of this device.
final NotifierProvider<AccountController, AuthState> accountControllerProvider = NotifierProvider<AccountController, AuthState>(AccountController.new);
