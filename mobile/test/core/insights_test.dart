import 'package:aroel/core/day.dart';
import 'package:aroel/core/insights.dart';
import 'package:flutter_test/flutter_test.dart';

DayStats _day(String date, {int? rating, int entries = 0, int gratitude = 0, List<String> tags = const <String>[], int? tone}) => DayStats(
  localDate: date,
  ratingHalf: rating,
  entryCount: entries,
  wordCount: entries * 10,
  gratitudeCount: gratitude,
  tagLabels: tags,
  sentimentHalf: tone,
);

void main() {
  group('weekly', () {
    test('the average runs over rated days only', () {
      final WindowStat stat = Insights.weekly(
        <DayStats>[_day('2026-11-17', rating: 6), _day('2026-11-18')],
        const <DayStats>[],
      );

      expect(stat.average, 3.0);
      expect(stat.daysRated, 1);
    });

    test('direction compares against the previous window', () {
      final WindowStat stat = Insights.weekly(
        <DayStats>[_day('2026-11-12', rating: 8), _day('2026-11-13', rating: 8)],
        <DayStats>[_day('2026-11-05', rating: 4), _day('2026-11-06', rating: 4)],
      );

      expect(stat.average, 4.0);
      expect(stat.direction, 2.0);
    });

    test('direction is null when either window has no rated day', () {
      final WindowStat stat = Insights.weekly(
        <DayStats>[_day('2026-11-17')],
        const <DayStats>[],
      );

      expect(stat.direction, isNull);
    });

    test('the best day breaks ties toward the most recent', () {
      final WindowStat stat = Insights.weekly(
        <DayStats>[_day('2026-11-15', rating: 8), _day('2026-11-17', rating: 8)],
        const <DayStats>[],
      );

      expect(stat.bestDay!.localDate, '2026-11-17');
    });

    test('top tags are counted and ordered by use', () {
      final WindowStat stat = Insights.weekly(
        <DayStats>[
          _day('2026-11-15', rating: 4, tags: const <String>['work', 'family']),
          _day('2026-11-16', rating: 6, tags: const <String>['work']),
          _day('2026-11-17', rating: 8, tags: const <String>['work', 'family', 'outside']),
        ],
        const <DayStats>[],
      );

      expect(stat.topTags.first.key, 'work');
      expect(stat.topTags.first.value, 3);
      expect(stat.topTags[1].key, 'family');
    });

    test('an empty window answers with empty values, not zeros', () {
      final WindowStat stat = Insights.weekly(const <DayStats>[], const <DayStats>[]);

      expect(stat.average, isNull);
      expect(stat.daysRated, 0);
      expect(stat.entriesWritten, 0);
      expect(stat.topTags, isEmpty);
    });
  });

  group('monthly grid', () {
    test('November 2026 starts on a Sunday and has a leading pad of six', () {
      // 2026-11-01 is a Sunday.
      final MonthGrid grid = Insights.monthGrid(
        '2026-11',
        List<DayStats>.generate(30, (int index) => _day('2026-11-${(index + 1).toString().padLeft(2, '0')}', rating: (index % 10) + 1)),
      );

      expect(grid.weeks.first.take(6).every((DayStats? cell) => cell == null), isTrue);
      expect(grid.weeks.first.last!.localDate, '2026-11-01');
      expect(grid.weeks.expand((List<DayStats?> week) => week).where((DayStats? cell) => cell == null).length, 12);
      expect(grid.weeks.length, 6);
    });

    test('cells carry the rating of their day', () {
      final MonthGrid grid = Insights.monthGrid(
        '2026-11',
        <DayStats>[_day('2026-11-04', rating: 7)],
      );

      final DayStats cell = grid.weeks.expand((List<DayStats?> week) => week).whereType<DayStats>().firstWhere((DayStats day) => day.localDate == '2026-11-04');
      expect(cell.ratingHalf, 7);
    });
  });

  group('weeks of a month', () {
    test('a 30-day month splits into five buckets', () {
      final List<WeekBucket> buckets = Insights.weeksOf('2026-11', const <DayStats>[]);

      expect(buckets, hasLength(5));
      expect(buckets.first.start, '2026-11-01');
      expect(buckets.last.end, '2026-11-30');
    });
  });
}
