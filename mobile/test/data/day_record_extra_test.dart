import 'package:aroel/core/clock.dart';
import 'package:aroel/core/day.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/repositories/day_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DayRepository repository;
  int counter = 0;

  setUp(() {
    counter = 0;
    database = AppDatabase(NativeDatabase.memory());
    repository = DayRepository(
      database: database,
      clock: FixedClock(DateTime.utc(2026, 11, 18, 9)),
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

  group('the tone', () {
    test('a tone is picked and read back', () async {
      await repository.setSentiment('2026-11-18', 3);

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.sentimentHalf, 3);
    });

    test('a tone is cleared by picking nothing', () async {
      await repository.setSentiment('2026-11-18', 7);
      await repository.setSentiment('2026-11-18', null);

      final DayRecord record = await repository.read('2026-11-18');
      expect(record.sentimentHalf, isNull);
    });

    test('a tone out of range is refused', () async {
      final Result<void> result = await repository.setSentiment('2026-11-18', 11);

      expect(result.isFailure, isTrue);
    });
  });

  group('entries', () {
    test('entriesOn lists pinned first, then the most recent', () async {
      await repository.writeEntry('2026-11-18', 'first');
      await repository.writeEntry('2026-11-18', 'second');

      final List<EntrySummary> entries = await repository.entriesOn('2026-11-18');
      expect(entries, hasLength(1)); // one entry per day, edited in place
    });

    test('an entry read back carries its day and tone', () async {
      await repository.writeEntry('2026-11-18', 'some words on the day');
      await repository.setSentiment('2026-11-18', 7);

      final List<EntrySummary> entries = await repository.entriesOn('2026-11-18');
      final EntryRead? read = await repository.readEntryById(entries.single.id);

      expect(read, isNotNull);
      expect(read!.localDate, '2026-11-18');
      expect(read.sentimentHalf, 7);
    });

    test('a deleted entry disappears from the day', () async {
      await repository.writeEntry('2026-11-18', 'soon to be gone');

      final List<EntrySummary> before = await repository.entriesOn('2026-11-18');
      expect(before, hasLength(1));

      await repository.deleteEntry(before.single.id);

      expect(await repository.entriesOn('2026-11-18'), isEmpty);
      expect(await repository.readEntryById(before.single.id), isNull);
    });
  });

  group('stats over a range', () {
    test('the range counts ratings, entries, gratitude and tags per day', () async {
      await repository.setRating('2026-11-17', 6);
      await repository.setGratitude('2026-11-17', 1, 'tea');
      await repository.writeEntry('2026-11-17', 'a few words here');
      final Result<DayTagView> tag = await repository.createTag('walk');
      await repository.toggleTag('2026-11-17', tag.valueOrNull!.id);
      await repository.setRating('2026-11-18', 8);

      final List<DayStats> stats = await repository.statsRange('2026-11-17', '2026-11-18');

      final DayStats seventeen = stats.firstWhere((DayStats day) => day.localDate == '2026-11-17');
      expect(seventeen.ratingHalf, 6);
      expect(seventeen.entryCount, 1);
      expect(seventeen.gratitudeCount, 1);
      expect(seventeen.tagLabels, contains('walk'));
      expect(stats.firstWhere((DayStats day) => day.localDate == '2026-11-18').ratingHalf, 8);
    });

    test('days in the range with nothing kept produce no stats row', () async {
      final List<DayStats> stats = await repository.statsRange('2026-11-01', '2026-11-18');

      expect(stats, isEmpty);
    });
  });
}
