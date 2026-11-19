import 'package:aroel/core/clock.dart';
import 'package:aroel/core/notes.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/data/local/app_database.dart';
import 'package:aroel/data/repositories/note_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late NoteRepository notes;
  int counter = 0;

  setUp(() {
    counter = 0;
    database = AppDatabase(NativeDatabase.memory());
    notes = NoteRepository(
      database: database,
      clock: FixedClock(DateTime.utc(2026, 11, 18, 9)),
      newId: () {
        counter++;
        final String tail = counter.toRadixString(16).padLeft(12, '0');
        return '0192f3a4-5b6c-7d8e-9f0a-$tail';
      },
      deviceTimeZone: 'Europe/Madrid',
      deviceLocale: 'en-GB',
      localNow: () => DateTime(2026, 11, 18, 21),
    );
  });

  tearDown(() => database.close());

  test('a note is made, written and read back with a word count', () async {
    final Result<Note> created = await notes.create();
    expect(created.isSuccess, isTrue);

    await notes.write(created.valueOrNull!.id, title: 'packing', body: 'the blue bag holds it all');

    final Note? read = await notes.read(created.valueOrNull!.id);
    expect(read!.title, 'packing');
    expect(read.wordCount, 6);
  });

  test('pinned notes come first, then the newest', () async {
    final Result<Note> first = await notes.create();
    await notes.write(first.valueOrNull!.id, body: 'first note');
    final Result<Note> second = await notes.create();
    await notes.write(second.valueOrNull!.id, body: 'second note');

    await notes.setPinned(first.valueOrNull!.id, true);

    final List<Note> listed = await notes.list();
    expect(listed.first.id, first.valueOrNull!.id);
  });

  test('a deleted note is gone from the shelf and cannot be read', () async {
    final Result<Note> created = await notes.create();
    await notes.write(created.valueOrNull!.id, body: 'gone soon');

    await notes.delete(created.valueOrNull!.id);

    expect(await notes.read(created.valueOrNull!.id), isNull);
    expect((await notes.list()).any((Note note) => note.id == created.valueOrNull!.id), isFalse);
  });

  test('a list skips deleted notes but keeps live ones', () async {
    final Result<Note> live = await notes.create();
    await notes.write(live.valueOrNull!.id, body: 'stays');
    final Result<Note> dead = await notes.create();
    await notes.write(dead.valueOrNull!.id, body: 'goes');

    await notes.delete(dead.valueOrNull!.id);

    final List<Note> listed = await notes.list();
    expect(listed, hasLength(1));
    expect(listed.single.body, 'stays');
  });
}
