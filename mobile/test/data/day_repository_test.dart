import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/day.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/core/streak.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/repositories/day_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clock that moves one minute on every reading, so rows written in a burst get
/// distinct timestamps.
final class MutableClock implements Clock {
  MutableClock(this._now);

  DateTime _now;

  @override
  DateTime nowUtc() {
    final DateTime moment = _now;
    _now = _now.add(const Duration(minutes: 1));
    return moment;
  }
}

void main() {
  late AppDatabase database;
  late DayRepository repository;
  int counter = 0;

  setUp(() {
    counter = 0;
    database = AppDatabase(NativeDatabase.memory());
    repository = DayRepository(
      database: database,
      clock: MutableClock(DateTime.utc(2026, 11, 18, 9)),
      newId: () {
        counter++;
        final String tail = counter.toRadixString(16).padLeft(12, '0');
        return '0192f3a4-5b6c-7d8e-9f0a-$tail';
      },
      deviceTimeZone: 'Europe/Madrid',
      deviceLocale: 'en-GB',
      localNow: () => DateTime(2026, 11, 18, 21),
    );
  });

  tearDown(() => database.close());

  group('the rating', () {
    test('a rating is set and read back', () async {
      await repository.setRating('2026-11-18', 7);

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.ratingHalf, 7);
    });

    test('a rating of zero is a real score, not absence', () async {
      await repository.setRating('2026-11-18', 0);

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.ratingHalf, 0);
    });

    test('a second tap on the same value clears the rating', () async {
      await repository.setRating('2026-11-18', 7);
      await repository.setRating('2026-11-18', null);

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.ratingHalf, isNull);
    });

    test('a rating out of range is refused', () async {
      final Result<void> result = await repository.setRating('2026-11-18', 11);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, DayErrorCodes.invalidRating);
    });
  });

  group('gratitude', () {
    test('a line is written and read back in its position', () async {
      await repository.setGratitude('2026-11-18', 2, 'coffee with a friend');

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.gratitude, <String>['', 'coffee with a friend', '']);
    });

    test('a line is edited by writing it again', () async {
      await repository.setGratitude('2026-11-18', 1, 'a quiet morning');
      await repository.setGratitude('2026-11-18', 1, 'a slow morning');

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.gratitude[0], 'a slow morning');
    });

    test('a position out of 1..3 is refused', () async {
      final Result<void> result = await repository.setGratitude('2026-11-18', 4, 'no');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, DayErrorCodes.invalidGratitudePosition);
    });
  });

  group('tags', () {
    test('five tags are the limit on a day', () async {
      for (int index = 1; index <= 5; index++) {
        final Result<DayTagView> created = await repository.createTag('tag$index');
        expect(created.isSuccess, isTrue);
        await repository.toggleTag('2026-11-18', created.valueOrNull!.id);
      }

      final Result<DayTagView> sixth = await repository.createTag('tag6');
      final Result<void> result = await repository.toggleTag('2026-11-18', sixth.valueOrNull!.id);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, DayErrorCodes.tooManyTags);
    });

    test('a tag toggles off again', () async {
      final Result<DayTagView> created = await repository.createTag('walk');
      await repository.toggleTag('2026-11-18', created.valueOrNull!.id);
      await repository.toggleTag('2026-11-18', created.valueOrNull!.id);

      final List<DayTagView> tags = await repository.tagsOn('2026-11-18');
      expect(tags, isEmpty);
    });

    test('recent tags are the five most recently used', () async {
      for (final String label in <String>['a', 'b', 'c', 'd', 'e']) {
        final Result<DayTagView> created = await repository.createTag(label);
        await repository.toggleTag('2026-11-18', created.valueOrNull!.id);
      }
      // The sixth tag goes on an earlier day, after the o'clock session, so it is the
      // most recent use of a tag without breaching the five-tag limit on one day.
      final Result<DayTagView> sixth = await repository.createTag('f');
      await repository.toggleTag('2026-11-17', sixth.valueOrNull!.id);

      final List<DayTagView> recent = await repository.recentTags();
      expect(recent, hasLength(5));
      expect(recent.first.label, 'f');
    });
  });

  group('writing', () {
    test('an entry is written and read back with a word count', () async {
      await repository.writeEntry('2026-11-18', 'a slow morning. a good one.');

      final DayEntry? entry = await repository.readEntry('2026-11-18');
      expect(entry, isNotNull);
      expect(entry!.wordCount, 6);
    });

    test('writing again edits the same entry, not a new one', () async {
      await repository.writeEntry('2026-11-18', 'first draft');
      await repository.writeEntry('2026-11-18', 'second draft');

      final DayEntry? entry = await repository.readEntry('2026-11-18');
      expect(entry!.body, 'second draft');
      expect(entry.wordCount, 2);
    });
  });

  group('the streak', () {
    test('a rating keeps the day', () async {
      await repository.setRating('2026-11-18', 8);

      final StreakSnapshot snapshot = await repository.streak();
      expect(snapshot.current, 1);
      expect(snapshot.lastKeptDate, '2026-11-18');
    });

    test('a gratitude line keeps the day', () async {
      await repository.setGratitude('2026-11-18', 1, 'tea');

      final StreakSnapshot snapshot = await repository.streak();
      expect(snapshot.current, 1);
    });

    test('an untagged, unrated day does not keep the day', () async {
      await repository.read('2026-11-18');

      final StreakSnapshot snapshot = await repository.streak();
      expect(snapshot.current, 0);
      expect(snapshot.lastKeptDate, isNull);
    });

    test('a restored day counts toward the streak', () async {
      await repository.setRating('2026-11-17', 5);
      await repository.recoverDay('2026-11-16');

      final StreakSnapshot snapshot = await repository.streak();
      expect(snapshot.current, 2);
      expect(snapshot.recoveredDates, <String>['2026-11-16']);
    });

    test('recoverable days are missed days only', () async {
      await repository.setRating('2026-11-17', 5);

      final List<String> days = await repository.recoverableDays(limit: 5);
      expect(days, isNot(contains('2026-11-17')));
      expect(days.length, 5);
      expect(days.first, '2026-11-16');
    });
  });

  group('recent entries', () {
    test('the two most recent entries are listed with a snippet', () async {
      await repository.writeEntry('2026-11-17', 'older entry with some words');
      await repository.writeEntry('2026-11-18', 'newer entry with some words');

      final List<RecentEntry> recent = await repository.recentEntries();
      expect(recent, hasLength(2));
      expect(recent.first.snippet, 'newer entry with some words');
      expect(recent.last.snippet, 'older entry with some words');
    });
  });
}
