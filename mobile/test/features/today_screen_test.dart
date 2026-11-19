import 'package:aroel/app/app.dart';
import 'package:aroel/core/day.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:aroel/data/repositories/day_repository.dart';
import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/harness.dart';

String _today() => DayRepository.formatLocalDate(DateTime.now());

void main() {
  testWidgets('tapping a stop rates the day and keeps it', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(onboarding: const OnboardingState(completed: true)),
        child: const AroelApp(),
      ),
    );
    await tester.pumpAndSettle();

    final Rect box = tester.getRect(find.byType(RatingTrack));
    await tester.tapAt(Offset(box.right - 12, box.center.dy));
    await tester.pumpAndSettle();

    final DayRecord record = await harness.dayRepository.read(_today());
    expect(record.ratingHalf, 10);
  });

  testWidgets('a filled gratitude line is kept after the debounce', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(onboarding: const OnboardingState(completed: true)),
        child: const AroelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'a cup of tea');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    final DayRecord record = await harness.dayRepository.read(_today());
    expect(record.gratitude[0], 'a cup of tea');
  });

  testWidgets('the streak chip shows the day as kept after a rating', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(onboarding: const OnboardingState(completed: true)),
        child: const AroelApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start today'), findsOneWidget);

    final Rect box = tester.getRect(find.byType(RatingTrack));
    await tester.tapAt(Offset(box.right - 12, box.center.dy));
    await tester.pumpAndSettle();

    expect(find.text('1 in a row'), findsOneWidget);
  });
}
