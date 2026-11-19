import 'dart:async';

import 'package:aroel/core/notes.dart';
import 'package:aroel/core/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_controller.freezed.dart';

/// What the shelf knows at this moment.
@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState({
    /// Whether the shelf is still loading.
    @Default(true) bool loading,

    /// The live notes, pinned first, then newest first.
    @Default(<Note>[]) List<Note> notes,

    /// The sentence explaining the last failure, when there was one.
    String? errorMessage,
  }) = _NotesState;
}

/// The shelf of this device (§5.6).
///
/// The controller is the only thing that changes the notes; the screens ask it and
/// listen to it. Every mutation lands in SQLite first and refreshes from there.
class NoteController extends Notifier<NotesState> {
  @override
  NotesState build() {
    // Captured while the provider is alive; `ref` is off limits once it is not.
    _notes = ref.read(noteServiceProvider);
    unawaited(_load());
    return const NotesState();
  }

  late final NoteService _notes;

  Future<void> _load() async {
    final List<Note> notes = await _notes.list();
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(loading: false, notes: notes);
  }

  /// Makes an empty note and returns it.
  Future<Note?> create() async {
    final Result<Note> result = await _notes.create();
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
      return null;
    }
    await _load();
    return result.valueOrNull;
  }

  /// Writes the title and the body of a note.
  Future<void> write(String id, {required String body, String title = ''}) async {
    final Result<void> result = await _notes.write(id, title: title, body: body);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _load();
  }

  /// Pins or unpins a note.
  Future<void> setPinned(String id, bool pinned) async {
    await _notes.setPinned(id, pinned);
    await _load();
  }

  /// Soft-deletes a note (§5.5). It is purged after thirty days.
  Future<void> delete(String id) async {
    await _notes.delete(id);
    await _load();
  }
}

/// The shelf of this device.
final NotifierProvider<NoteController, NotesState> noteControllerProvider = NotifierProvider<NoteController, NotesState>(NoteController.new);
