import 'package:aroel/core/account.dart';
import 'package:aroel/core/account_controller.dart';
import 'package:aroel/core/day_controller.dart';
import 'package:aroel/features/settings/theme_controller.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The settings of the app (§5.9).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(accountControllerProvider);
    final AccountSnapshot account = auth.account;
    final ThemeMode mode = ref.watch(themeModeProvider);
    final DayState day = ref.watch(dayControllerProvider);
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Settings',
      child: ListView(
        children: <Widget>[
          Text('ACCOUNT', style: type.label),
          const SizedBox(height: Space.xs),
          PaperCard(
            padding: EdgeInsets.zero,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.go('/settings/account'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.md,
                  vertical: Space.md,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            account.status == AccountStatus.signedIn ? (account.email ?? '') : 'Local only',
                            style: type.uiBodyStrong.copyWith(
                              color: tokens.palette.ink,
                            ),
                          ),
                          const SizedBox(height: Space.xxs),
                          Text(
                            account.status == AccountStatus.signedIn ? 'Your account and your journal' : 'Add an account and your journal can follow you',
                            style: type.uiBody.copyWith(
                              color: tokens.palette.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: tokens.palette.inkFaint,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text('STREAK', style: type.label),
          const SizedBox(height: Space.xs),
          PaperCard(
            child: Row(
              children: <Widget>[
                _StreakFigure(label: 'CURRENT', value: '${day.streak.current}'),
                _StreakFigure(label: 'LONGEST', value: '${day.streak.longest}'),
                _StreakFigure(label: 'RECOVERED', value: '${day.streak.recoveredDates.length}'),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          Text('APPEARANCE', style: type.label),
          const SizedBox(height: Space.xs),
          Row(
            children: <Widget>[
              _Appearance(
                label: 'Light',
                selected: mode == ThemeMode.light,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
              ),
              const SizedBox(width: Space.xs),
              _Appearance(
                label: 'Dark',
                selected: mode == ThemeMode.dark,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
              ),
              const SizedBox(width: Space.xs),
              _Appearance(
                label: 'System',
                selected: mode == ThemeMode.system,
                onTap: () => ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          Text('ABOUT', style: type.label),
          const SizedBox(height: Space.xs),
          Text(
            'Aroel is a quiet journal that keeps a record of your days.',
            style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// One of the three streak numbers. Never with guilt copy: a streak is a record
/// of showing up, not a debt.
class _StreakFigure extends StatelessWidget {
  const _StreakFigure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Expanded(
      child: Column(
        children: <Widget>[
          Text(label, style: type.label),
          Text(value, style: type.pageTitle.copyWith(color: tokens.palette.ink)),
        ],
      ),
    );
  }
}

/// One of the appearances the app offers.
class _Appearance extends StatelessWidget {
  const _Appearance({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? tokens.palette.paperSunk : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: selected ? tokens.palette.accent : tokens.palette.border,
          ),
        ),
        child: Text(
          label,
          style: type.uiBody.copyWith(
            color: selected ? tokens.palette.ink : tokens.palette.inkSoft,
          ),
        ),
      ),
    );
  }
}
