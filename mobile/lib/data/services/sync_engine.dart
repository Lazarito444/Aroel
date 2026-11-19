import 'package:aroel/core/app_error.dart';
import 'package:aroel/core/clock.dart';
import 'package:aroel/core/ids.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/sync_api.dart';
import 'package:aroel/data/repositories/local_profile.dart';
import 'package:drift/drift.dart';

/// The sync of the device (§7.3).
///
/// Push goes first, then pull. A row travels when it never reached the server
/// (`sync_seq` is null) or it changed after the last acknowledged write; a deletion
/// travels as a tombstone so it cannot be resurrected by a stale device.
///
/// The server is last-write-wins per row by `updated_at`; the client applies whatever
/// the server hands back, because the server's merge has already happened by then.
///
/// Sync is gated on a confirmed address: a device that has not verified its email does
/// nothing, because verification is required before the first sync (§5.1). Writing is
/// never gated, so a failure to sync costs nothing but the delay.
class SyncEngine {
  /// Creates the engine.
  SyncEngine({
    required this._database,
    required this._api,
    required this._clock,
    required this._canSync,
  });

  final AppDatabase _database;
  final SyncApi _api;
  final Clock _clock;
  final bool Function() _canSync;
  bool _busy = false;

  /// Whether a sync is running right now.
  bool get isBusy => _busy;

  /// Flushes local changes and pulls the server's.
  ///
  /// Failures land in the returned [Result]; a launch-time sync ignores them, a manual
  /// one shows them in one plain sentence.
  Future<Result<SyncSummary>> syncNow() async {
    if (_busy) {
      return const Result<SyncSummary>.success(SyncSummary(pushed: 0, pulled: 0));
    }

    if (!_canSync()) {
      return const Result<SyncSummary>.failure(AppError.server('auth.email_not_verified'));
    }

    _busy = true;
    try {
      final DateTime pushedBefore = await _lastPushAt();
      final DateTime pulledBefore = await _lastPulledAt();

      final Push outcome = await _push(pushedBefore, pulledBefore);
      if (outcome.failure != null) {
        return Result<SyncSummary>.failure(outcome.failure!);
      }

      if (outcome.serverErrors.isNotEmpty) {
        return const Result<SyncSummary>.failure(AppError.client(ClientErrorCodes.syncPartialFailure));
      }

      final Pull pull = await _pull();
      return Result<SyncSummary>.success(SyncSummary(pushed: outcome.pushed, pulled: pull.merged));
    } finally {
      _busy = false;
    }
  }

  Future<Push> _push(DateTime pushedBefore, DateTime pulledBefore) async {
    final DateTime watermark = pushedBefore.isAfter(pulledBefore) ? pushedBefore : pulledBefore;
    final List<SyncOperation> operations = <SyncOperation>[];
    operations.addAll(await _collectDays(watermark));
    operations.addAll(await _collectEntries(watermark));
    operations.addAll(await _collectNotes(watermark));
    operations.addAll(await _collectTags(watermark));
    operations.addAll(await _collectGratitudeItems(watermark));
    operations.addAll(await _collectDayTags(watermark));
    operations.addAll(await _collectSentiments(watermark));
    operations.addAll(await _collectTombstones(watermark));

    if (operations.isEmpty) {
      await _writeSyncWatermark('last_pushed_at');
      return const Push(pushed: 0);
    }

    final Result<SyncBatchResult> result = await _api.push(operations);
    if (result.isFailure) {
      return Push(failure: result.errorOrNull);
    }

    final SyncBatchResult batch = result.valueOrNull!;
    await _applyPushedRows(batch.rows);
    await _clearTombstonesFor(batch.rows);
    await _writeSyncWatermark('last_pushed_at');

    return Push(pushed: operations.length, serverErrors: batch.errors);
  }

  Future<Pull> _pull() async {
    int cursor = await _database.readCursor();
    int merged = 0;

    while (true) {
      final Result<SyncPullPage> page = await _api.pull(cursor);
      if (page.isFailure) {
        return const Pull();
      }

      final SyncPullPage pull = page.valueOrNull!;
      for (final SyncRow row in pull.rows) {
        final bool applied = await _applyPulledRow(row);
        if (applied) {
          merged++;
        }
      }

      cursor = pull.cursor;
      await _database.writeCursor(cursor, _clock.nowUtc());

      if (!pull.hasMore) {
        break;
      }
    }

    await _writeSyncWatermark('last_pulled_at');
    return Pull(merged: merged);
  }

  // --- Dirty collection ----------------------------------------------------

  bool _dirty(DateTime watermark, DateTime rowUpdatedAt, int? syncSeq) => syncSeq == null || rowUpdatedAt.isAfter(watermark);

  Future<List<SyncOperation>> _collectDays(DateTime watermark) async {
    final List<Day> rows = await _database.select(_database.days).get();
    return <SyncOperation>[
      for (final Day row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'days',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'localDate': row.localDate,
              'ratingHalf': row.ratingHalf,
              'note': row.note,
              'ratedAt': row.ratedAt?.toUtc().toIso8601String(),
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectGratitudeItems(DateTime watermark) async {
    final List<GratitudeItem> rows = await _database.select(_database.gratitudeItems).get();
    return <SyncOperation>[
      for (final GratitudeItem row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'gratitude_items',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'dayId': row.dayId,
              'position': row.position,
              'text': row.line,
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectTags(DateTime watermark) async {
    final List<Tag> rows = await _database.select(_database.tags).get();
    return <SyncOperation>[
      for (final Tag row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'tags',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'label': row.label,
              'color': row.color,
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectDayTags(DateTime watermark) async {
    final List<DayTag> rows = await _database.select(_database.dayTags).get();
    return <SyncOperation>[
      for (final DayTag row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'day_tags',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'dayId': row.dayId,
              'tagId': row.tagId,
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectEntries(DateTime watermark) async {
    final List<Entry> rows = await _database.select(_database.entries).get();
    return <SyncOperation>[
      for (final Entry row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'entries',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'dayId': row.dayId,
              'kind': row.kind,
              'title': row.title,
              'bodyMd': row.bodyMd,
              'wordCount': row.wordCount,
              'openedCount': row.openedCount,
              'lastOpenedAt': row.lastOpenedAt?.toUtc().toIso8601String(),
              'pinned': row.pinned,
              'deletedAt': row.deletedAt?.toUtc().toIso8601String(),
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectNotes(DateTime watermark) async {
    final List<NoteRow> rows = await _database.select(_database.noteRows).get();
    return <SyncOperation>[
      for (final NoteRow row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'notes',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'title': row.title.isEmpty ? null : row.title,
              'bodyMd': row.bodyMd,
              'wordCount': row.wordCount,
              'pinned': row.pinned,
              'deletedAt': row.deletedAt?.toUtc().toIso8601String(),
              'createdAt': row.createdAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectSentiments(DateTime watermark) async {
    final List<DaySentiment> rows = await _database.select(_database.daySentiments).get();
    return <SyncOperation>[
      for (final DaySentiment row in rows)
        if (_dirty(watermark, row.updatedAt, row.syncSeq))
          SyncOperation(
            table: 'day_sentiment',
            op: 'upsert',
            id: row.id,
            updatedAt: row.updatedAt,
            data: <String, Object?>{
              'dayId': row.dayId,
              'ratingHalf': row.ratingHalf,
              'source': row.source,
              'recordedAt': row.recordedAt.toUtc().toIso8601String(),
              'updatedAt': row.updatedAt.toUtc().toIso8601String(),
            },
          ),
    ];
  }

  Future<List<SyncOperation>> _collectTombstones(DateTime watermark) async {
    final List<Tombstone> rows = await _database.select(_database.tombstones).get();
    return <SyncOperation>[
      for (final Tombstone row in rows)
        SyncOperation(
          table: row.sourceTable,
          op: 'delete',
          id: row.rowId,
          updatedAt: row.deletedAt,
        ),
    ];
  }

  // --- Applying what the server hands back ----------------------------------

  Future<void> _applyPushedRows(List<SyncRow> rows) async {
    for (final SyncRow row in rows) {
      if (row.op == 'delete') {
        continue;
      }

      await _applyUpsert(row);
    }
  }

  Future<void> _clearTombstonesFor(List<SyncRow> rows) async {
    for (final SyncRow row in rows) {
      if (row.op != 'delete') {
        continue;
      }

      await (_database.delete(_database.tombstones)..where((tombstone) => tombstone.sourceTable.equals(row.table) & tombstone.rowId.equals(row.id))).go();
    }
  }

  Future<bool> _applyPulledRow(SyncRow row) async {
    if (row.op == 'delete') {
      return _applyDelete(row);
    }

    return _applyUpsert(row);
  }

  Future<bool> _applyUpsert(SyncRow row) async {
    final Map<String, Object?> data = row.data ?? <String, Object?>{};

    switch (row.table) {
      case 'days':
        return _upsertDays(row, data);
      case 'gratitude_items':
        return _upsertGratitudeItems(row, data);
      case 'tags':
        return _upsertTags(row, data);
      case 'day_tags':
        return _upsertDayTags(row, data);
      case 'entries':
        return _upsertEntries(row, data);
      case 'notes':
        return _upsertNotes(row, data);
      case 'day_sentiment':
        return _upsertSentiments(row, data);
      default:
        return false;
    }
  }

  Future<bool> _applyDelete(SyncRow row) async {
    switch (row.table) {
      case 'entries':
      case 'notes':
        await _softDeleteRow(row);
        return true;
      case 'gratitude_items':
        await (_database.delete(_database.gratitudeItems)..where((item) => item.id.equals(row.id))).go();
        return true;
      case 'tags':
        await (_database.delete(_database.tags)..where((item) => item.id.equals(row.id))).go();
        return true;
      case 'day_tags':
        await (_database.delete(_database.dayTags)..where((item) => item.id.equals(row.id))).go();
        return true;
      case 'day_sentiment':
        await (_database.delete(_database.daySentiments)..where((item) => item.id.equals(row.id))).go();
        return true;
      default:
        return false;
    }
  }

  Future<void> _softDeleteRow(SyncRow row) async {
    final DateTime when = row.updatedAt;
    if (row.table == 'entries') {
      final Entry? existing = (await (_database.select(_database.entries)..where((entry) => entry.id.equals(row.id))).getSingleOrNull());
      if (existing != null && !existing.updatedAt.isAfter(when)) {
        await (_database.update(_database.entries)..where((entry) => entry.id.equals(row.id))).write(
          EntriesCompanion(
            deletedAt: Value<DateTime?>(when),
            updatedAt: Value<DateTime>(when),
            syncSeq: Value<int?>(row.syncSeq),
          ),
        );
      }
      return;
    }

    final NoteRow? existing = (await (_database.select(_database.noteRows)..where((note) => note.id.equals(row.id))).getSingleOrNull());
    if (existing != null && !existing.updatedAt.isAfter(when)) {
      await (_database.update(_database.noteRows)..where((note) => note.id.equals(row.id))).write(
        NoteRowsCompanion(
          deletedAt: Value<DateTime?>(when),
          updatedAt: Value<DateTime>(when),
          syncSeq: Value<int?>(row.syncSeq),
        ),
      );
    }
  }

  Future<bool> _upsertDays(SyncRow row, Map<String, Object?> data) async {
    final String localDate = _str(data, 'localDate') ?? '';
    if (localDate.isEmpty) {
      return false;
    }

    final Day? existing = (await (_database.select(_database.days)..where((day) => day.id.equals(row.id))).getSingleOrNull());
    final int? ratingHalf = _int(data, 'ratingHalf');
    final String? note = _str(data, 'note');
    final DateTime? ratedAt = _instant(data, 'ratedAt');
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      final String userId = await _userId();
      final Day? sameDate = await (_database.select(_database.days)..where((day) => day.userId.equals(userId) & day.localDate.equals(localDate))).getSingleOrNull();

      if (sameDate != null) {
        // Two devices made the same day offline: keep the local row, merge the fields by LWW.
        if (sameDate.updatedAt.isAfter(row.updatedAt)) {
          return true;
        }

        await (_database.update(_database.days)..where((day) => day.id.equals(sameDate.id))).write(
          DaysCompanion(
            ratingHalf: Value<int?>(ratingHalf),
            note: Value<String?>(note),
            ratedAt: Value<DateTime?>(ratedAt),
            updatedAt: Value<DateTime>(row.updatedAt),
            syncSeq: Value<int?>(row.syncSeq),
          ),
        );
        return true;
      }

      await _database
          .into(_database.days)
          .insert(
            DaysCompanion.insert(
              id: row.id,
              userId: await _userId(),
              localDate: localDate,
              ratingHalf: Value<int?>(ratingHalf),
              note: Value<String?>(note),
              ratedAt: Value<DateTime?>(ratedAt),
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.days)..where((day) => day.id.equals(row.id))).write(
      DaysCompanion(
        localDate: Value<String>(localDate),
        ratingHalf: Value<int?>(ratingHalf),
        note: Value<String?>(note),
        ratedAt: Value<DateTime?>(ratedAt),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertGratitudeItems(SyncRow row, Map<String, Object?> data) async {
    final GratitudeItem? existing = (await (_database.select(_database.gratitudeItems)..where((item) => item.id.equals(row.id))).getSingleOrNull());
    final String text = _str(data, 'text') ?? '';
    final int position = _int(data, 'position') ?? 1;
    final String dayId = _str(data, 'dayId') ?? '';
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      await _database
          .into(_database.gratitudeItems)
          .insert(
            GratitudeItemsCompanion.insert(
              id: row.id,
              dayId: dayId,
              position: position,
              line: text,
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.gratitudeItems)..where((item) => item.id.equals(row.id))).write(
      GratitudeItemsCompanion(
        dayId: Value<String>(dayId),
        position: Value<int>(position),
        line: Value<String>(text),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertTags(SyncRow row, Map<String, Object?> data) async {
    final Tag? existing = (await (_database.select(_database.tags)..where((tag) => tag.id.equals(row.id))).getSingleOrNull());
    final String label = _str(data, 'label') ?? '';
    final String? color = _str(data, 'color');
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      await _database
          .into(_database.tags)
          .insert(
            TagsCompanion.insert(
              id: row.id,
              userId: await _userId(),
              label: label,
              color: Value<String?>(color),
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.tags)..where((tag) => tag.id.equals(row.id))).write(
      TagsCompanion(
        label: Value<String>(label),
        color: Value<String?>(color),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertDayTags(SyncRow row, Map<String, Object?> data) async {
    final DayTag? existing = (await (_database.select(_database.dayTags)..where((link) => link.id.equals(row.id))).getSingleOrNull());
    final String dayId = _str(data, 'dayId') ?? '';
    final String tagId = _str(data, 'tagId') ?? '';
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      await _database
          .into(_database.dayTags)
          .insert(
            DayTagsCompanion.insert(
              id: row.id,
              dayId: dayId,
              tagId: tagId,
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.dayTags)..where((link) => link.id.equals(row.id))).write(
      DayTagsCompanion(
        dayId: Value<String>(dayId),
        tagId: Value<String>(tagId),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertEntries(SyncRow row, Map<String, Object?> data) async {
    final Entry? existing = (await (_database.select(_database.entries)..where((entry) => entry.id.equals(row.id))).getSingleOrNull());
    final String dayId = _str(data, 'dayId') ?? '';
    final String body = _str(data, 'bodyMd') ?? '';
    final int wordCount = _int(data, 'wordCount') ?? 0;
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      await _database
          .into(_database.entries)
          .insert(
            EntriesCompanion.insert(
              id: row.id,
              userId: await _userId(),
              dayId: dayId,
              kind: _str(data, 'kind') ?? 'free',
              title: Value<String>(_str(data, 'title') ?? ''),
              bodyMd: body,
              wordCount: Value<int>(wordCount),
              openedCount: Value<int>(_int(data, 'openedCount') ?? 0),
              lastOpenedAt: Value<DateTime?>(_instant(data, 'lastOpenedAt')),
              pinned: Value<bool>(_bool(data, 'pinned') ?? false),
              deletedAt: Value<DateTime?>(_instant(data, 'deletedAt')),
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.entries)..where((entry) => entry.id.equals(row.id))).write(
      EntriesCompanion(
        dayId: Value<String>(dayId),
        kind: Value<String>(_str(data, 'kind') ?? 'free'),
        title: Value<String>(_str(data, 'title') ?? ''),
        bodyMd: Value<String>(body),
        wordCount: Value<int>(wordCount),
        openedCount: Value<int>(_int(data, 'openedCount') ?? existing.openedCount),
        lastOpenedAt: Value<DateTime?>(_instant(data, 'lastOpenedAt')),
        pinned: Value<bool>(_bool(data, 'pinned') ?? existing.pinned),
        deletedAt: Value<DateTime?>(_instant(data, 'deletedAt')),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertNotes(SyncRow row, Map<String, Object?> data) async {
    final NoteRow? existing = (await (_database.select(_database.noteRows)..where((note) => note.id.equals(row.id))).getSingleOrNull());
    final String body = _str(data, 'bodyMd') ?? '';
    final int wordCount = _int(data, 'wordCount') ?? 0;
    final DateTime createdAt = _instant(data, 'createdAt') ?? row.updatedAt;

    if (existing == null) {
      await _database
          .into(_database.noteRows)
          .insert(
            NoteRowsCompanion.insert(
              id: row.id,
              userId: await _userId(),
              title: Value<String>(_str(data, 'title') ?? ''),
              bodyMd: body,
              wordCount: Value<int>(wordCount),
              pinned: Value<bool>(_bool(data, 'pinned') ?? false),
              deletedAt: Value<DateTime?>(_instant(data, 'deletedAt')),
              createdAt: createdAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    if (existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    await (_database.update(_database.noteRows)..where((note) => note.id.equals(row.id))).write(
      NoteRowsCompanion(
        title: Value<String>(_str(data, 'title') ?? ''),
        bodyMd: Value<String>(body),
        wordCount: Value<int>(wordCount),
        pinned: Value<bool>(_bool(data, 'pinned') ?? existing.pinned),
        deletedAt: Value<DateTime?>(_instant(data, 'deletedAt')),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  Future<bool> _upsertSentiments(SyncRow row, Map<String, Object?> data) async {
    final DaySentiment? existing = (await (_database.select(_database.daySentiments)..where((sentiment) => sentiment.id.equals(row.id))).getSingleOrNull());
    final String dayId = _str(data, 'dayId') ?? '';
    final int? tone = _int(data, 'ratingHalf');
    final DateTime recordedAt = _instant(data, 'recordedAt') ?? row.updatedAt;
    if (existing != null && existing.updatedAt.isAfter(row.updatedAt)) {
      return false;
    }

    if (existing == null) {
      await _database
          .into(_database.daySentiments)
          .insert(
            DaySentimentsCompanion.insert(
              id: row.id,
              userId: await _userId(),
              dayId: dayId,
              ratingHalf: Value<int?>(tone),
              source: _str(data, 'source') ?? 'manual',
              recordedAt: recordedAt,
              updatedAt: row.updatedAt,
              syncSeq: Value<int?>(row.syncSeq),
            ),
          );
      return true;
    }

    await (_database.update(_database.daySentiments)..where((sentiment) => sentiment.id.equals(row.id))).write(
      DaySentimentsCompanion(
        dayId: Value<String>(dayId),
        ratingHalf: Value<int?>(tone),
        source: Value<String>(_str(data, 'source') ?? 'manual'),
        recordedAt: Value<DateTime>(recordedAt),
        updatedAt: Value<DateTime>(row.updatedAt),
        syncSeq: Value<int?>(row.syncSeq),
      ),
    );
    return true;
  }

  // --- Helpers ----------------------------------------------------------------

  /// The profile of this device, made on first use if it is not there yet. An empty
  /// journal syncs too: the first pull has something to land in.
  Future<String> _userId() async {
    final LocalUser? profile = await _database.findProfile();
    if (profile != null) {
      return profile.id;
    }

    return (await ensureLocalProfile(
      database: _database,
      newId: Ids.uuid7,
      timeZone: 'UTC',
      locale: 'en',
      now: _clock.nowUtc(),
    )).id;
  }

  Future<DateTime> _lastPushAt() async {
    final String? raw = await _database.readPreference('sync.last_pushed_at');
    return raw == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse(raw).toUtc();
  }

  Future<DateTime> _lastPulledAt() async {
    final String? raw = await _database.readPreference('sync.last_pulled_at');
    return raw == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse(raw).toUtc();
  }

  Future<void> _writeSyncWatermark(String key) => _database.writePreference(key, _clock.nowUtc().toIso8601String());

  static String? _str(Map<String, Object?> data, String key) => data[key] as String?;

  static int? _int(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static bool? _bool(Map<String, Object?> data, String key) => data[key] as bool?;

  static DateTime? _instant(Map<String, Object?> data, String key) {
    final Object? value = data[key];
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value).toUtc();
  }
}

/// What a sync did, in numbers.
class SyncSummary {
  /// Creates a summary.
  const SyncSummary({required this.pushed, required this.pulled});

  /// The operations that went out.
  final int pushed;

  /// The rows that came in.
  final int pulled;
}

class Push {
  const Push({this.pushed = 0, this.failure, this.serverErrors = const <Map<String, Object?>>[]});

  final int pushed;
  final AppError? failure;
  final List<Map<String, Object?>> serverErrors;
}

class Pull {
  const Pull({this.merged = 0});

  final int merged;
}
