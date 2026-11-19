import 'package:aroel/core/onboarding.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The journal profile of this device (§4.2).
///
/// One row, created on first launch. Its identifier is the one the client writes every
/// row under, and it is a `uuid7` the device made itself, so nothing ever has to be
/// re-keyed when an account is created.
class LocalUsers extends Table {
  /// The identifier this device writes its rows under.
  TextColumn get id => text()();

  /// The account this device is linked to, when there is one.
  TextColumn get accountUserId => text().nullable()();

  /// The name shown in the app.
  TextColumn get displayName => text().withDefault(const Constant(''))();

  /// The timezone the days are counted in.
  TextColumn get timeZone => text()();

  /// The culture the interface is rendered in.
  TextColumn get locale => text()();

  /// Whether the device holds journal rows of its own.
  ///
  /// A device with rows of its own never adopts the identifier of an account: a row is
  /// never re-keyed (§4.2). A fresh device does adopt it, so that everything the account
  /// brings down lands under the same identifier.
  BoolColumn get hasLocalJournal => boolean().withDefault(const Constant(false))();

  /// When the profile was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the profile last changed.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Small pieces of state the app keeps on the device.
class Preferences extends Table {
  /// The name of the preference.
  TextColumn get key => text()();

  /// The value, as text.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

/// Where the sync stands.
class SyncStates extends Table {
  /// There is one row, and its identifier is one.
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// The server cursor the last pull reached.
  IntColumn get cursor => integer().withDefault(const Constant(0))();

  /// When the last pull finished.
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The day is the unit (§4.1). One row per user per `local_date`; everything the app
/// calls history or analytics is a query over this table.
class Days extends Table {
  /// The identifier of the day record.
  TextColumn get id => text()();

  /// The identifier of the person the day belongs to.
  TextColumn get userId => text()();

  /// The day as a diary counts it, `YYYY-MM-DD`. Not a UTC instant.
  TextColumn get localDate => text()();

  /// Half points, 0..10. `null` means the day is not rated; `0` is a real score.
  IntColumn get ratingHalf => integer().nullable()();

  /// The one-line note of the day, when there is one.
  TextColumn get note => text().nullable()();

  /// When the rating was set or last changed.
  DateTimeColumn get ratedAt => dateTime().nullable()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {userId, localDate},
  ];
}

/// The three small things of a day (§5.3). Each line is optional.
class GratitudeItems extends Table {
  /// The identifier of the line.
  TextColumn get id => text()();

  /// The day the line belongs to.
  TextColumn get dayId => text()();

  /// The position of the line, 1 to 3.
  IntColumn get position => integer()();

  /// What the reader wrote. Empty text is a removed line, kept rather than deleted.
  TextColumn get line => text().named('text')();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {dayId, position},
  ];
}

/// A context tag for a day (§4.2).
class Tags extends Table {
  /// The identifier of the tag.
  TextColumn get id => text()();

  /// The identifier of the person the tag belongs to.
  TextColumn get userId => text()();

  /// The word the reader sees.
  TextColumn get label => text()();

  /// The colour of the tag, when the reader chose one.
  TextColumn get color => text().nullable()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {userId, label},
  ];
}

/// The link between a day and a tag (§4.2).
class DayTags extends Table {
  /// The identifier of the link.
  TextColumn get id => text()();

  /// The day the tag is on.
  TextColumn get dayId => text()();

  /// The tag that is on the day.
  TextColumn get tagId => text()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {dayId, tagId},
  ];
}

/// Per-day writing (§5.4). The entry attaches to the day it was written on.
class Entries extends Table {
  /// The identifier of the entry.
  TextColumn get id => text()();

  /// The identifier of the person the entry belongs to.
  TextColumn get userId => text()();

  /// The day the entry belongs to.
  TextColumn get dayId => text()();

  /// `free` or `mood_only`.
  TextColumn get kind => text()();

  /// The title, when there is one.
  TextColumn get title => text().withDefault(const Constant(''))();

  /// The markdown-lite body.
  TextColumn get bodyMd => text()();

  /// The number of words in the body, kept so analytics never has to recount.
  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  /// How many times the entry has been opened.
  IntColumn get openedCount => integer().withDefault(const Constant(0))();

  /// When the entry was last opened.
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();

  /// Whether the entry is pinned.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// When the entry was soft-deleted. `null` means the entry is live.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The tone of a day (§4.6). At most one per day; a hand pick wins over a derived one.
class DaySentiments extends Table {
  /// The identifier of the tone record.
  TextColumn get id => text()();

  /// The identifier of the person the tone belongs to.
  TextColumn get userId => text()();

  /// The day the tone belongs to.
  TextColumn get dayId => text()();

  /// The tone on the same half point scale as a rating, when one was picked.
  IntColumn get ratingHalf => integer().nullable()();

  /// Where the tone came from: `manual` or `on_device`.
  TextColumn get source => text()();

  /// When the tone was recorded.
  DateTimeColumn get recordedAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {dayId},
  ];
}

/// The notes shelf (§4.2). A note has no date and never touches the streak.
class NoteRows extends Table {
  /// The identifier of the note.
  TextColumn get id => text()();

  /// The identifier of the person the note belongs to.
  TextColumn get userId => text()();

  /// The title of the note, when there is one.
  TextColumn get title => text().withDefault(const Constant(''))();

  /// The markdown-lite body.
  TextColumn get bodyMd => text()();

  /// The number of words in the body.
  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  /// Whether the note is pinned.
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  /// When the note was soft-deleted. `null` means the note is live.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  /// The server cursor of the last sync, when the row has reached the server.
  IntColumn get syncSeq => integer().nullable()();

  @override
  String get tableName => 'notes';

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The spine of the sync: deletions that have to travel as tombstones (§7.3).
class Tombstones extends Table {
  /// The identifier of the tombstone.
  TextColumn get id => text()();

  /// The table the row was deleted from, e.g. `day_tags`.
  TextColumn get sourceTable => text().named('table_name')();

  /// The identifier of the row that was deleted.
  TextColumn get rowId => text()();

  /// When the row was deleted.
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// The streak of this reader (§2.3). One row per user.
class StreakStates extends Table {
  /// The identifier of the state.
  TextColumn get id => text()();

  /// The identifier of the person the streak belongs to.
  TextColumn get userId => text()();

  /// The days in a row that count right now.
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();

  /// The longest run the reader has ever had.
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();

  /// Whether the grace token is available.
  IntColumn get graceRemaining => integer().withDefault(const Constant(1))();

  /// The last day that was kept, `YYYY-MM-DD`.
  TextColumn get lastKeptDate => text().nullable()();

  /// When the row last changed.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {userId},
  ];
}

/// A day the reader chose to recover (§2.3). Recovered days count as kept, and are
/// marked as recovered.
class StreakRestorations extends Table {
  /// The identifier of the restoration.
  TextColumn get id => text()();

  /// The identifier of the person the restoration belongs to.
  TextColumn get userId => text()();

  /// The streak the restoration belongs to.
  TextColumn get streakStateId => text()();

  /// The day that was recovered, `YYYY-MM-DD`.
  TextColumn get localDate => text()();

  /// When the row was created.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {userId, localDate},
  ];
}

/// The device's own store (§7.1).
///
/// Every read the app makes comes from here and every write lands here first; the
/// network is a sync process, never a dependency of an interaction.
@DriftDatabase(
  tables: <Type>[
    LocalUsers,
    Preferences,
    SyncStates,
    Days,
    GratitudeItems,
    Tags,
    DayTags,
    Entries,
    StreakStates,
    StreakRestorations,
    DaySentiments,
    NoteRows,
    Tombstones,
  ],
)
class AppDatabase extends _$AppDatabase implements PreferencesStore {
  AppDatabase(super.e);

  /// Opens the database of the running app.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'aroel'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(days);
        await m.createTable(gratitudeItems);
        await m.createTable(tags);
        await m.createTable(dayTags);
        await m.createTable(entries);
        await m.createTable(streakStates);
        await m.createTable(streakRestorations);
      }
      if (from < 3) {
        await m.createTable(daySentiments);
        await m.createTable(noteRows);
        await m.createTable(tombstones);
      }
    },
  );

  /// The profile of this device, created on first launch if it is not there yet.
  Future<LocalUser> ensureLocalProfile({
    required String id,
    required String timeZone,
    required String locale,
    required DateTime now,
  }) async {
    final LocalUser? existing = await (select(
      localUsers,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }

    final LocalUser? any = await select(localUsers).getSingleOrNull();
    if (any != null) {
      return any;
    }

    await into(localUsers).insert(
      LocalUsersCompanion.insert(
        id: id,
        timeZone: timeZone,
        locale: locale,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return (select(localUsers)..where((row) => row.id.equals(id))).getSingle();
  }

  /// The profile of this device, when there is one.
  Future<LocalUser?> findProfile() => select(localUsers).getSingleOrNull();

  /// Links the device to an account.
  ///
  /// [adoptIdentifier] is only ever true for a device that holds no rows of its own: the
  /// identifier of the account then becomes the identifier this device writes under, and
  /// not one row has to be re-keyed.
  Future<void> linkAccount(
    String accountUserId, {
    required bool adoptIdentifier,
    required DateTime now,
  }) async {
    final LocalUser? profile = await findProfile();
    if (profile == null) {
      return;
    }

    if (adoptIdentifier && profile.id != accountUserId) {
      final LocalUser adopted = LocalUser(
        id: accountUserId,
        accountUserId: accountUserId,
        displayName: profile.displayName,
        timeZone: profile.timeZone,
        locale: profile.locale,
        hasLocalJournal: profile.hasLocalJournal,
        createdAt: profile.createdAt,
        updatedAt: now,
      );

      await transaction(() async {
        await (delete(
          localUsers,
        )..where((row) => row.id.equals(profile.id))).go();
        await into(localUsers).insert(adopted);
      });
      return;
    }

    await (update(localUsers)..where((row) => row.id.equals(profile.id))).write(
      LocalUsersCompanion(
        accountUserId: Value(accountUserId),
        updatedAt: Value(now),
      ),
    );
  }

  /// Records that the device holds rows of its own.
  Future<void> markJournalStarted(DateTime now) async {
    await update(localUsers).write(
      LocalUsersCompanion(
        hasLocalJournal: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  /// Reads a preference.
  @override
  Future<String?> readPreference(String key) async {
    final Preference? row = await (select(
      preferences,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Writes a preference.
  @override
  Future<void> writePreference(String key, String value) async {
    await into(preferences).insertOnConflictUpdate(
      PreferencesCompanion.insert(key: key, value: value),
    );
  }

  /// Removes a preference.
  @override
  Future<void> removePreference(String key) async {
    await (delete(preferences)..where((row) => row.key.equals(key))).go();
  }

  /// The cursor the last pull reached.
  Future<int> readCursor() async {
    final SyncState? row = await (select(
      syncStates,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    return row?.cursor ?? 0;
  }

  /// Writes the cursor the last pull reached.
  Future<void> writeCursor(int cursor, DateTime now) async {
    await into(syncStates).insertOnConflictUpdate(
      SyncStatesCompanion.insert(
        id: const Value<int>(1),
        cursor: Value<int>(cursor),
        lastSyncedAt: Value<DateTime>(now),
      ),
    );
  }

  /// Wipes the journal and the profile of this device.
  ///
  /// This is what deleting an account does locally: at once, and for good (§5.9). The
  /// preferences stay — they say what kind of person the reader is, not what they wrote
  /// — and the profile is made again by the next call that needs it.
  Future<void> wipeLocalData() async {
    await transaction(() async {
      await delete(tombstones).go();
      await delete(noteRows).go();
      await delete(daySentiments).go();
      await delete(streakRestorations).go();
      await delete(streakStates).go();
      await delete(entries).go();
      await delete(dayTags).go();
      await delete(tags).go();
      await delete(gratitudeItems).go();
      await delete(days).go();
      await delete(localUsers).go();
      await delete(syncStates).go();
    });
  }
}
