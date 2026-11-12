import 'package:aroel/core/account.dart';
import 'package:aroel/features/auth/account/account_screen.dart';
import 'package:aroel/ui/widgets/paper_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets(
    'without an account the screen says local only and offers to add sync',
    (WidgetTester tester) async {
      final AccountHarness harness = AccountHarness(
        server: FakeServer((options) => <String, Object?>{}),
      );
      addTearDown(harness.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides(),
          child: const MaterialApp(home: AccountScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Local only'), findsOneWidget);
      expect(find.text('Add sync'), findsOneWidget);

      // Nothing is greyed out for want of an account.
      final PaperButton add = tester.widget(
        find.widgetWithText(PaperButton, 'Add sync'),
      );
      expect(add.onPressed, isNotNull);
    },
  );

  testWidgets('with an account the screen shows the address and the ways out', (
    WidgetTester tester,
  ) async {
    final AccountHarness harness = AccountHarness(
      server: FakeServer((options) => <String, Object?>{}),
    );
    addTearDown(harness.close);

    const AccountSnapshot account = AccountSnapshot(
      status: AccountStatus.signedIn,
      localUserId: '0192f3a4-5b6c-7d8e-9f0a-000000000001',
      accountUserId: '0192f3a4-5b6c-7d8e-9f0a-000000000001',
      email: 'ada@example.com',
      displayName: 'ada',
      timeZone: 'Europe/Madrid',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides(account: account),
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ada@example.com'), findsWidgets);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Europe/Madrid'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets(
    'an unconfirmed address is said out loud, and nothing else changes',
    (WidgetTester tester) async {
      final AccountHarness harness = AccountHarness(
        server: FakeServer((options) => <String, Object?>{}),
      );
      addTearDown(harness.close);

      const AccountSnapshot account = AccountSnapshot(
        status: AccountStatus.signedIn,
        localUserId: '0192f3a4-5b6c-7d8e-9f0a-000000000001',
        accountUserId: '0192f3a4-5b6c-7d8e-9f0a-000000000001',
        email: 'ada@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides(account: account),
          child: const MaterialApp(home: AccountScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('One step left'), findsOneWidget);
      expect(find.text('Send the email again'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    },
  );
}
