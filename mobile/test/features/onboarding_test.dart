import 'package:aroel/app/app.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets(
    'the three steps are there, and every one of them can be left alone',
    (WidgetTester tester) async {
      final AccountHarness harness = AccountHarness(
        server: FakeServer((options) => <String, Object?>{}),
      );
      addTearDown(harness.close);

      await tester.pumpWidget(
        ProviderScope(overrides: harness.overrides(), child: const AroelApp()),
      );
      await tester.pumpAndSettle();

      // The first step asks why the reader is here.
      expect(find.text('What brings you here?'), findsOneWidget);
      expect(find.text('Understand myself'), findsOneWidget);
      expect(find.text('Slow down'), findsOneWidget);
      expect(find.text('Work through something'), findsOneWidget);
      expect(find.text('Build a habit'), findsOneWidget);

      await tester.tap(find.text('Slow down'));
      await tester.pumpAndSettle();

      expect(
        await harness.database.readPreference(PreferenceKeys.onboardingIntent),
        'slow_down',
      );

      // The second step plants the first rating.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('How was today?'), findsOneWidget);
      expect(find.text('bottom'), findsOneWidget);
      expect(find.text('good day'), findsOneWidget);

      // The third step invites an account, and says that "not now" is an answer.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Take your journal with you'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    },
  );

  testWidgets('the whole flow can be skipped', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides(), child: const AroelApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(
      await harness.database.readPreference(PreferenceKeys.onboardingCompleted),
      'true',
    );
    expect(find.text('What brings you here?'), findsNothing);
  });

  testWidgets('the first rating is planted where the day record will read it', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(overrides: harness.overrides(), child: const AroelApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final Finder track = find.byType(RatingTrack);
    expect(track, findsOneWidget);

    final Rect box = tester.getRect(track);
    await tester.tapAt(Offset(box.left + box.width * 0.85, box.center.dy));
    await tester.pumpAndSettle();

    expect(
      await harness.database.readPreference(
        PreferenceKeys.onboardingFirstRating,
      ),
      isNotNull,
    );
  });
}
