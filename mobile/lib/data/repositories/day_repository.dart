import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/day.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/core/streak.dart';
import 'package:aroel/core/word_counter.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/repositories/local_profile.dart';
import 'package:drift/drift.dart';

/// The day record, read and written against the device's own store (§7.1).
///
/// Nothing here waits for the network. Every write lands in SQLite first, so the journal
/// works the same with the radio on and off; sync, when it is built, reads these rows.
class DayRepository implements DayService {
  /// Creates the repository.
  DayRepository({
    required this._database,
    required this._clock,
    required this._newId,
    required this._deviceTimeZone,
    required this._deviceLocale,
    DateTime Function()? localNow,
  }) : _localNow = localNow ?? DateTime.now;

  final AppDatabase _database;
  final Clock _clock;
  final String Function() _newId;
  final String _deviceTimeZone;
  final String _deviceLocale;
  final DateTime Function() _localNow;

  /// Today, as `YYYY-MM-DD` in the device's own timezone. A day is a diary concept, not a
  /// UTC one (§4.1).
  @override
  String today() => formatLocalDate(_localNow());

  /// Formats [moment] as `YYYY-MM-DD` in its own timezone.
  static String formatLocalDate(DateTime moment) =>
      '${moment.year.toString().padLeft(4, '0')}-'
      '${moment.month.toString().padLeft(2, '0')}-'
      '${moment.day.toString().padLeft(2, '0')}';

  @override
  Future<DayRecord> read(String localDate) async {
    final String userId = await _userId();
    final Day? day = await _findDay(userId, localDate);
    if (day == null) {
      return DayRecord(localDate: localDate);
    }

    final List<String> gratitude = await _gratitudeOf(day.id);
    final List<DayTagView> tags = await _tagsOf(day.id);
    final int words = await _wordCountOf(day.id);
    final int? tone = await _toneOf(day.id);

    return DayRecord(
      localDate: localDate,
      ratingHalf: day.ratingHalf,
      note: day.note ?? '',
      gratitude: gratitude,
      tags: tags,
      wordCount: words,
      sentimentHalf: tone,
    );
  }

  @override
  Future<Result<void>> setRating(String localDate, int? ratingHalf) async {
    if (ratingHalf != null && (ratingHalf < 0 || ratingHalf > 10)) {
      return const Result<void>.failure(AppError.client(DayErrorCodes.invalidRating));
    }

    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    await _database.transaction(() async {
      final Day? existing = await _findDay(userId, localDate);
      if (existing == null) {
        await _database
            .into(_database.days)
            .insert(
              DaysCompanion.insert(
                id: _newId(),
                userId: userId,
                localDate: localDate,
                ratingHalf: Value<int?>(ratingHalf),
                ratedAt: Value<DateTime?>(ratingHalf == null ? null : now),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_database.update(_database.days)..where((row) => row.id.equals(existing.id))).write(
          DaysCompanion(
            ratingHalf: Value<int?>(ratingHalf),
            ratedAt: Value<DateTime?>(ratingHalf == null ? null : now),
            updatedAt: Value<DateTime>(now),
          ),
        );
      }
      await _database.markJournalStarted(now);
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<Result<void>> setNote(String localDate, String note) async {
    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();
    final String trimmed = note.trim();

    await _database.transaction(() async {
      final String dayId = await _ensureDay(userId, localDate, now);
      await (_database.update(_database.days)..where((row) => row.id.equals(dayId))).write(
        DaysCompanion(
          note: Value<String?>(trimmed.isEmpty ? null : trimmed),
          updatedAt: Value<DateTime>(now),
        ),
      );
      await _database.markJournalStarted(now);
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<Result<void>> setGratitude(String localDate, int position, String text) async {
    if (position < 1 || position > 3) {
      return const Result<void>.failure(AppError.client(DayErrorCodes.invalidGratitudePosition));
    }

    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    await _database.transaction(() async {
      final String dayId = await _ensureDay(userId, localDate, now);
      final List<GratitudeItem> rows = await (_database.select(
        _database.gratitudeItems,
      )..where((row) => row.dayId.equals(dayId) & row.position.equals(position))).get();

      if (rows.isEmpty) {
        await _database
            .into(_database.gratitudeItems)
            .insert(
              GratitudeItemsCompanion.insert(
                id: _newId(),
                dayId: dayId,
                position: position,
                line: text,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_database.update(
          _database.gratitudeItems,
        )..where((row) => row.id.equals(rows.first.id))).write(
          GratitudeItemsCompanion(
            line: Value<String>(text),
            updatedAt: Value<DateTime>(now),
          ),
        );
      }
      await _touchDay(dayId, now);
      await _database.markJournalStarted(now);
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<List<DayTagView>> tagsOn(String localDate) async {
    final String userId = await _userId();
    final Day? day = await _findDay(userId, localDate);
    return day == null ? <DayTagView>[] : _tagsOf(day.id);
  }

  @override
  Future<List<DayTagView>> recentTags({int limit = 5}) async {
    final String userId = await _userId();

    // The five most recently *used* tags, not the five most recently made.
    final List<QueryRow> rows = await _database
        .customSelect(
          '''
      SELECT tags.id, tags.label, tags.color, MAX(day_tags.created_at) AS last_used
      FROM tags
      JOIN day_tags ON day_tags.tag_id = tags.id
      JOIN days ON days.id = day_tags.day_id
      WHERE days.user_id = ?
      GROUP BY tags.id
      ORDER BY last_used DESC, tags.id DESC
      LIMIT ?
      ''',
          variables: <Variable<Object>>[Variable<String>(userId), Variable<int>(limit)],
          readsFrom: <TableInfo<Table, Object?>>{_database.tags, _database.dayTags, _database.days},
        )
        .get();

    return rows.map(_tagFromRow).toList();
  }

  @override
  Future<List<DayTagView>> searchTags(String query, {int limit = 20}) async {
    final String userId = await _userId();
    final String normalized = query.trim();

    final List<Tag> rows;
    if (normalized.isEmpty) {
      rows =
          await (_database.select(_database.tags)
                ..where((row) => row.userId.equals(userId))
                ..orderBy(<OrderingTerm Function($TagsTable)>[(row) => OrderingTerm.desc(row.updatedAt)])
                ..limit(limit))
              .get();
    } else {
      rows =
          await (_database.select(_database.tags)
                ..where((row) => row.userId.equals(userId) & row.label.like('%$normalized%'))
                ..orderBy(<OrderingTerm Function($TagsTable)>[(row) => OrderingTerm.asc(row.label)])
                ..limit(limit))
              .get();
    }
    return rows.map(_tagOf).toList();
  }

  @override
  Future<Result<DayTagView>> createTag(String label) async {
    final String normalized = label.trim();
    if (normalized.isEmpty) {
      return const Result<DayTagView>.failure(AppError.client(DayErrorCodes.tagLabelEmpty));
    }

    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    final List<Tag> existing = await (_database.select(
      _database.tags,
    )..where((row) => row.userId.equals(userId) & row.label.equals(normalized))).get();

    if (existing.isNotEmpty) {
      return Result<DayTagView>.success(_tagOf(existing.first));
    }

    await _database
        .into(_database.tags)
        .insert(
          TagsCompanion.insert(
            id: _newId(),
            userId: userId,
            label: normalized,
            createdAt: now,
            updatedAt: now,
          ),
        );

    final Tag created = await (_database.select(
      _database.tags,
    )..where((row) => row.userId.equals(userId) & row.label.equals(normalized))).getSingle();
    return Result<DayTagView>.success(_tagOf(created));
  }

  @override
  Future<Result<void>> toggleTag(String localDate, String tagId) async {
    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    // A day carries at most five tags (§4.2); checked before the transaction so the
    // failure is a value, not an exception.
    final Day? existing = await _findDay(userId, localDate);
    final List<DayTag> onDay = existing == null
        ? <DayTag>[]
        : await (_database.select(
            _database.dayTags,
          )..where((row) => row.dayId.equals(existing.id))).get();
    final bool isOn = onDay.any((DayTag row) => row.tagId == tagId);
    if (!isOn && onDay.length >= 5) {
      return const Result<void>.failure(AppError.client(DayErrorCodes.tooManyTags));
    }

    await _database.transaction(() async {
      final String dayId = await _ensureDay(userId, localDate, now);

      if (isOn) {
        final List<DayTag> links = await (_database.select(
          _database.dayTags,
        )..where((row) => row.dayId.equals(dayId) & row.tagId.equals(tagId))).get();
        if (links.isNotEmpty) {
          await (_database.delete(_database.dayTags)..where((row) => row.id.equals(links.first.id))).go();
          // A deletion has to travel as a tombstone, or the tag comes back on sync.
          await _database
              .into(_database.tombstones)
              .insert(
                TombstonesCompanion.insert(
                  id: _newId(),
                  sourceTable: 'day_tags',
                  rowId: links.first.id,
                  deletedAt: now,
                ),
              );
        }
      } else {
        await _database
            .into(_database.dayTags)
            .insert(
              DayTagsCompanion.insert(
                id: _newId(),
                dayId: dayId,
                tagId: tagId,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      await _touchDay(dayId, now);
      await _database.markJournalStarted(now);
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<StreakSnapshot> streak() async {
    final String userId = await _userId();
    final Set<String> kept = await _keptDates(userId);
    final List<String> restored = await _restoredDates(userId);
    return Streak.evaluate(kept: kept, restored: restored, today: today());
  }

  @override
  Future<Result<void>> recoverDay(String localDate) async {
    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    await _database.transaction(() async {
      StreakState? state = await _streakStateOf(userId);
      state ??= await _createStreakState(userId, now);

      await _database
          .into(_database.streakRestorations)
          .insertOnConflictUpdate(
            StreakRestorationsCompanion.insert(
              id: _newId(),
              userId: userId,
              streakStateId: state.id,
              localDate: localDate,
              createdAt: now,
            ),
          );
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<List<String>> recoverableDays({int limit = 14}) async {
    final String userId = await _userId();
    final DateTime now = _localNow();
    final Set<String> kept = await _keptDates(userId);
    final Set<String> restored = (await _restoredDates(userId)).toSet();

    final List<String> candidates = <String>[];
    for (int offset = 1; offset <= 60 && candidates.length < limit; offset++) {
      final DateTime day = now.subtract(Duration(days: offset));
      final String key = formatLocalDate(day);
      if (!kept.contains(key) && !restored.contains(key)) {
        candidates.add(key);
      }
    }
    return candidates;
  }

  @override
  Future<Result<void>> setSentiment(String localDate, int? sentimentHalf) async {
    if (sentimentHalf != null && (sentimentHalf < 0 || sentimentHalf > 10)) {
      return const Result<void>.failure(AppError.client(DayErrorCodes.invalidRating));
    }

    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();

    await _database.transaction(() async {
      final String dayId = await _ensureDay(userId, localDate, now);
      final List<DaySentiment> rows = await (_database.select(
        _database.daySentiments,
      )..where((row) => row.dayId.equals(dayId))).get();

      if (rows.isEmpty) {
        await _database
            .into(_database.daySentiments)
            .insert(
              DaySentimentsCompanion.insert(
                id: _newId(),
                userId: userId,
                dayId: dayId,
                source: 'manual',
                ratingHalf: Value<int?>(sentimentHalf),
                recordedAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_database.update(
          _database.daySentiments,
        )..where((row) => row.id.equals(rows.first.id))).write(
          DaySentimentsCompanion(
            ratingHalf: Value<int?>(sentimentHalf),
            recordedAt: Value<DateTime>(now),
            updatedAt: Value<DateTime>(now),
          ),
        );
      }
      await _touchDay(dayId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<List<EntrySummary>> entriesOn(String localDate) async {
    await _purgeDeletedEntries();
    final String userId = await _userId();
    final Day? day = await _findDay(userId, localDate);
    if (day == null) {
      return <EntrySummary>[];
    }

    final List<Entry> rows = await (_database.select(
      _database.entries,
    )..where((row) => row.dayId.equals(day.id) & row.deletedAt.isNull())).get();
    rows.sort((Entry a, Entry b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      final int byUpdated = b.updatedAt.compareTo(a.updatedAt);
      return byUpdated != 0 ? byUpdated : b.id.compareTo(a.id);
    });

    return rows
        .map(
          (Entry row) => EntrySummary(
            id: row.id,
            snippet: _snippet(row.bodyMd),
            wordCount: row.wordCount,
            pinned: row.pinned,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<EntryRead?> readEntryById(String entryId) async {
    await _purgeDeletedEntries();
    final String userId = await _userId();
    final List<Entry> rows = await (_database.select(
      _database.entries,
    )..where((row) => row.id.equals(entryId) & row.deletedAt.isNull() & row.userId.equals(userId))).get();
    if (rows.isEmpty) {
      return null;
    }

    final Entry entry = rows.first;
    final List<Day> days = await (_database.select(
      _database.days,
    )..where((row) => row.id.equals(entry.dayId))).get();
    if (days.isEmpty) {
      return null;
    }

    final Day day = days.first;
    final int? tone = await _toneOf(day.id);
    final List<DayTagView> tags = await _tagsOf(day.id);

    return EntryRead(
      id: entry.id,
      localDate: day.localDate,
      body: entry.bodyMd,
      wordCount: entry.wordCount,
      pinned: entry.pinned,
      createdAt: entry.createdAt,
      sentimentHalf: tone,
      tags: tags,
    );
  }

  @override
  Future<Result<void>> setEntryPinned(String entryId, bool pinned) async {
    final DateTime now = _clock.nowUtc();
    await (_database.update(
      _database.entries,
    )..where((row) => row.id.equals(entryId) & row.deletedAt.isNull())).write(
      EntriesCompanion(
        pinned: Value<bool>(pinned),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return const Result<void>.success(null);
  }

  @override
  Future<Result<void>> deleteEntry(String entryId) async {
    final DateTime now = _clock.nowUtc();
    await (_database.update(_database.entries)..where((row) => row.id.equals(entryId))).write(
      EntriesCompanion(
        deletedAt: Value<DateTime?>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return const Result<void>.success(null);
  }

  @override
  Future<List<DayStats>> statsRange(String fromDate, String toDate) async {
    final String userId = await _userId();

    final List<Day> days = await (_database.select(
      _database.days,
    )..where((row) => row.userId.equals(userId) & row.localDate.isBiggerOrEqualValue(fromDate) & row.localDate.isSmallerOrEqualValue(toDate))).get();

    final List<DayStats> stats = <DayStats>[];
    for (final Day day in days) {
      final List<GratitudeItem> lines = await (_database.select(
        _database.gratitudeItems,
      )..where((row) => row.dayId.equals(day.id))).get();
      final int gratitudeCount = lines.where((GratitudeItem line) => line.line.trim().isNotEmpty).length;

      final List<Entry> entries = await (_database.select(
        _database.entries,
      )..where((row) => row.dayId.equals(day.id) & row.deletedAt.isNull())).get();

      final List<QueryRow> tagRows = await _database
          .customSelect(
            '''
      SELECT tags.label FROM tags
      JOIN day_tags ON day_tags.tag_id = tags.id
      WHERE day_tags.day_id = ?
      ''',
            variables: <Variable<Object>>[Variable<String>(day.id)],
            readsFrom: <TableInfo<Table, Object?>>{_database.tags, _database.dayTags},
          )
          .get();

      final int? tone = await _toneOf(day.id);

      stats.add(
        DayStats(
          localDate: day.localDate,
          ratingHalf: day.ratingHalf,
          entryCount: entries.where((Entry row) => row.bodyMd.trim().isNotEmpty).length,
          wordCount: entries.fold<int>(0, (int sum, Entry row) => sum + row.wordCount),
          gratitudeCount: gratitudeCount,
          tagLabels: tagRows.map((QueryRow row) => row.read<String>('label')).toList(),
          sentimentHalf: tone,
        ),
      );
    }

    return stats;
  }

  /// Entries soft-deleted more than thirty days ago are purged for good (§5.5).
  Future<void> _purgeDeletedEntries() async {
    final DateTime cutoff = _clock.nowUtc().subtract(const Duration(days: 30));
    await (_database.delete(_database.entries)..where((row) => row.deletedAt.isNotNull() & row.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  Future<int?> _toneOf(String dayId) async {
    final List<DaySentiment> rows = await (_database.select(
      _database.daySentiments,
    )..where((row) => row.dayId.equals(dayId))).get();
    return rows.isEmpty ? null : rows.first.ratingHalf;
  }

  @override
  Future<DayEntry?> readEntry(String localDate) async {
    final String userId = await _userId();
    final Day? day = await _findDay(userId, localDate);
    if (day == null) {
      return null;
    }

    final List<Entry> rows = await (_database.select(
      _database.entries,
    )..where((row) => row.dayId.equals(day.id) & row.deletedAt.isNull())).get();

    if (rows.isEmpty) {
      return null;
    }

    final Entry entry = rows.first;
    return DayEntry(id: entry.id, body: entry.bodyMd, wordCount: entry.wordCount);
  }

  @override
  Future<Result<void>> writeEntry(String localDate, String body) async {
    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();
    final int words = WordCounter.count(body);

    await _database.transaction(() async {
      final String dayId = await _ensureDay(userId, localDate, now);
      final List<Entry> rows = await (_database.select(
        _database.entries,
      )..where((row) => row.dayId.equals(dayId) & row.deletedAt.isNull())).get();

      if (rows.isEmpty) {
        await _database
            .into(_database.entries)
            .insert(
              EntriesCompanion.insert(
                id: _newId(),
                userId: userId,
                dayId: dayId,
                kind: 'free',
                bodyMd: body,
                wordCount: Value<int>(words),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_database.update(
          _database.entries,
        )..where((row) => row.id.equals(rows.first.id))).write(
          EntriesCompanion(
            bodyMd: Value<String>(body),
            wordCount: Value<int>(words),
            updatedAt: Value<DateTime>(now),
          ),
        );
      }

      await _touchDay(dayId, now);
      await _database.markJournalStarted(now);
      await _refreshStreak(userId, now);
    });

    return const Result<void>.success(null);
  }

  @override
  Future<List<RecentEntry>> recentEntries({int limit = 2}) async {
    final String userId = await _userId();
    final List<QueryRow> rows = await _database
        .customSelect(
          '''
      SELECT entries.id, days.local_date, entries.body_md
      FROM entries JOIN days ON days.id = entries.day_id
      WHERE entries.user_id = ? AND entries.deleted_at IS NULL AND entries.body_md != ''
      ORDER BY entries.updated_at DESC, entries.id DESC
      LIMIT ?
      ''',
          variables: <Variable<Object>>[Variable<String>(userId), Variable<int>(limit)],
          readsFrom: <TableInfo<Table, Object?>>{_database.entries, _database.days},
        )
        .get();

    return rows
        .map(
          (QueryRow row) => RecentEntry(
            id: row.read<String>('id'),
            localDate: row.read<String>('local_date'),
            snippet: _snippet(row.read<String>('body_md')),
          ),
        )
        .toList();
  }

  /// The days with something kept on them: a rating, a gratitude line, a tag, or writing.
  Future<Set<String>> _keptDates(String userId) async {
    final Set<String> kept = <String>{};

    final List<Day> days = await (_database.select(
      _database.days,
    )..where((row) => row.userId.equals(userId))).get();

    for (final Day day in days) {
      final bool hasRating = day.ratingHalf != null;
      final bool hasNote = (day.note ?? '').trim().isNotEmpty;

      final List<GratitudeItem> lines = await (_database.select(
        _database.gratitudeItems,
      )..where((row) => row.dayId.equals(day.id))).get();
      final bool hasGratitude = lines.any(
        (GratitudeItem line) => line.line.trim().isNotEmpty,
      );

      final List<DayTag> links = await (_database.select(
        _database.dayTags,
      )..where((row) => row.dayId.equals(day.id))).get();

      final List<Entry> entries = await (_database.select(
        _database.entries,
      )..where((row) => row.dayId.equals(day.id) & row.deletedAt.isNull())).get();
      final bool hasWriting = entries.any((Entry row) => row.bodyMd.trim().isNotEmpty);

      if (hasRating || hasNote || hasGratitude || links.isNotEmpty || hasWriting) {
        kept.add(day.localDate);
      }
    }

    return kept;
  }

  Future<List<String>> _restoredDates(String userId) async {
    final List<StreakRestoration> rows = await (_database.select(
      _database.streakRestorations,
    )..where((row) => row.userId.equals(userId))).get();
    return rows.map((StreakRestoration row) => row.localDate).toList();
  }

  /// Persists the current streak so the rest of the app can read it without walking.
  Future<void> _refreshStreak(String userId, DateTime now) async {
    final Set<String> kept = await _keptDates(userId);
    final List<String> restored = await _restoredDates(userId);
    final StreakSnapshot snapshot = Streak.evaluate(
      kept: kept,
      restored: restored,
      today: today(),
    );

    StreakState? state = await _streakStateOf(userId);
    state ??= await _createStreakState(userId, now);

    await (_database.update(_database.streakStates)..where((row) => row.id.equals(state!.id))).write(
      StreakStatesCompanion(
        currentStreak: Value<int>(snapshot.current),
        longestStreak: Value<int>(snapshot.longest),
        graceRemaining: Value<int>(snapshot.graceRemaining),
        lastKeptDate: Value<String?>(snapshot.lastKeptDate),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  Future<StreakState?> _streakStateOf(String userId) async {
    final List<StreakState> rows = await (_database.select(
      _database.streakStates,
    )..where((row) => row.userId.equals(userId))).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<StreakState> _createStreakState(String userId, DateTime now) async {
    await _database
        .into(_database.streakStates)
        .insert(
          StreakStatesCompanion.insert(
            id: _newId(),
            userId: userId,
            updatedAt: now,
          ),
        );
    return (await _streakStateOf(userId))!;
  }

  Future<String> _userId() async => (await ensureLocalProfile(
    database: _database,
    newId: _newId,
    timeZone: _deviceTimeZone,
    locale: _deviceLocale,
    now: _clock.nowUtc(),
  )).id;

  Future<Day?> _findDay(String userId, String localDate) async {
    final List<Day> rows = await (_database.select(
      _database.days,
    )..where((row) => row.userId.equals(userId) & row.localDate.equals(localDate))).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Gets or creates the day row for [localDate] and returns its identifier.
  Future<String> _ensureDay(String userId, String localDate, DateTime now) async {
    final Day? existing = await _findDay(userId, localDate);
    if (existing != null) {
      return existing.id;
    }

    final String id = _newId();
    await _database
        .into(_database.days)
        .insert(
          DaysCompanion.insert(
            id: id,
            userId: userId,
            localDate: localDate,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> _touchDay(String dayId, DateTime now) async {
    await (_database.update(_database.days)..where((row) => row.id.equals(dayId))).write(
      DaysCompanion(updatedAt: Value<DateTime>(now)),
    );
  }

  Future<List<String>> _gratitudeOf(String dayId) async {
    final List<GratitudeItem> rows = await (_database.select(
      _database.gratitudeItems,
    )..where((row) => row.dayId.equals(dayId))).get();

    final List<String> lines = <String>['', '', ''];
    for (final GratitudeItem row in rows) {
      if (row.position >= 1 && row.position <= 3) {
        lines[row.position - 1] = row.line;
      }
    }
    return lines;
  }

  Future<List<DayTagView>> _tagsOf(String dayId) async {
    final List<QueryRow> rows = await _database
        .customSelect(
          '''
      SELECT tags.id, tags.label, tags.color
      FROM tags JOIN day_tags ON day_tags.tag_id = tags.id
      WHERE day_tags.day_id = ?
      ORDER BY day_tags.created_at DESC, day_tags.id DESC
      ''',
          variables: <Variable<Object>>[Variable<String>(dayId)],
          readsFrom: <TableInfo<Table, Object?>>{_database.tags, _database.dayTags},
        )
        .get();

    return rows.map(_tagFromRow).toList();
  }

  Future<int> _wordCountOf(String dayId) async {
    final List<Entry> rows = await (_database.select(
      _database.entries,
    )..where((row) => row.dayId.equals(dayId) & row.deletedAt.isNull())).get();
    return rows.fold<int>(0, (int sum, Entry row) => sum + row.wordCount);
  }

  DayTagView _tagOf(Tag row) => DayTagView(id: row.id, label: row.label, color: row.color);

  DayTagView _tagFromRow(QueryRow row) => DayTagView(
    id: row.read<String>('id'),
    label: row.read<String>('label'),
    color: row.read<String?>('color'),
  );

  String _snippet(String body) {
    final String line = body.split('\n').first.trim();
    if (line.length <= 80) {
      return line;
    }
    return '${line.substring(0, 77)}...';
  }
}
