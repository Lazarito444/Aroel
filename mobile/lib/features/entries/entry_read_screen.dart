import 'dart:async';

import 'package:aroel/core/day.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/markdown_lite.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The entry read view (§5.5): serif prose on paper, metadata footer, edit and delete.
class EntryReadScreen extends ConsumerStatefulWidget {
  const EntryReadScreen({required this.id, super.key});

  /// The entry to read.
  final String id;

  @override
  ConsumerState<EntryReadScreen> createState() => _EntryReadScreenState();
}

class _EntryReadScreenState extends ConsumerState<EntryReadScreen> {
  EntryRead? _entry;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final EntryRead? entry = await ref.read(dayServiceProvider).readEntryById(widget.id);
    if (mounted) {
      setState(() => _entry = entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final EntryRead? entry = _entry;

    return PaperScaffold(
      title: 'Entry',
      padding: EdgeInsets.zero,
      actions: <Widget>[
        if (entry != null) ...<Widget>[
          IconButton(
            icon: Icon(
              entry.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              size: 20,
            ),
            color: entry.pinned ? tokens.palette.accent : tokens.palette.inkFaint,
            tooltip: entry.pinned ? 'Unpin' : 'Pin',
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: tokens.palette.inkFaint,
            tooltip: 'Edit',
            onPressed: () => context.go('/write?date=${entry.localDate}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: tokens.palette.inkFaint,
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ],
      child: entry == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(Space.lg),
              children: <Widget>[
                MarkdownLite(entry.body),
                const SizedBox(height: Space.xl),
                Divider(height: 1, color: tokens.palette.border),
                const SizedBox(height: Space.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        DateFormat('EEEE d MMMM yyyy').format(DateTime.parse(entry.localDate)),
                        style: type.caption.copyWith(color: tokens.palette.inkFaint),
                      ),
                    ),
                    Text(
                      '${entry.wordCount} words',
                      style: type.caption.copyWith(color: tokens.palette.inkFaint),
                    ),
                  ],
                ),
                if (entry.sentimentHalf != null || entry.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Space.xs),
                  Row(
                    children: <Widget>[
                      if (entry.sentimentHalf != null)
                        Padding(
                          padding: const EdgeInsets.only(right: Space.sm),
                          child: Text(
                            'Tone · ${DayTone.at(entry.sentimentHalf)?.label ?? ''}',
                            style: type.caption.copyWith(color: tokens.palette.inkFaint),
                          ),
                        ),
                      for (final DayTagView tag in entry.tags)
                        Padding(
                          padding: const EdgeInsets.only(right: Space.xs),
                          child: Text(
                            '#${tag.label}',
                            style: type.caption.copyWith(color: tokens.palette.inkFaint),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _togglePin() async {
    final EntryRead? entry = _entry;
    if (entry == null) {
      return;
    }
    await ref.read(dayServiceProvider).setEntryPinned(entry.id, !entry.pinned);
    await _load();
  }

  Future<void> _confirmDelete() async {
    final EntryRead? entry = _entry;
    if (entry == null) {
      return;
    }

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
      await ref.read(dayServiceProvider).deleteEntry(entry.id);
      if (mounted) {
        context.go('/day/${entry.localDate}');
      }
    }
  }
}
