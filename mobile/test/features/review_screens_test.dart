import 'package:aroel/app/app.dart';
import 'package:aroel/core/onboarding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/harness.dart';

void main() {
  testWidgets('insights teaches when there is nothing to show yet', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(onboarding: const OnboardingState(completed: true)),
        child: const AroelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);
    expect(find.textContaining('Rate a day, and the week starts here'), findsOneWidget);
  });

  testWidgets('a note can be created from the shelf and written', (WidgetTester tester) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);
    addTearDown(tester.view.resetPhysicalSize);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(onboarding: const OnboardingState(completed: true)),
        child: const AroelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing on the shelf yet'), findsOneWidget);

    await tester.tap(find.byTooltip('New note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(1), 'the honest paragraph');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(
      (await harness.noteRepository.list()).single.body,
      'the honest paragraph',
    );
  });
}
