import 'package:aroel/features/auth/delete/delete_account_screen.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/harness.dart';

void main() {
  testWidgets(
    'the first step says what happens on the device and on the server',
    (WidgetTester tester) async {
      final AccountHarness harness = AccountHarness(
        server: FakeServer((options) => <String, Object?>{}),
      );
      addTearDown(harness.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides(),
          child: const MaterialApp(home: DeleteAccountScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Everything goes'), findsOneWidget);
      expect(find.text('Everything is wiped now.'), findsOneWidget);
      expect(find.text('The copy is wiped within 24 hours.'), findsOneWidget);
      expect(find.text('One last thing'), findsNothing);
    },
  );

  testWidgets('nothing is deleted until the word is typed', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(),
        child: const MaterialApp(home: DeleteAccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('One last thing'), findsOneWidget);
    expect(find.byType(PaperTextField), findsOneWidget);

    PaperButton button = tester.widget(
      find.widgetWithText(PaperButton, 'Delete everything'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(PaperTextField), 'not yet');
    await tester.pumpAndSettle();

    button = tester.widget(
      find.widgetWithText(PaperButton, 'Delete everything'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(PaperTextField), 'delete');
    await tester.pumpAndSettle();

    button = tester.widget(
      find.widgetWithText(PaperButton, 'Delete everything'),
    );
    expect(button.onPressed, isNotNull);
  });
}
