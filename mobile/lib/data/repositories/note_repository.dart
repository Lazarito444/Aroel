import 'package:aroel/core/clock.dart';
import 'package:aroel/core/notes.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/core/word_counter.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/repositories/local_profile.dart';
import 'package:drift/drift.dart';

/// The notes shelf, read and written against the device's own store (§5.6).
class NoteRepository implements NoteService {
  /// Creates the repository.
  NoteRepository({
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

  @override
  String today() =>
      '${_localNow().year.toString().padLeft(4, '0')}-'
      '${_localNow().month.toString().padLeft(2, '0')}-'
      '${_localNow().day.toString().padLeft(2, '0')}';

  @override
  Future<List<Note>> list() async {
    await _purge();
    final String userId = await _userId();
    final List<NoteRow> rows =
        await (_database.select(_database.noteRows)
              ..where((row) => row.userId.equals(userId) & row.deletedAt.isNull())
              ..orderBy(<OrderingTerm Function($NoteRowsTable)>[
                (row) => OrderingTerm.desc(row.pinned),
                (row) => OrderingTerm.desc(row.updatedAt),
                (row) => OrderingTerm.desc(row.id),
              ]))
            .get();
    return rows.map(_noteOf).toList();
  }

  @override
  Future<Note?> read(String id) async {
    final List<NoteRow> rows = await (_database.select(
      _database.noteRows,
    )..where((row) => row.id.equals(id) & row.deletedAt.isNull())).get();
    return rows.isEmpty ? null : _noteOf(rows.first);
  }

  @override
  Future<Result<Note>> create() async {
    final String userId = await _userId();
    final DateTime now = _clock.nowUtc();
    final String id = _newId();

    await _database
        .into(_database.noteRows)
        .insert(
          NoteRowsCompanion.insert(
            id: id,
            userId: userId,
            bodyMd: '',
            createdAt: now,
            updatedAt: now,
          ),
        );

    return Result<Note>.success(
      Note(
        id: id,
        title: '',
        body: '',
        wordCount: 0,
        pinned: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<Result<void>> write(String id, {required String body, String title = ''}) async {
    final DateTime now = _clock.nowUtc();
    final int words = WordCounter.count(body);

    await (_database.update(_database.noteRows)..where((row) => row.id.equals(id) & row.deletedAt.isNull())).write(
      NoteRowsCompanion(
        title: Value<String>(title.trim()),
        bodyMd: Value<String>(body),
        wordCount: Value<int>(words),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return const Result<void>.success(null);
  }

  @override
  Future<Result<void>> setPinned(String id, bool pinned) async {
    final DateTime now = _clock.nowUtc();
    await (_database.update(_database.noteRows)..where((row) => row.id.equals(id) & row.deletedAt.isNull())).write(
      NoteRowsCompanion(
        pinned: Value<bool>(pinned),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return const Result<void>.success(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final DateTime now = _clock.nowUtc();
    await (_database.update(_database.noteRows)..where((row) => row.id.equals(id))).write(
      NoteRowsCompanion(
        deletedAt: Value<DateTime?>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
    return const Result<void>.success(null);
  }

  /// Notes soft-deleted more than thirty days ago are purged for good (§5.5).
  Future<void> _purge() async {
    final DateTime cutoff = _clock.nowUtc().subtract(const Duration(days: 30));
    await (_database.delete(_database.noteRows)..where((row) => row.deletedAt.isNotNull() & row.deletedAt.isSmallerThanValue(cutoff))).go();
  }

  Future<String> _userId() async => (await ensureLocalProfile(
    database: _database,
    newId: _newId,
    timeZone: _deviceTimeZone,
    locale: _deviceLocale,
    now: _clock.nowUtc(),
  )).id;

  Note _noteOf(NoteRow row) => Note(
    id: row.id,
    title: row.title,
    body: row.bodyMd,
    wordCount: row.wordCount,
    pinned: row.pinned,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}
