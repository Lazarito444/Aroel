import 'dart:async';

import 'package:aroel/core/day.dart';
import 'package:aroel/core/result.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/gratitude_card.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:aroel/ui/widgets/rating_track.dart';
import 'package:aroel/ui/widgets/tag_picker.dart';
import 'package:aroel/ui/widgets/tone_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The record of one date (§5.7): the rating, the tags, the gratitude, the tone, the
/// one-line note and the entries of that day. Reachable from the monthly grid.
///
/// A day that has not happened yet is read-only-empty, never editable.
class DayDetailScreen extends ConsumerStatefulWidget {
  const DayDetailScreen({required this.localDate, super.key});

  /// The day to show, `YYYY-MM-DD`.
  final String localDate;

  @override
  ConsumerState<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends ConsumerState<DayDetailScreen> {
  DayRecord? _record;
  List<DayTagView> _recentTags = const <DayTagView>[];
  List<EntrySummary> _entries = const <EntrySummary>[];
  final TextEditingController _note = TextEditingController();
  Timer? _noteFlush;
  String? _error;

  bool get _isFuture => widget.localDate.compareTo(ref.read(dayServiceProvider).today()) > 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _noteFlush?.cancel();
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final DayService service = ref.read(dayServiceProvider);
    final DayRecord record = await service.read(widget.localDate);
    final List<DayTagView> recentTags = await service.recentTags();
    final List<EntrySummary> entries = await service.entriesOn(widget.localDate);

    if (!mounted) {
      return;
    }
    setState(() {
      _record = record;
      _recentTags = recentTags;
      _entries = entries;
      _note.text = record.note;
      _error = null;
    });
  }

  Future<void> _mutate(Future<Result<void>> Function() action) async {
    final Result<void> result = await action();
    if (result.isFailure && mounted) {
      setState(() => _error = result.errorOrNull!.message);
    }
    await _load();
  }

  void _onNoteChanged(String text) {
    _noteFlush?.cancel();
    _noteFlush = Timer(
      const Duration(seconds: 2),
      () => unawaited(ref.read(dayServiceProvider).setNote(widget.localDate, text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final DayRecord? record = _record;

    return PaperScaffold(
      title: DateFormat('EEEE d MMMM').format(DateTime.parse(widget.localDate)),
      padding: EdgeInsets.zero,
      child: record == null
          ? const SizedBox.shrink()
          : _isFuture
          ? _FutureDay(localDate: widget.localDate)
          : ListView(
              padding: const EdgeInsets.all(Space.lg),
              children: <Widget>[
                RatingTrack(
                  value: record.ratingHalf,
                  onChanged: (int? value) => _mutate(
                    () => ref.read(dayServiceProvider).setRating(widget.localDate, value),
                  ),
                ),
                const SizedBox(height: Space.md),
                TagPicker(
                  selected: record.tags,
                  recentTags: _recentTags,
                  onToggle: (String tagId) => _mutate(
                    () => ref.read(dayServiceProvider).toggleTag(widget.localDate, tagId),
                  ),
                  onCreateAndToggle: (String label) async {
                    final Result<DayTagView> created = await ref.read(dayServiceProvider).createTag(label);
                    if (created.isSuccess) {
                      await _mutate(
                        () => ref.read(dayServiceProvider).toggleTag(widget.localDate, created.valueOrNull!.id),
                      );
                    }
                  },
                  onSearch: ref.read(dayServiceProvider).searchTags,
                ),
                const SizedBox(height: Space.xs),
                TonePicker(
                  sentimentHalf: record.sentimentHalf,
                  onChanged: (int? value) => _mutate(
                    () => ref.read(dayServiceProvider).setSentiment(widget.localDate, value),
                  ),
                ),
                const SizedBox(height: Space.xs),
                GratitudeCard(
                  lines: record.gratitude,
                  onChanged: (int position, String text) => _mutate(
                    () => ref.read(dayServiceProvider).setGratitude(widget.localDate, position, text),
                  ),
                ),
                const SizedBox(height: Space.md),
                Text('ONE LINE', style: type.label),
                const SizedBox(height: Space.xxs),
                TextField(
                  controller: _note,
                  style: type.prose.copyWith(color: tokens.palette.ink),
                  cursorColor: tokens.palette.accent,
                  onChanged: _onNoteChanged,
                  maxLength: 280,
                  decoration: InputDecoration.collapsed(
                    hintText: 'One line about the day.',
                    hintStyle: type.prose.copyWith(color: tokens.palette.inkFaint),
                    border: InputBorder.none,
                  ).copyWith(counterText: ''),
                ),
                const SizedBox(height: Space.lg),
                Row(
                  children: <Widget>[
                    Expanded(child: Text('ENTRIES', style: type.label)),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 22),
                      color: tokens.palette.accent,
                      tooltip: 'Write on this day',
                      onPressed: () => context.go('/write?date=${widget.localDate}'),
                    ),
                  ],
                ),
                if (_entries.isEmpty)
                  Text(
                    'Nothing written on this day.',
                    style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
                  ),
                for (final EntrySummary entry in _entries)
                  _EntryTile(
                    entry: entry,
                    onOpen: () => context.go('/entry/${entry.id}'),
                    onTogglePin: () => _mutate(
                      () => ref.read(dayServiceProvider).setEntryPinned(entry.id, !entry.pinned),
                    ),
                    onDelete: () => _confirmDelete(entry.id),
                  ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: Space.sm),
                  Text(_error!, style: type.uiBody.copyWith(color: tokens.palette.seal)),
                ],
              ],
            ),
    );
  }

  Future<void> _confirmDelete(String entryId) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete this entry?'),
            content: const Text('It disappears from the record and is purged after thirty days.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: PaperTokens.of(dialogContext).palette.seal),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _mutate(() => ref.read(dayServiceProvider).deleteEntry(entryId));
    }
  }
}

class _FutureDay extends StatelessWidget {
  const _FutureDay({required this.localDate});

  final String localDate;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Text(
        "This day hasn't happened yet.\n\nNothing to record, nothing to rate. It will be yours.",
        style: type.prose.copyWith(color: tokens.palette.inkSoft),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onOpen,
    required this.onTogglePin,
    required this.onDelete,
  });

  final EntrySummary entry;
  final VoidCallback onOpen;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: entry.pinned ? Icon(Icons.push_pin_rounded, size: 16, color: tokens.palette.accent) : null,
      title: Text(
        entry.snippet,
        style: type.prose.copyWith(color: tokens.palette.ink),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${entry.wordCount} words',
        style: type.caption.copyWith(color: tokens.palette.inkFaint),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              entry.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: 18,
            ),
            color: entry.pinned ? tokens.palette.accent : tokens.palette.inkFaint,
            tooltip: entry.pinned ? 'Unpin' : 'Pin',
            onPressed: onTogglePin,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: tokens.palette.inkFaint,
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onOpen,
    );
  }
}
