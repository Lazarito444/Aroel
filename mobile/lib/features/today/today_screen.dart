import 'package:aroel/core/account.dart';
import 'package:aroel/core/account_controller.dart';
import 'package:aroel/core/day.dart';
import 'package:aroel/core/day_controller.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/core/streak.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/gratitude_card.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/paper_sheet.dart';
import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:aroel/ui/widgets/tag_picker.dart';
import 'package:aroel/ui/widgets/tone_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The home of the app (§5.3).
///
/// Everything here works offline from the device's own store. The rating is the hero;
/// writing is one tap away and never a gate.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final DayState day = ref.watch(dayControllerProvider);
    final AccountSnapshot account = ref.watch(
      accountControllerProvider.select((AuthState auth) => auth.account),
    );
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DayController controller = ref.read(dayControllerProvider.notifier);

    return PaperScaffold(
      showBackButton: false,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(Space.lg),
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  DateFormat('EEEE d MMMM').format(DateTime.now()).toUpperCase(),
                  style: type.label,
                ),
              ),
              _StreakChip(streak: day.streak),
            ],
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
                Text('RATE TODAY', style: type.label),
                const SizedBox(height: Space.md),
                RatingTrack(
                  value: day.record.ratingHalf,
                  onChanged: (int? value) => controller.setRating(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          TagPicker(
            selected: day.record.tags,
            recentTags: day.recentTags,
            onToggle: controller.toggleTag,
            onCreateAndToggle: controller.createTagAndToggle,
            onSearch: controller.searchTags,
          ),
          const SizedBox(height: Space.xs),
          TonePicker(
            sentimentHalf: day.record.sentimentHalf,
            onChanged: controller.setSentiment,
          ),
          const SizedBox(height: Space.xs),
          GratitudeCard(
            lines: day.record.gratitude,
            onChanged: (int position, String text) => ref.read(dayControllerProvider.notifier).setGratitude(position, text),
          ),
          const SizedBox(height: Space.md),
          PaperCard(
            onTap: () => context.go('/write'),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Write',
                        style: type.uiBodyStrong.copyWith(color: tokens.palette.ink),
                      ),
                      const SizedBox(height: Space.xxs),
                      Text(
                        day.record.wordCount > 0 ? '${day.record.wordCount} words so far today.' : 'The day you write in is the day you wrote in, even at 00:30.',
                        style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_outlined, size: 20, color: tokens.palette.accent),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          Row(
            children: <Widget>[
              Expanded(
                child: PaperButton(
                  label: 'Notes',
                  variant: PaperButtonVariant.secondary,
                  onPressed: () => context.go('/notes'),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: PaperButton(
                  label: 'Insights',
                  variant: PaperButtonVariant.secondary,
                  onPressed: () => context.go('/insights'),
                ),
              ),
            ],
          ),
          if (day.recentEntries.isNotEmpty) ...<Widget>[
            const SizedBox(height: Space.lg),
            Text('RECENT', style: type.label),
            const SizedBox(height: Space.xs),
            for (final RecentEntry entry in day.recentEntries)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Text(
                  entry.snippet,
                  style: type.prose.copyWith(color: tokens.palette.inkSoft),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          const SizedBox(height: Space.lg),
          PaperButton(
            label: account.status == AccountStatus.signedIn ? 'Account' : 'Add sync',
            variant: PaperButtonVariant.secondary,
            onPressed: () => context.go('/settings/account'),
          ),
          const SizedBox(height: Space.xs),
          PaperButton(
            label: 'Settings',
            variant: PaperButtonVariant.quiet,
            onPressed: () => context.go('/settings'),
          ),
          if (day.errorMessage != null) ...<Widget>[
            const SizedBox(height: Space.sm),
            Text(
              day.errorMessage!,
              style: type.uiBody.copyWith(color: tokens.palette.seal),
            ),
          ],
        ],
      ),
    );
  }
}

/// The streak chip: the count, whether a grace token stands, and the way to recover
/// a missed day (§2.3). Never with guilt copy.
class _StreakChip extends ConsumerWidget {
  const _StreakChip({required this.streak});

  final StreakSnapshot streak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final int current = streak.current;

    return GestureDetector(
      onTap: () => _showRecoverySheet(context, ref),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.palette.paperSunk,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: tokens.palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: streak.graceRemaining > 0 ? tokens.palette.sage : tokens.palette.inkFaint,
                ),
              ),
              const SizedBox(width: Space.xs),
              Text(
                current == 0 ? 'Start today' : '$current in a row',
                style: type.label.copyWith(color: tokens.palette.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRecoverySheet(BuildContext context, WidgetRef ref) async {
    final List<String> days = await ref.read(dayControllerProvider.notifier).recoverableDays();

    if (!context.mounted) {
      return;
    }

    await showPaperSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        final PaperType sheetType = PaperType.of(sheetContext);
        final PaperTokens sheetTokens = PaperTokens.of(sheetContext);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const PaperSheetTitle(
              'Mark a day as kept',
              subtitle: 'A missed day can always be recovered. No streak is lost to a bad week.',
            ),
            const SizedBox(height: Space.md),
            if (days.isEmpty)
              Text(
                'Every recent day is already kept.',
                style: sheetType.uiBody.copyWith(color: sheetTokens.palette.inkSoft),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final String day in days)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          DateFormat('EEEE d MMMM').format(DateTime.parse(day)),
                          style: sheetType.uiBody.copyWith(color: sheetTokens.palette.ink),
                        ),
                        trailing: Text(
                          'Mark as kept',
                          style: sheetType.uiBodyStrong.copyWith(color: sheetTokens.palette.accent),
                        ),
                        onTap: () async {
                          await ref.read(dayControllerProvider.notifier).recoverDay(day);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
