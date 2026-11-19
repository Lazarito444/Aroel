import 'package:aroel/core/day.dart';

/// The numbers of one window (§5.8). Every figure is arithmetic over local rows; none of
/// it is written by a model.
class WindowStat {
  /// Creates a snapshot of a window.
  const WindowStat({
    required this.daysRated,
    required this.entriesWritten,
    required this.gratitudeLines,
    required this.topTags,
    this.average,
    this.direction,
    this.sentimentAverage,
    this.bestDay,
    this.highestSentimentDay,
  });

  /// The days that were rated in the window.
  final int daysRated;

  /// The average rating of the rated days, in points (0..5), `null` when none were rated.
  final double? average;

  /// The movement against the previous window of the same length, in points, `null` when
  /// either window has an empty rating pool.
  final double? direction;

  /// The entries written in the window.
  final int entriesWritten;

  /// The gratitude lines filled in the window.
  final int gratitudeLines;

  /// The most used tags, most used first, then alphabetical.
  final List<MapEntry<String, int>> topTags;

  /// The average tone of the window, in points, `null` when none was picked.
  final double? sentimentAverage;

  /// The best rated day of the window; ties go to the most recent.
  final DayStats? bestDay;

  /// The day with the highest tone of the window; ties go to the most recent.
  final DayStats? highestSentimentDay;
}

/// The monthly grid: the weeks of one calendar month, Monday first (§6.6).
class MonthGrid {
  /// Creates a grid.
  const MonthGrid({required this.weeks, required this.month});

  /// Seven cells per week; `null` pads the first and the last week.
  final List<List<DayStats?>> weeks;

  /// The month the grid belongs to, `YYYY-MM`.
  final String month;
}

/// The per-week breakdown inside a month (§5.8).
class WeekBucket {
  /// Creates a bucket.
  const WeekBucket({
    required this.start,
    required this.end,
    required this.daysRated,
    required this.entriesWritten,
    required this.gratitudeLines,
    this.average,
  });

  /// The first day of the bucket, `YYYY-MM-DD`.
  final String start;

  /// The last day of the bucket, `YYYY-MM-DD`.
  final String end;

  /// The days that were rated in the bucket.
  final int daysRated;

  /// The average rating of the rated days, in points, `null` when none were rated.
  final double? average;

  /// The entries written in the bucket.
  final int entriesWritten;

  /// The gratitude lines filled in the bucket.
  final int gratitudeLines;
}

/// The arithmetic of the review screens (§5.8).
///
/// Rating averages run over rated days only; absence is never folded in as a zero.
/// Ties go to the most recent day. Everything is local, offline and never scolding.
abstract final class Insights {
  /// The weekly review of [current], with [previous] as the comparison window.
  static WindowStat weekly(
    List<DayStats> current,
    List<DayStats> previous, {
    int tagLimit = 3,
  }) {
    final double? currentAverage = _averageRating(current);
    final double? previousAverage = _averageRating(previous);

    return WindowStat(
      daysRated: _rated(current).length,
      entriesWritten: current.fold(0, (int sum, DayStats day) => sum + day.entryCount),
      gratitudeLines: current.fold(0, (int sum, DayStats day) => sum + day.gratitudeCount),
      topTags: _topTags(current, tagLimit),
      average: currentAverage,
      direction: currentAverage == null || previousAverage == null ? null : currentAverage - previousAverage,
      sentimentAverage: _averageTone(current),
      bestDay: _bestDay(current),
      highestSentimentDay: _highestSentimentDay(current),
    );
  }

  /// The monthly review of the days of one calendar month.
  static WindowStat monthly(List<DayStats> month, {int tagLimit = 3}) => weekly(month, const <DayStats>[], tagLimit: tagLimit);

  /// The weeks of a month, seven days each, first bucket starting on the 1st.
  static List<WeekBucket> weeksOf(String month, List<DayStats> stats) {
    final DateTime first = DateTime.utc(_year(month), _month(month));
    final DateTime last = DateTime.utc(_year(month), _month(month) + 1).subtract(const Duration(days: 1));
    final Map<String, DayStats> byDate = <String, DayStats>{
      for (final DayStats day in stats) day.localDate: day,
    };

    final List<WeekBucket> buckets = <WeekBucket>[];
    DateTime start = first;
    while (!start.isAfter(last)) {
      DateTime end = start.add(const Duration(days: 6));
      if (end.isAfter(last)) {
        end = last;
      }

      final List<DayStats> days = <DayStats>[];
      for (int offset = 0; offset <= end.difference(start).inDays; offset++) {
        final DayStats? day = byDate[_key(start.add(Duration(days: offset)))];
        if (day != null) {
          days.add(day);
        }
      }

      buckets.add(
        WeekBucket(
          start: _key(start),
          end: _key(end),
          daysRated: _rated(days).length,
          average: _averageRating(days),
          entriesWritten: days.fold(0, (int sum, DayStats day) => sum + day.entryCount),
          gratitudeLines: days.fold(0, (int sum, DayStats day) => sum + day.gratitudeCount),
        ),
      );

      start = end.add(const Duration(days: 1));
    }

    return buckets;
  }

  /// The calendar grid of a month, Monday first; `null` pads empty leading and trailing cells.
  static MonthGrid monthGrid(String month, List<DayStats> stats) {
    final Map<String, DayStats> byDate = <String, DayStats>{
      for (final DayStats day in stats) day.localDate: day,
    };

    final DateTime first = DateTime.utc(_year(month), _month(month));
    final int days = DateTime.utc(_year(month), _month(month) + 1).difference(first).inDays;

    // DateTime.weekday: 1 == Monday.
    final int lead = first.weekday - DateTime.monday;
    final List<List<DayStats?>> weeks = <List<DayStats?>>[];
    List<DayStats?> week = List<DayStats?>.filled(lead, null, growable: false);

    for (int day = 1; day <= days; day++) {
      week = List<DayStats?>.of(week)..add(byDate[_key(DateTime.utc(_year(month), _month(month), day))]);
      if (week.length == 7) {
        weeks.add(week);
        week = <DayStats?>[];
      }
    }

    if (week.isNotEmpty) {
      while (week.length < 7) {
        week = List<DayStats?>.of(week)..add(null);
      }
      weeks.add(week);
    }

    return MonthGrid(weeks: weeks, month: month);
  }

  static List<DayStats> _rated(List<DayStats> days) => days.where((DayStats day) => day.ratingHalf != null).toList();

  static double? _averageRating(List<DayStats> days) {
    final List<DayStats> rated = _rated(days);
    if (rated.isEmpty) {
      return null;
    }
    return rated.fold(0, (int sum, DayStats day) => sum + day.ratingHalf!) / rated.length / 2;
  }

  static double? _averageTone(List<DayStats> days) {
    final List<int> tones = days.map((DayStats day) => day.sentimentHalf).whereType<int>().toList();
    if (tones.isEmpty) {
      return null;
    }
    return tones.fold(0, (int sum, int tone) => sum + tone) / tones.length / 2;
  }

  static DayStats? _bestDay(List<DayStats> days) {
    DayStats? best;
    for (final DayStats day in _rated(days)) {
      if (best == null || day.ratingHalf! > best.ratingHalf! || (day.ratingHalf == best.ratingHalf && day.localDate.compareTo(best.localDate) > 0)) {
        best = day;
      }
    }
    return best;
  }

  static DayStats? _highestSentimentDay(List<DayStats> days) {
    DayStats? best;
    for (final DayStats day in days.where((DayStats day) => day.sentimentHalf != null)) {
      if (best == null || day.sentimentHalf! > best.sentimentHalf! || (day.sentimentHalf == best.sentimentHalf && day.localDate.compareTo(best.localDate) > 0)) {
        best = day;
      }
    }
    return best;
  }

  static List<MapEntry<String, int>> _topTags(List<DayStats> days, int limit) {
    final Map<String, int> counts = <String, int>{};
    for (final DayStats day in days) {
      for (final String label in day.tagLabels) {
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    final List<MapEntry<String, int>> entries = counts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        final int byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });

    return entries.take(limit).toList();
  }

  static int _year(String month) => int.parse(month.substring(0, 4));

  static int _month(String month) => int.parse(month.substring(5, 7));

  static String _key(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// The `YYYY-MM` of the month containing [localDate].
  static String monthOf(String localDate) => localDate.substring(0, 7);
}
