import 'package:aroel/core/onboarding.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:aroel/ui/widgets/paper_option.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The three steps of the onboarding (§5.2).
///
/// Every step can be left alone, and the whole flow can be skipped: no account is asked
/// for until the reader asks for one.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController controller = ref.read(
      onboardingControllerProvider.notifier,
    );

    return PaperScaffold(
      showBackButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Progress(step: state.step, controller: controller),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Space.lg,
                Space.sm,
                Space.lg,
                Space.lg,
              ),
              child: switch (state.step) {
                0 => _IntentStep(state: state, controller: controller),
                1 => _RatingStep(state: state, controller: controller),
                _ => _SyncStep(controller: controller),
              },
            ),
          ),
          _Actions(step: state.step, controller: controller),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.controller});

  final int step;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.lg,
        Space.lg,
        Space.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'STEP ${step + 1} OF ${OnboardingState.stepCount}',
                style: type.label,
              ),
              TextButton(
                onPressed: () {
                  controller.skip();
                  context.go('/');
                },
                style: TextButton.styleFrom(
                  foregroundColor: tokens.palette.inkSoft,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Skip',
                  style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Row(
            children: List<Widget>.generate(
              OnboardingState.stepCount,
              (int index) => Expanded(
                child: Container(
                  height: 2,
                  margin: EdgeInsets.only(
                    right: index == OnboardingState.stepCount - 1 ? 0 : Space.xs,
                  ),
                  color: index <= step ? tokens.palette.accent : tokens.palette.border,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntentStep extends StatelessWidget {
  const _IntentStep({required this.state, required this.controller});

  final OnboardingState state;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final PaperType type = PaperType.of(context);
    final PaperTokens tokens = PaperTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('What brings you here?', style: type.display),
        const SizedBox(height: Space.xs),
        Text(
          'It only sets the tone of the words around your day.',
          style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
        ),
        const SizedBox(height: Space.lg),
        ...OnboardingIntent.values.map(
          (OnboardingIntent intent) => Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: PaperOption(
              title: intent.title,
              description: intent.description,
              selected: state.intent == intent,
              onTap: () => controller.chooseIntent(intent),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingStep extends StatelessWidget {
  const _RatingStep({required this.state, required this.controller});

  final OnboardingState state;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final PaperType type = PaperType.of(context);
    final PaperTokens tokens = PaperTokens.of(context);
    final int? rating = state.firstRating;
    final String anchor = rating == null ? 'Eleven stops, from a day you would rather not repeat to one of the good ones.' : RatingStop.at(rating).anchor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('How was today?', style: type.display),
        const SizedBox(height: Space.xs),
        Text(
          'One tap sets the rating. A second tap on the same stop clears it.',
          style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
        ),
        const SizedBox(height: Space.xl),
        RatingTrack(
          value: rating,
          onChanged: (int? value) => controller.setFirstRating(value),
        ),
        const SizedBox(height: Space.md),
        Text(anchor, style: type.prose.copyWith(color: tokens.palette.inkSoft)),
      ],
    );
  }
}

class _SyncStep extends StatelessWidget {
  const _SyncStep({required this.controller});

  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final PaperType type = PaperType.of(context);
    final PaperTokens tokens = PaperTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Take your journal with you', style: type.display),
        const SizedBox(height: Space.xs),
        Text(
          'An account carries your journal to a second device. Nothing else changes: '
          'writing, rating and the streak work exactly as they do now.',
          style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
        ),
        const SizedBox(height: Space.lg),
        PaperCard(
          child: Text(
            'You can do this later, in Settings. Not now is a complete answer.',
            style: type.prose.copyWith(color: tokens.palette.inkSoft),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.step, required this.controller});

  final int step;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final bool isLast = step == OnboardingState.stepCount - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.lg,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: PaperTokens.of(context).palette.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!isLast)
            PaperButton(
              label: 'Continue',
              onPressed: () => controller.goToStep(step + 1),
            ),
          if (isLast) ...<Widget>[
            PaperButton(
              label: 'Create an account',
              onPressed: () {
                controller.complete();
                context.go('/sign-up');
              },
            ),
            const SizedBox(height: Space.xs),
            PaperButton(
              label: 'Not now',
              variant: PaperButtonVariant.quiet,
              onPressed: () {
                controller.complete();
                context.go('/');
              },
            ),
          ],
          if (!isLast) ...<Widget>[
            const SizedBox(height: Space.xs),
            PaperButton(
              label: 'Not now',
              variant: PaperButtonVariant.quiet,
              onPressed: () {
                controller.complete();
                context.go('/');
              },
            ),
          ],
        ],
      ),
    );
  }
}
