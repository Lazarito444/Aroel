import 'package:aroel/features/auth/signin/sign_in_screen.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('the providers sit above the email disclosure', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('or use email'), findsOneWidget);

    final double apple = tester.getTopLeft(find.text('Continue with Apple')).dy;
    final double google = tester.getTopLeft(find.text('Continue with Google')).dy;
    final double disclosure = tester.getTopLeft(find.text('or use email')).dy;

    expect(apple, lessThan(disclosure));
    expect(google, lessThan(disclosure));
  });

  testWidgets('the email form is behind the disclosure', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaperTextField), findsNothing);

    await tester.tap(find.text('or use email'));
    await tester.pumpAndSettle();

    expect(find.byType(PaperTextField), findsNWidgets(2));
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('nothing in the screen asks for an account', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(),
        child: const MaterialApp(home: SignInScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nothing here is required to write'),
      findsOneWidget,
    );
  });

  testWidgets('a password that is too short never leaves the device', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(),
        child: const MaterialApp(home: SignInScreen(mode: AuthMode.signUp)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('or use email'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(PaperTextField).first,
      'ada@example.com',
    );
    await tester.enterText(find.byType(PaperTextField).last, 'short');
    await tester.tap(find.widgetWithText(PaperButton, 'Create an account'));
    await tester.pumpAndSettle();

    expect(harness.server.requests, isEmpty);
    expect(find.textContaining('eight characters'), findsWidgets);
  });
}
