import 'package:aroel/core/account_controller.dart';
import 'package:aroel/core/provider_sign_in.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_notice.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Which way the reader is going.
enum AuthMode {
  /// Signing in to an account that already exists.
  signIn,

  /// Creating an account.
  signUp,
}

/// Sign in, or create an account.
///
/// The account is optional and the screen says so: the form is behind a disclosure, the
/// providers are one tap away, and nothing in the app waits for it (§5.1).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.mode = AuthMode.signIn});

  /// Whether the reader is signing in or creating an account.
  final AuthMode mode;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _emailVisible = false;

  bool get _isSignUp => widget.mode == AuthMode.signUp;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(accountControllerProvider);
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      showBackButton: true,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.xl,
          Space.lg,
          Space.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SealMark(),
            const SizedBox(height: Space.md),
            Text(
              _isSignUp ? 'Create an account' : 'Sign in',
              style: type.display,
            ),
            const SizedBox(height: Space.xs),
            Text(
              _isSignUp
                  ? 'An account carries your journal to a second device. Everything you '
                        'write works without one.'
                  : 'Your journal stays on this device either way. Signing in lets it '
                        'follow you to another one.',
              style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
            ),
            const SizedBox(height: Space.lg),
            PaperButton(
              label: 'Continue with Apple',
              variant: PaperButtonVariant.secondary,
              leading: const Icon(Icons.apple, size: 16),
              busy: auth.busy,
              onPressed: () => _signInWithProvider(AuthProvider.apple),
            ),
            const SizedBox(height: Space.xs),
            PaperButton(
              label: 'Continue with Google',
              variant: PaperButtonVariant.secondary,
              busy: auth.busy,
              onPressed: () => _signInWithProvider(AuthProvider.google),
            ),
            const SizedBox(height: Space.lg),
            _Disclosure(
              expanded: _emailVisible,
              onTap: () {
                ref.read(accountControllerProvider.notifier).clearError();
                setState(() => _emailVisible = !_emailVisible);
              },
            ),
            if (_emailVisible) ...<Widget>[
              const SizedBox(height: Space.md),
              PaperTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !auth.busy,
                onChanged: (_) => ref.read(accountControllerProvider.notifier).clearError(),
              ),
              const SizedBox(height: Space.md),
              PaperTextField(
                label: 'Password',
                controller: _password,
                hint: 'At least eight characters',
                obscure: true,
                textInputAction: TextInputAction.done,
                enabled: !auth.busy,
                onSubmitted: (_) => _submit(),
                onChanged: (_) => ref.read(accountControllerProvider.notifier).clearError(),
              ),
              const SizedBox(height: Space.lg),
              PaperButton(
                label: _isSignUp ? 'Create an account' : 'Continue',
                busy: auth.busy,
                onPressed: _submit,
              ),
              const SizedBox(height: Space.xs),
              PaperButton(
                label: _isSignUp ? 'I already have an account' : 'Create an account',
                variant: PaperButtonVariant.quiet,
                onPressed: () {
                  ref.read(accountControllerProvider.notifier).clearError();
                  context.go(_isSignUp ? '/sign-in' : '/sign-up');
                },
              ),
            ],
            if (auth.errorMessage != null) ...<Widget>[
              const SizedBox(height: Space.md),
              PaperNotice(auth.errorMessage!, tone: NoticeTone.error),
            ],
            const SizedBox(height: Space.lg),
            Text(
              'Nothing here is required to write. The journal on this device works the '
              'same with or without an account.',
              style: type.caption,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithProvider(AuthProvider provider) async {
    final bool signedIn = await ref.read(accountControllerProvider.notifier).signInWithProvider(provider);
    if (signedIn && mounted) {
      context.go('/');
    }
  }

  Future<void> _submit() async {
    final AccountController controller = ref.read(
      accountControllerProvider.notifier,
    );

    final bool done = _isSignUp
        ? await controller.register(
            email: _email.text,
            password: _password.text,
          )
        : await controller.signIn(email: _email.text, password: _password.text);

    if (done && mounted) {
      context.go('/');
    }
  }
}

/// The hairline that separates the providers from the email form.
class _Disclosure extends StatelessWidget {
  const _Disclosure({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(child: Container(height: 1, color: tokens.palette.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm),
            child: Text(
              'or use email',
              style: type.label.copyWith(color: tokens.palette.inkFaint),
            ),
          ),
          Expanded(child: Container(height: 1, color: tokens.palette.border)),
        ],
      ),
    );
  }
}

/// The mark at the top of the screen: a seal, drawn rather than imported.
class _SealMark extends StatelessWidget {
  const _SealMark();

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: tokens.palette.accent, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.palette.accent,
          ),
        ),
      ),
    );
  }
}
