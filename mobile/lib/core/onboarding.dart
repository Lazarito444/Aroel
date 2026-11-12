import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.freezed.dart';

/// What brings the reader here (§5.2).
///
/// The answer sets the tone of the copy around the day record; it never changes what the
/// app does.
enum OnboardingIntent {
  /// To understand themselves.
  understandMyself,

  /// To slow down.
  slowDown,

  /// To work through something.
  workThroughSomething,

  /// To build a habit.
  buildAHabit,
}

/// The words that name an intent.
extension OnboardingIntentCopy on OnboardingIntent {
  /// The name of the intent.
  String get title => switch (this) {
    OnboardingIntent.understandMyself => 'Understand myself',
    OnboardingIntent.slowDown => 'Slow down',
    OnboardingIntent.workThroughSomething => 'Work through something',
    OnboardingIntent.buildAHabit => 'Build a habit',
  };

  /// The line that says what the intent is for.
  String get description => switch (this) {
    OnboardingIntent.understandMyself => 'Keep a record and see what your days have in common.',
    OnboardingIntent.slowDown => 'A few seconds at the end of the day instead of scrolling.',
    OnboardingIntent.workThroughSomething => 'Put the day down in words, one evening at a time.',
    OnboardingIntent.buildAHabit => 'A small ritual that is easy to keep.',
  };

  /// The line the app greets the reader with, once the intent is known.
  String get greeting => switch (this) {
    OnboardingIntent.understandMyself => 'Let us look back a little.',
    OnboardingIntent.slowDown => 'A moment, and then the day is written.',
    OnboardingIntent.workThroughSomething => 'Take your time with today.',
    OnboardingIntent.buildAHabit => 'One small thing a day.',
  };

  /// The wire name of the intent.
  String get wireName => switch (this) {
    OnboardingIntent.understandMyself => 'understand_myself',
    OnboardingIntent.slowDown => 'slow_down',
    OnboardingIntent.workThroughSomething => 'work_through_something',
    OnboardingIntent.buildAHabit => 'build_a_habit',
  };

  /// The intent a wire name stands for.
  static OnboardingIntent? fromWireName(String value) {
    for (final OnboardingIntent intent in OnboardingIntent.values) {
      if (intent.wireName == value) {
        return intent;
      }
    }
    return null;
  }
}

/// Where the reader is in the three steps of the onboarding.
@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    /// Whether the reader has been through the flow, or has skipped it.
    @Default(false) bool completed,

    /// What the reader said brings them here.
    OnboardingIntent? intent,

    /// The first rating that was planted, as a count of half points.
    int? firstRating,

    /// The step the reader is on, from zero to two.
    @Default(0) int step,
  }) = _OnboardingState;

  /// The steps of the flow.
  static const int stepCount = 3;
}

/// The onboarding of this device.
///
/// Every step can be left alone and the whole flow can be skipped; what is kept is the
/// answer to the intent and the first rating, so that the day record starts with a
/// direction (§5.2).
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => ref.watch(initialOnboardingProvider);

  PreferencesStore get _preferences => ref.read(preferencesStoreProvider);

  /// Records what brought the reader here.
  Future<void> chooseIntent(OnboardingIntent intent) async {
    state = state.copyWith(intent: intent);
    await _preferences.writePreference(
      PreferenceKeys.onboardingIntent,
      intent.wireName,
    );
  }

  /// Plants the first rating.
  Future<void> setFirstRating(int? halfSteps) async {
    state = state.copyWith(firstRating: halfSteps);
    if (halfSteps == null) {
      await _preferences.removePreference(PreferenceKeys.onboardingFirstRating);
      return;
    }
    await _preferences.writePreference(
      PreferenceKeys.onboardingFirstRating,
      halfSteps.toString(),
    );
  }

  /// Moves to another step.
  void goToStep(int step) {
    state = state.copyWith(step: step.clamp(0, OnboardingState.stepCount - 1));
  }

  /// Leaves the flow without an account, which is a complete answer.
  Future<void> skip() async {
    state = state.copyWith(completed: true);
    await _preferences.writePreference(
      PreferenceKeys.onboardingCompleted,
      'true',
    );
  }

  /// Finishes the flow.
  Future<void> complete() async {
    state = state.copyWith(completed: true);
    await _preferences.writePreference(
      PreferenceKeys.onboardingCompleted,
      'true',
    );
  }
}

/// The names of the preferences the onboarding keeps.
abstract final class PreferenceKeys {
  /// Whether the flow has been finished or skipped.
  static const String onboardingCompleted = 'onboarding.completed';

  /// What brought the reader here.
  static const String onboardingIntent = 'onboarding.intent';

  /// The first rating that was planted.
  static const String onboardingFirstRating = 'onboarding.first_rating';
}

/// The onboarding of this device.
final NotifierProvider<OnboardingController, OnboardingState> onboardingControllerProvider = NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

/// What the onboarding keeps on the device.
///
/// The port lives here so that the onboarding does not depend on how the device stores
/// what it remembers; the data layer implements it, and the app wires the two together.
abstract interface class PreferencesStore {
  /// Reads a preference.
  Future<String?> readPreference(String key);

  /// Writes a preference.
  Future<void> writePreference(String key, String value);

  /// Removes a preference.
  Future<void> removePreference(String key);
}

/// The preferences of this device.
final Provider<PreferencesStore> preferencesStoreProvider = Provider<PreferencesStore>(
  (Ref ref) => throw StateError(
    'The device store has to be wired before the app starts.',
  ),
);

/// The onboarding as it was read at launch.
final Provider<OnboardingState> initialOnboardingProvider = Provider<OnboardingState>(
  (Ref ref) => throw StateError(
    'The onboarding has to be read before the app starts.',
  ),
);
