import 'package:aroel/core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A note (§4.2, §5.6): a thing with no date, the shelf.
class Note {
  /// Creates a note view.
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.wordCount,
    required this.pinned,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The identifier of the note.
  final String id;

  /// The title, when there is one.
  final String title;

  /// The markdown-lite body.
  final String body;

  /// The number of words in the body.
  final int wordCount;

  /// Whether the note is pinned. Pinned notes float to the top.
  final bool pinned;

  /// When the note was created, in UTC.
  final DateTime createdAt;

  /// When the note last changed, in UTC.
  final DateTime updatedAt;
}

/// The notes shelf as the app reads and writes it (§5.6).
///
/// The port lives in `core`; the data layer implements it, and the app wires the two
/// together. Notes never touch the streak and never appear in day analytics.
abstract interface class NoteService {
  /// Today, as `YYYY-MM-DD` in the device's own timezone.
  String today();

  /// Lists the live notes: pinned first, then newest first.
  Future<List<Note>> list();

  /// Reads one note.
  Future<Note?> read(String id);

  /// Makes an empty note and returns it.
  Future<Result<Note>> create();

  /// Writes the title and the body of a note.
  Future<Result<void>> write(String id, {required String body, String title = ''});

  /// Pins or unpins a note.
  Future<Result<void>> setPinned(String id, bool pinned);

  /// Soft-deletes a note (§5.5, §5.6). It is purged after thirty days.
  Future<Result<void>> delete(String id);
}

/// The note service of this device.
///
/// The app wires the real service at launch; until it does, the shelf is not there.
final Provider<NoteService> noteServiceProvider = Provider<NoteService>(
  (Ref ref) => throw StateError(
    'The note service has to be wired before the app starts.',
  ),
);
