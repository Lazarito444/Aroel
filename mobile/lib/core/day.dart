import 'package:aroel/core/result.dart';
import 'package:aroel/core/streak.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The day service of this device.
///
/// The app wires the real service at launch; until it does, the day is not there.
final Provider<DayService> dayServiceProvider = Provider<DayService>(
  (Ref ref) => throw StateError(
    'The day service has to be wired before the app starts.',
  ),
);

/// A context tag as the reader sees it (§4.2).
class DayTagView {
  /// Creates a tag view.
  const DayTagView({required this.id, required this.label, this.color});

  /// The identifier of the tag.
  final String id;

  /// The word the reader sees.
  final String label;

  /// The colour the reader chose, when they chose one.
  final String? color;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is DayTagView && other.id == id && other.label == label && other.color == color);

  @override
  int get hashCode => Object.hash(id, label, color);
}

/// The five tones a hand can pick for a day (§4.6, source `manual`).
///
/// Neutral words, never diagnosis language (§8, §10.5). Values are half points on the
/// same scale the rating uses.
final class DayTone {
  /// Creates a tone.
  const DayTone._(this.label, this.ratingHalf);

  /// The word the reader sees.
  final String label;

  /// The tone on the half point scale, 0..10.
  final int ratingHalf;

  /// The tones, from the hardest day to the lightest.
  static const List<DayTone> all = <DayTone>[
    DayTone._('Heavy', 1),
    DayTone._('Low', 3),
    DayTone._('Steady', 5),
    DayTone._('Light', 7),
    DayTone._('Bright', 9),
  ];

  /// Whether [ratingHalf] is the value of this tone.
  bool matches(int? ratingHalf) => ratingHalf == this.ratingHalf;

  /// The tone that sits on [ratingHalf], when one does.
  static DayTone? at(int? ratingHalf) {
    for (final DayTone tone in all) {
      if (tone.matches(ratingHalf)) {
        return tone;
      }
    }
    return null;
  }
}

/// What the reader sees of one day (§5.3).
///
/// Gratitude lines are three strings in positions 1 to 3; an empty string is a line that
/// is not written. The rating is half points, `null` when the day is not rated.
class DayRecord {
  /// Creates a record.
  const DayRecord({
    required this.localDate,
    this.ratingHalf,
    this.note = '',
    this.gratitude = const <String>['', '', ''],
    this.tags = const <DayTagView>[],
    this.wordCount = 0,
    this.sentimentHalf,
  });

  /// The day as a diary counts it, `YYYY-MM-DD`.
  final String localDate;

  /// Half points, 0..10. `null` means not rated; `0` is a real score.
  final int? ratingHalf;

  /// The one-line note of the day, empty when there is none.
  final String note;

  /// The three lines of gratitude, in order. An empty string is an unwritten line.
  final List<String> gratitude;

  /// The tags on the day, most recently added first.
  final List<DayTagView> tags;

  /// The words written on the day's entry, so far.
  final int wordCount;

  /// The tone of the day on the half point scale, when one was picked by hand.
  final int? sentimentHalf;
}

/// One of the two most recent entries, as the Today screen lists them (§5.3).
class RecentEntry {
  /// Creates a view of a past entry.
  const RecentEntry({required this.id, required this.localDate, required this.snippet});

  /// The identifier of the entry.
  final String id;

  /// The day the entry belongs to, `YYYY-MM-DD`.
  final String localDate;

  /// The first line of the body, trimmed for display.
  final String snippet;
}

/// The day record as the app reads and writes it (§5.3, §5.4).
///
/// The port lives in `core`; the data layer implements it, and the app wires the two
/// together. Every method answers with a [Result] when it can fail in a way the screen
/// has to explain.
abstract interface class DayService {
  /// Today, as `YYYY-MM-DD` in the device's own timezone. A day is a diary concept, not a
  /// UTC one (§4.1).
  String today();

  /// Reads the record of [localDate], or an empty record when nothing was kept that day.
  Future<DayRecord> read(String localDate);

  /// Sets or clears the rating of [localDate]. A second tap on the same value clears it.
  Future<Result<void>> setRating(String localDate, int? ratingHalf);

  /// Sets the one-line note of [localDate].
  Future<Result<void>> setNote(String localDate, String note);

  /// Sets the gratitude line at [position] (1..3) of [localDate]. An empty string is a
  /// removed line.
  Future<Result<void>> setGratitude(String localDate, int position, String text);

  /// Reads the tags on [localDate].
  Future<List<DayTagView>> tagsOn(String localDate);

  /// Reads the most recently used tags, for the row on Today.
  Future<List<DayTagView>> recentTags({int limit = 5});

  /// Reads the tags whose label contains [query], for the sheet.
  Future<List<DayTagView>> searchTags(String query, {int limit = 20});

  /// Creates a tag with [label], or returns the existing one with that label.
  Future<Result<DayTagView>> createTag(String label);

  /// Adds or removes [tagId] on [localDate].
  Future<Result<void>> toggleTag(String localDate, String tagId);

  /// Reads the streak as it stands today.
  Future<StreakSnapshot> streak();

  /// Marks [localDate] as recovered (§2.3).
  Future<Result<void>> recoverDay(String localDate);

  /// Reads the days the streak can recover, most recent first.
  Future<List<String>> recoverableDays({int limit = 14});

  /// Reads the entry of [localDate], or `null` when nothing was written.
  Future<DayEntry?> readEntry(String localDate);

  /// Writes [body] to the entry of [localDate], creating the day if it does not exist.
  Future<Result<void>> writeEntry(String localDate, String body);

  /// Reads the two most recent entries with something written on them.
  Future<List<RecentEntry>> recentEntries({int limit = 2});

  /// Sets or clears the tone of [localDate] (§4.6). A hand pick wins over a derived one.
  Future<Result<void>> setSentiment(String localDate, int? sentimentHalf);

  /// Reads the entries of [localDate], pinned first, most recent first.
  Future<List<EntrySummary>> entriesOn(String localDate);

  /// Reads an entry by its identifier (§5.5).
  Future<EntryRead?> readEntryById(String entryId);

  /// Pins or unpins an entry.
  Future<Result<void>> setEntryPinned(String entryId, bool pinned);

  /// Soft-deletes an entry (§5.5). It is purged after thirty days.
  Future<Result<void>> deleteEntry(String entryId);

  /// Reads the stats of every day in [fromDate]..[toDate], inclusive (§5.8).
  Future<List<DayStats>> statsRange(String fromDate, String toDate);
}

/// One entry of a day, as the day detail lists it (§5.7).
class EntrySummary {
  /// Creates a summary.
  const EntrySummary({
    required this.id,
    required this.snippet,
    required this.wordCount,
    required this.pinned,
    required this.updatedAt,
  });

  /// The identifier of the entry.
  final String id;

  /// The first line of the body, trimmed for display.
  final String snippet;

  /// The number of words in the body.
  final int wordCount;

  /// Whether the entry is pinned.
  final bool pinned;

  /// When the entry last changed, in UTC.
  final DateTime updatedAt;
}

/// An entry, as the read view shows it (§5.5).
class EntryRead {
  /// Creates a read view.
  const EntryRead({
    required this.id,
    required this.localDate,
    required this.body,
    required this.wordCount,
    required this.pinned,
    required this.createdAt,
    required this.sentimentHalf,
    required this.tags,
  });

  /// The identifier of the entry.
  final String id;

  /// The day the entry belongs to, `YYYY-MM-DD`.
  final String localDate;

  /// The markdown-lite body.
  final String body;

  /// The number of words in the body.
  final int wordCount;

  /// Whether the entry is pinned.
  final bool pinned;

  /// When the entry was created, in UTC.
  final DateTime createdAt;

  /// The tone of the day, when one was picked.
  final int? sentimentHalf;

  /// The tags on the day the entry belongs to.
  final List<DayTagView> tags;
}

/// The rows of one day, grouped for the insights arithmetic (§5.8).
class DayStats {
  /// Creates a stats bundle.
  const DayStats({
    required this.localDate,
    this.ratingHalf,
    this.entryCount = 0,
    this.wordCount = 0,
    this.gratitudeCount = 0,
    this.tagLabels = const <String>[],
    this.sentimentHalf,
  });

  /// The day as a diary counts it, `YYYY-MM-DD`.
  final String localDate;

  /// Half points, 0..10, when the day was rated.
  final int? ratingHalf;

  /// The number of live entries written on the day.
  final int entryCount;

  /// The words written on the day.
  final int wordCount;

  /// The gratitude lines filled on the day.
  final int gratitudeCount;

  /// The labels of the tags on the day.
  final List<String> tagLabels;

  /// The tone of the day, when one was picked.
  final int? sentimentHalf;
}

/// Today's entry, as the editor reads it (§5.4).
class DayEntry {
  /// Creates an entry view.
  const DayEntry({required this.id, required this.body, required this.wordCount});

  /// The identifier of the entry.
  final String id;

  /// The markdown-lite body.
  final String body;

  /// The number of words in the body.
  final int wordCount;
}
