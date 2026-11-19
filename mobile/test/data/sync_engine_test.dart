import 'package:aroel/core/clock.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/remote/sync_api.dart';
import 'package:aroel/data/repositories/day_repository.dart';
import 'package:aroel/data/services/sync_engine.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// A fake server that plays both sync endpoints: it stores what it receives and
/// answers with assigned sequence numbers.
class FakeSyncServer {
  FakeSyncServer() {
    server = FakeServer(handler);
  }

  int _seq = 100;
  bool failAll = false;
  final List<Map<String, Object?>> seedRowsHolder = <Map<String, Object?>>[];

  /// The fake transport.
  late final FakeServer server;

  List<Map<String, Object?>> get seedRows => seedRowsHolder;

  set seedRows(List<Map<String, Object?>> rows) {
    seedRowsHolder
      ..clear()
      ..addAll(rows);
  }

  /// The request handler, for whoever builds the [FakeServer].
  Object? Function(RequestOptions options) get handler => (RequestOptions options) {
    if (failAll) {
      return const FakeFailure(500);
    }

    if (options.uri.path == '/v1/sync/batch' && options.method == 'POST') {
      final Map<String, Object?> body = Map<String, Object?>.from(options.data as Map);
      final List<dynamic> ops = body['operations'] as List<dynamic>;
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
      for (final Map<String, Object?> op in ops.cast<Map<String, Object?>>()) {
        _seq += 1;
        rows.add(<String, Object?>{
          'table': op['table'],
          'op': op['op'],
          'id': op['id'],
          'updatedAt': op['updatedAt'],
          'syncSeq': _seq,
          if (op['data'] != null) 'data': op['data'],
        });
      }
      return <String, Object?>{'cursor': _seq, 'rows': rows, 'errors': <Object?>[]};
    }

    if (options.uri.path == '/v1/sync' && options.method == 'GET') {
      return <String, Object?>{'cursor': _seq, 'hasMore': false, 'rows': seedRowsHolder};
    }

    return <String, Object?>{};
  };
}

void main() {
  late AppDatabase database;
  late DayRepository repository;
  late SyncEngine engine;
  late FakeSyncServer fake;
  int counter = 0;

  setUp(() {
    counter = 0;
    fake = FakeSyncServer();
    database = AppDatabase(NativeDatabase.memory());
    repository = DayRepository(
      database: database,
      clock: FixedClock(DateTime.utc(2026, 11, 18, 9)),
      newId: () {
        counter++;
        return '0192f3a4-5b6c-7d8e-9f0a-${counter.toRadixString(16).padLeft(12, '0')}';
      },
      deviceTimeZone: 'Europe/Madrid',
      deviceLocale: 'en-GB',
      localNow: () => DateTime(2026, 11, 18, 21),
    );
    engine = SyncEngine(
      database: database,
      api: SyncApi(fake.server.dio),
      clock: FixedClock(DateTime.utc(2026, 11, 18, 10)),
      canSync: () => true,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('a local day is pushed and stamped with its cursor', () async {
    await repository.setRating('2026-11-18', 8);

    final Result<SyncSummary> result = await engine.syncNow();

    expect(result.isSuccess, isTrue);
    expect(fake.server.requestsFor('/v1/sync/batch'), hasLength(1));

    final Day? day = await (database.select(database.days)).getSingleOrNull();
    expect(day!.syncSeq, isNotNull);
  });

  test('a pull merges the server rows into the device', () async {
    fake.seedRows = <Map<String, Object?>>[
      <String, Object?>{
        'table': 'days',
        'op': 'upsert',
        'id': '0192f3a4-5b6c-7d8e-9f0a-aaaaaaaaaaaa',
        'updatedAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
        'syncSeq': 400,
        'data': <String, Object?>{
          'localDate': '2026-11-17',
          'ratingHalf': 9,
          'note': 'good one',
          'createdAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
          'updatedAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
        },
      },
      <String, Object?>{
        'table': 'gratitude_items',
        'op': 'upsert',
        'id': '0192f3a4-5b6c-7d8e-9f0a-bbbbbbbbbbbb',
        'updatedAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
        'syncSeq': 401,
        'data': <String, Object?>{
          'dayId': '0192f3a4-5b6c-7d8e-9f0a-aaaaaaaaaaaa',
          'position': 1,
          'text': 'the quiet',
          'createdAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
          'updatedAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
        },
      },
    ];

    final Result<SyncSummary> result = await engine.syncNow();

    expect(result.isSuccess, isTrue);

    final List<Day> days = await database.select(database.days).get();
    expect(days, hasLength(1));
    expect(days.single.ratingHalf, 9);
    expect(days.single.note, 'good one');
    expect(days.single.syncSeq, 400);

    final List<GratitudeItem> lines = await database.select(database.gratitudeItems).get();
    expect(lines, hasLength(1));
    expect(lines.single.line, 'the quiet');
  });

  test('a stale local row is not overwritten by an older server row', () async {
    await repository.setRating('2026-11-17', 2);
    final Day local = (await database.select(database.days).get()).single;

    fake.seedRows = <Map<String, Object?>>[
      <String, Object?>{
        'table': 'days',
        'op': 'upsert',
        'id': local.id,
        'updatedAt': DateTime.utc(2026, 11, 10).toIso8601String(),
        'syncSeq': 500,
        'data': <String, Object?>{
          'localDate': '2026-11-17',
          'ratingHalf': 9,
          'createdAt': DateTime.utc(2026, 11, 17, 20).toIso8601String(),
          'updatedAt': DateTime.utc(2026, 11, 10).toIso8601String(),
        },
      },
    ];

    final Result<SyncSummary> result = await engine.syncNow();
    expect(result.isSuccess, isTrue);

    final Day? after = await (database.select(database.days)).getSingleOrNull();
    expect(after!.ratingHalf, 2);
  });

  test('a tombstone for a day tag is pushed and cleared', () async {
    final result = await repository.createTag('walk');
    final tag = result.valueOrNull!;
    await repository.toggleTag('2026-11-18', tag.id);
    await repository.toggleTag('2026-11-18', tag.id);

    final Result<SyncSummary> sync = await engine.syncNow();
    expect(sync.isSuccess, isTrue);

    final RequestOptions lastBatch = fake.server.requestsFor('/v1/sync/batch').single;
    final Map<String, Object?> body = Map<String, Object?>.from(lastBatch.data as Map);
    final List<dynamic> ops = body['operations'] as List<dynamic>;
    final List<Map<String, Object?>> deletes = ops.cast<Map<String, Object?>>().where((Map<String, Object?> op) => op['op'] == 'delete').toList();

    expect(deletes, hasLength(1));
    expect(deletes.single['table'], 'day_tags');

    final List<Tombstone> tombstones = await database.select(database.tombstones).get();
    expect(tombstones, isEmpty);
  });

  test('sync refuses to run without a verified address', () async {
    engine = SyncEngine(
      database: database,
      api: SyncApi(fake.server.dio),
      clock: FixedClock(DateTime.utc(2026, 11, 18, 10)),
      canSync: () => false,
    );

    final Result<SyncSummary> result = await engine.syncNow();

    expect(result.isFailure, isTrue);
    expect(result.errorOrNull!.code, 'auth.email_not_verified');
    expect(fake.server.requests, isEmpty);
  });
}
