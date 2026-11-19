import 'dart:async';

import 'package:aroel/core/day.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/core/streak.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_controller.freezed.dart';

/// What Today knows at this moment.
@freezed
abstract class DayState with _$DayState {
  const factory DayState({
    /// The record of today.
    required DayRecord record,

    /// Whether the record of today is still loading.
    @Default(true) bool loading,

    /// The streak as it stands.
    @Default(
      StreakSnapshot(
        current: 0,
        longest: 0,
        graceRemaining: 1,
        lastKeptDate: null,
        recoveredDates: <String>[],
      ),
    )
    StreakSnapshot streak,

    /// The most recently used tags, for the row on Today.
    @Default(<DayTagView>[]) List<DayTagView> recentTags,

    /// The two most recent entries with something on them.
    @Default(<RecentEntry>[]) List<RecentEntry> recentEntries,

    /// The sentence explaining the last failure, when there was one.
    String? errorMessage,
  }) = _DayState;
}

/// The day record of this device.
final NotifierProvider<DayController, DayState> dayControllerProvider = NotifierProvider<DayController, DayState>(DayController.new);

/// The day service of this device.
///
/// The controller is the only thing that changes the record; the screens ask it and
/// listen to it. Every mutation lands in SQLite first and refreshes from there, so what
/// the screen shows is what the store holds.
class DayController extends Notifier<DayState> {
  @override
  DayState build() {
    // Captured while the provider is alive; `ref` is off limits once it is not.
    _service = ref.read(dayServiceProvider);
    final String today = _service.today();
    unawaited(_load());
    return DayState(record: DayRecord(localDate: today));
  }

  late final DayService _service;

  Future<void> _load() async {
    final String today = _service.today();
    final DayRecord record = await _service.read(today);
    final StreakSnapshot streak = await _service.streak();
    final List<DayTagView> recentTags = await _service.recentTags();
    final List<RecentEntry> recentEntries = await _service.recentEntries();

    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(
      loading: false,
      record: record,
      streak: streak,
      recentTags: recentTags,
      recentEntries: recentEntries,
      errorMessage: null,
    );
  }

  /// Sets or clears the rating of today.
  Future<void> setRating(int? ratingHalf) async {
    final String today = _service.today();
    // Optimistic: the ramp is the hero of the screen and must feel instant (< 30 ms).
    state = state.copyWith(record: _withRating(state.record, ratingHalf));
    final Result<void> result = await _service.setRating(today, ratingHalf);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// Sets the note of today.
  Future<void> setNote(String note) async {
    final Result<void> result = await _service.setNote(_service.today(), note);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    } else {
      state = state.copyWith(record: _withNote(state.record, note));
    }
    await _refresh();
  }

  /// Sets the gratitude line at [position] (1..3) of today.
  Future<void> setGratitude(int position, String text) async {
    final Result<void> result = await _service.setGratitude(_service.today(), position, text);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// Adds or removes [tagId] on today.
  Future<void> toggleTag(String tagId) async {
    final Result<void> result = await _service.toggleTag(_service.today(), tagId);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// Creates a tag and puts it on today.
  Future<void> createTagAndToggle(String label) async {
    final Result<DayTagView> created = await _service.createTag(label);
    if (created.isFailure) {
      state = state.copyWith(errorMessage: created.errorOrNull!.message);
      return;
    }
    final Result<void> result = await _service.toggleTag(_service.today(), created.valueOrNull!.id);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// Sets or clears the tone of today (§4.6). A hand pick wins over a derived one.
  Future<void> setSentiment(int? sentimentHalf) async {
    final Result<void> result = await _service.setSentiment(_service.today(), sentimentHalf);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// The entries of [localDate], pinned first.
  Future<List<EntrySummary>> entriesOn(String localDate) => _service.entriesOn(localDate);

  /// Reads an entry by its identifier (§5.5).
  Future<EntryRead?> readEntryById(String entryId) => _service.readEntryById(entryId);

  /// Pins or unpins an entry.
  Future<void> setEntryPinned(String entryId, bool pinned) async {
    await _service.setEntryPinned(entryId, pinned);
  }

  /// Soft-deletes an entry (§5.5). It is purged after thirty days.
  Future<void> deleteEntry(String entryId) async {
    await _service.deleteEntry(entryId);
    await _refresh();
  }

  /// The stats of every day in [fromDate]..[toDate], for the review screens (§5.8).
  Future<List<DayStats>> statsRange(String fromDate, String toDate) => _service.statsRange(fromDate, toDate);

  /// Marks [localDate] as recovered (§2.3).
  Future<void> recoverDay(String localDate) async {
    final Result<void> result = await _service.recoverDay(localDate);
    if (result.isFailure) {
      state = state.copyWith(errorMessage: result.errorOrNull!.message);
    }
    await _refresh();
  }

  /// Reads the days the streak can recover, most recent first.
  Future<List<String>> recoverableDays() => _service.recoverableDays();

  /// Tags whose label contains [query], for the sheet.
  Future<List<DayTagView>> searchTags(String query) => _service.searchTags(query);

  Future<void> _refresh() async {
    final String today = _service.today();
    final DayRecord record = await _service.read(today);
    final StreakSnapshot streak = await _service.streak();
    final List<DayTagView> recentTags = await _service.recentTags();
    final List<RecentEntry> recentEntries = await _service.recentEntries();

    if (!ref.mounted) {
      return;
    }

    state = state.copyWith(
      loading: false,
      record: record,
      streak: streak,
      recentTags: recentTags,
      recentEntries: recentEntries,
    );
  }

  DayRecord _withRating(DayRecord record, int? ratingHalf) => DayRecord(
    localDate: record.localDate,
    ratingHalf: ratingHalf,
    note: record.note,
    gratitude: record.gratitude,
    tags: record.tags,
    wordCount: record.wordCount,
  );

  DayRecord _withNote(DayRecord record, String note) => DayRecord(
    localDate: record.localDate,
    ratingHalf: record.ratingHalf,
    note: note,
    gratitude: record.gratitude,
    tags: record.tags,
    wordCount: record.wordCount,
  );
}
