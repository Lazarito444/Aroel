import 'package:aroel/core/streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluating the streak', () {
    test('is one when a single day was kept', () {
      final StreakSnapshot snapshot = Streak.evaluate(kept: <String>['2026-11-17'], today: '2026-11-18');

      expect(snapshot.current, 1);
      expect(snapshot.longest, 1);
      expect(snapshot.graceRemaining, 1);
    });

    test('counts consecutive kept days', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-14', '2026-11-15', '2026-11-16', '2026-11-17', '2026-11-18'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 5);
      expect(snapshot.longest, 5);
    });

    test('one missed day spends the grace token and the streak continues', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-15', '2026-11-17'],
        today: '2026-11-17',
      );

      expect(snapshot.current, 2);
      expect(snapshot.longest, 2);
      // The one missed day was absorbed, so the token stands again after a kept day.
      expect(snapshot.graceRemaining, 1);
    });

    test('an unkept today does not spend the token', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-16', '2026-11-17'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 2);
      expect(snapshot.graceRemaining, 1);
    });

    test('two consecutive missed days break the streak', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-10', '2026-11-11'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 0);
      expect(snapshot.longest, 2);
    });

    test('one missed day ago is grace spent, streak alive', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-14', '2026-11-15', '2026-11-16'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 3);
      expect(snapshot.graceRemaining, 0);
    });

    test('two missed days ago breaks the streak', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-14', '2026-11-15'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 0);
    });

    test('a recovered day counts as kept', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-15', '2026-11-17', '2026-11-18'],
        restored: const <String>['2026-11-16'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 4);
      expect(snapshot.recoveredDates, <String>['2026-11-16']);
    });

    test('an empty history is a fresh streak with the token intact', () {
      final StreakSnapshot snapshot = Streak.evaluate(kept: const <String>[], today: '2026-11-18');

      expect(snapshot.current, 0);
      expect(snapshot.longest, 0);
      expect(snapshot.graceRemaining, 1);
      expect(snapshot.lastKeptDate, isNull);
    });

    test('the longest run survives a break', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-01', '2026-11-02', '2026-11-03', '2026-11-04'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 0);
      expect(snapshot.longest, 4);
    });

    test('a fresh streak starts with a fresh token', () {
      final StreakSnapshot snapshot = Streak.evaluate(
        kept: <String>['2026-11-01', '2026-11-02', '2026-11-17', '2026-11-18'],
        today: '2026-11-18',
      );

      expect(snapshot.current, 2);
      expect(snapshot.graceRemaining, 1);
      expect(snapshot.longest, 2);
    });
  });
}
