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
  BoolColumn get hasLocalJournal =>
      boolean().withDefault(const Constant(false))();

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

/// The device's own store (§7.1).
///
/// Every read the app makes comes from here and every write lands here first; the
/// network is a sync process, never a dependency of an interaction.
@DriftDatabase(tables: <Type>[LocalUsers, Preferences, SyncStates])
class AppDatabase extends _$AppDatabase implements PreferencesStore {
  AppDatabase(super.e);

  /// Opens the database of the running app.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'aroel'));

  @override
  int get schemaVersion => 1;

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
      await delete(localUsers).go();
      await delete(syncStates).go();
    });
  }
}
