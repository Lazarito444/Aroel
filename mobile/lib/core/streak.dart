/// The forgiving streak (§2.3).
///
/// Evaluated lazily against the days that were kept, so no nightly job is needed and the
/// answer is the same whenever it is asked for. A day counts when something happened on
/// it: a rating, a tag, a gratitude line, or something written. One missed day spends the
/// grace token and the streak continues; two consecutive missed days break it, and the
/// fresh streak starts with a fresh token.
///
/// Whether the token replenishes over time is an open question (§10.8); as implemented,
/// it is available whenever the last day walked was a kept one.
abstract final class Streak {
  /// Evaluates the streak a person has at [today].
  ///
  /// [kept] are the days with activity, [restored] the days the reader chose to recover.
  /// Both are `YYYY-MM-DD`. An unkept [today] is not counted as a miss: the day is not
  /// over yet.
  static StreakSnapshot evaluate({
    required Iterable<String> kept,
    required String today,
    Iterable<String> restored = const <String>[],
  }) {
    final Set<String> merged = <String>{...kept, ...restored};

    if (merged.isEmpty) {
      return const StreakSnapshot(
        current: 0,
        longest: 0,
        graceRemaining: 1,
        lastKeptDate: null,
        recoveredDates: <String>[],
      );
    }

    // A day that is not over is not a miss: the walk stops at yesterday when today has
    // nothing on it yet.
    final DateTime end = _parse(today);
    final bool todayKept = merged.contains(today);
    final DateTime walkEnd = todayKept ? end : end.subtract(const Duration(days: 1));

    final List<String> ordered = merged.toList()..sort();

    int current = 0;
    int longest = 0;
    int missRun = 0;
    DateTime cursor = _parse(ordered.first);

    while (!cursor.isAfter(walkEnd)) {
      final String key = _format(cursor);
      if (merged.contains(key)) {
        current += 1;
        missRun = 0;
      } else {
        missRun += 1;
        if (missRun >= 2) {
          // Two consecutive missed days break the streak.
          current = 0;
        }
        // One missed day spends the grace token and the streak continues.
      }
      if (current > longest) {
        longest = current;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return StreakSnapshot(
      current: current,
      longest: longest,
      graceRemaining: missRun == 0 ? 1 : 0,
      lastKeptDate: ordered.last,
      recoveredDates: restored.toList()..sort(),
    );
  }

  static DateTime _parse(String localDate) {
    final List<String> parts = localDate.split('-');
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String _format(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// The streak as the reader sees it.
class StreakSnapshot {
  /// Creates a snapshot.
  const StreakSnapshot({
    required this.current,
    required this.longest,
    required this.graceRemaining,
    required this.lastKeptDate,
    required this.recoveredDates,
  });

  /// The days in a row that count right now.
  final int current;

  /// The longest run the reader has ever had.
  final int longest;

  /// Whether the grace token is available: `1` when the last day walked was kept.
  final int graceRemaining;

  /// The last day that was kept, `YYYY-MM-DD`, or `null` when nothing ever was.
  final String? lastKeptDate;

  /// The days the reader chose to recover, oldest first.
  final List<String> recoveredDates;
}
