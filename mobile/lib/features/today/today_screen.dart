import 'package:aroel/core/account.dart';
import 'package:aroel/core/account_controller.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The home of the app.
///
/// The day record itself — the rating, the tags, the gratitude lines and the writing —
/// is milestone M2. What is here now is the shell the account stories sit in: the date,
/// the greeting, and where the journal lives.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final AccountSnapshot account = ref.watch(
      accountControllerProvider.select((AuthState auth) => auth.account),
    );
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      showBackButton: false,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: <Widget>[
          Text(
            DateFormat('EEEE d MMMM').format(DateTime.now()).toUpperCase(),
            style: type.label,
          ),
          const SizedBox(height: Space.xs),
          Text(
            onboarding.intent?.greeting ?? 'A place to put the day down.',
            style: type.display,
          ),
          const SizedBox(height: Space.lg),
          PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your journal is on this device.',
                  style: type.uiBodyStrong.copyWith(color: tokens.palette.ink),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  account.status == AccountStatus.signedIn
                      ? 'It is also in your account, so it can follow you to another '
                            'device.'
                      : 'Everything you write works this way. Add an account and it can '
                            'follow you to another device.',
                  style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
                ),
                const SizedBox(height: Space.md),
                PaperButton(
                  label: account.status == AccountStatus.signedIn ? 'Account' : 'Add sync',
                  variant: PaperButtonVariant.secondary,
                  onPressed: () => context.go('/settings/account'),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          PaperButton(
            label: 'Settings',
            variant: PaperButtonVariant.quiet,
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}
