import 'package:aroel/data/local/app_database.dart';

/// The profile of this device, made on first use if it is not there yet.
///
/// Both repositories need the identifier the device writes its rows under. The rule lives
/// once here: an existing profile is returned as it is; a missing one is made under a
/// fresh identifier.
Future<LocalUser> ensureLocalProfile({
  required AppDatabase database,
  required String Function() newId,
  required String timeZone,
  required String locale,
  required DateTime now,
}) async {
  final LocalUser? existing = await database.findProfile();
  if (existing != null) {
    return existing;
  }

  return database.ensureLocalProfile(
    id: newId(),
    timeZone: timeZone,
    locale: locale,
    now: now,
  );
}
