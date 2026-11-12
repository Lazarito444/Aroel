import 'package:aroel/core/account.dart';
import 'package:aroel/core/account_controller.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_notice.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/paper_sheet.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The account of the reader (§5.9, US-105).
///
/// Without an account this screen says "local only" and offers to add sync. Nothing in
/// the app is greyed out for want of an account.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(accountControllerProvider);
    final AccountSnapshot account = auth.account;
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Account',
      child: ListView(
        children: <Widget>[
          if (account.needsVerification) ...<Widget>[
            PaperNotice(
              'Confirm your email address to turn on sync. Until then everything you '
              'write stays on this device.',
              tone: NoticeTone.warning,
              title: 'One step left',
            ),
            const SizedBox(height: Space.sm),
            PaperButton(
              label: 'Send the email again',
              variant: PaperButtonVariant.secondary,
              busy: auth.busy,
              onPressed: () => ref
                  .read(accountControllerProvider.notifier)
                  .sendVerificationEmail(),
            ),
            const SizedBox(height: Space.md),
          ],
          switch (account.status) {
            AccountStatus.signedIn => _SignedIn(account: account),
            AccountStatus.signedOut => _SignedOut(email: account.email),
            AccountStatus.localOnly => const _LocalOnly(),
          },
          if (account.status == AccountStatus.signedIn) ...<Widget>[
            const SizedBox(height: Space.lg),
            _Action(
              label: 'Change password',
              onTap: () => _changePassword(context, ref),
            ),
            const Divider(height: Space.lg),
            _Action(
              label: 'Sign out',
              onTap: () =>
                  ref.read(accountControllerProvider.notifier).signOut(),
            ),
            const Divider(height: Space.lg),
            _Action(
              label: 'Delete account',
              destructive: true,
              onTap: () => context.go('/settings/account/delete'),
            ),
          ],
          if (account.localJournalIsSeparate) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text(
              'The journal on this device stays here. The one in your account comes down '
              'from the server.',
              style: type.caption,
            ),
          ],
          if (auth.errorMessage != null) ...<Widget>[
            const SizedBox(height: Space.md),
            PaperNotice(auth.errorMessage!, tone: NoticeTone.error),
          ],
          if (account.status == AccountStatus.signedIn) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text(
              'Your account is ${account.email}.',
              style: type.caption.copyWith(color: tokens.palette.inkFaint),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final TextEditingController current = TextEditingController();
    final TextEditingController next = TextEditingController();

    await showPaperSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PaperSheetTitle(
            'Change password',
            subtitle: 'At least eight characters. Nothing else is required.',
          ),
          const SizedBox(height: Space.lg),
          PaperTextField(
            label: 'Current password',
            controller: current,
            obscure: true,
          ),
          const SizedBox(height: Space.md),
          PaperTextField(
            label: 'New password',
            controller: next,
            obscure: true,
          ),
          const SizedBox(height: Space.lg),
          PaperButton(
            label: 'Change password',
            onPressed: () async {
              final bool changed = await ref
                  .read(accountControllerProvider.notifier)
                  .changePassword(
                    currentPassword: current.text,
                    newPassword: next.text,
                  );
              if (changed && sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
        ],
      ),
    );

    current.dispose();
    next.dispose();
  }
}

/// The account of a reader who has one.
class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.account});

  final AccountSnapshot account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaperCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          _Value(label: 'Email', value: account.email ?? ''),
          const Divider(height: 1),
          _Value(
            label: 'Display name',
            value: account.displayName,
            onTap: () => _edit(
              context,
              ref,
              title: 'Display name',
              subtitle: 'The name shown in the app.',
              initial: account.displayName,
              field: 'Name',
              apply: (String value) => ref
                  .read(accountControllerProvider.notifier)
                  .updateProfile(displayName: value),
            ),
          ),
          const Divider(height: 1),
          _Value(
            label: 'Time zone',
            value: account.timeZone,
            onTap: () => _edit(
              context,
              ref,
              title: 'Time zone',
              subtitle:
                  'The timezone your days are counted in, such as Europe/Madrid.',
              initial: account.timeZone,
              field: 'Time zone',
              apply: (String value) => ref
                  .read(accountControllerProvider.notifier)
                  .updateProfile(timeZone: value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required String initial,
    required String field,
    required Future<bool> Function(String value) apply,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initial,
    );

    await showPaperSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PaperSheetTitle(title, subtitle: subtitle),
          const SizedBox(height: Space.lg),
          PaperTextField(label: field, controller: controller),
          const SizedBox(height: Space.lg),
          PaperButton(
            label: 'Save',
            onPressed: () async {
              final bool saved = await apply(controller.text);
              if (saved && sheetContext.mounted) {
                Navigator.of(sheetContext).pop();
              }
            },
          ),
        ],
      ),
    );

    controller.dispose();
  }
}

/// The account of a reader who has none.
class _LocalOnly extends StatelessWidget {
  const _LocalOnly();

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Local only',
                style: type.uiBodyStrong.copyWith(color: tokens.palette.ink),
              ),
              const SizedBox(height: Space.xs),
              Text(
                'Your journal stays on this device. Add an account and it can follow you '
                'to another one.',
                style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        PaperButton(label: 'Add sync', onPressed: () => context.go('/sign-up')),
      ],
    );
  }
}

/// The account of a reader who has signed out.
class _SignedOut extends StatelessWidget {
  const _SignedOut({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Signed out',
                style: type.uiBodyStrong.copyWith(color: tokens.palette.ink),
              ),
              const SizedBox(height: Space.xs),
              Text(
                email == null
                    ? 'Your journal is still on this device.'
                    : 'Your journal is still on this device. Sign in with $email to '
                          'carry on where you left off.',
                style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        PaperButton(label: 'Sign in', onPressed: () => context.go('/sign-in')),
      ],
    );
  }
}

/// A line of the account, with the value it holds.
class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        child: Row(
          children: <Widget>[
            Text(label, style: type.label),
            const SizedBox(width: Space.md),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                textAlign: TextAlign.end,
                style: type.uiBody.copyWith(color: tokens.palette.ink),
              ),
            ),
            if (onTap != null) ...<Widget>[
              const SizedBox(width: Space.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: tokens.palette.inkFaint,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A line the reader can act on.
class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.sm),
        child: Text(
          label,
          style: type.uiBodyStrong.copyWith(
            color: destructive ? tokens.palette.seal : tokens.palette.ink,
          ),
        ),
      ),
    );
  }
}
