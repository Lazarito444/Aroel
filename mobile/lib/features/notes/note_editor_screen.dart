import 'dart:async';

import 'package:aroel/core/note_controller.dart';
import 'package:aroel/core/notes.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The note editor (§5.6): one editor, no date field, by design.
///
/// Every keystroke lands in SQLite with a two-second debounced flush; back keeps the text.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({required this.id, super.key});

  /// The note to edit.
  final String id;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  Timer? _flush;
  bool _pinned = false;
  bool _loaded = false;

  // Captured up front: `ref` is off limits once the widget is going away.
  late final NoteService _service = ref.read(noteServiceProvider);
  late final NoteController _controller = ref.read(noteControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final Note? note = await _service.read(widget.id);
    if (note == null || !mounted) {
      return;
    }
    setState(() {
      _title.text = note.title;
      _body.text = note.body;
      _pinned = note.pinned;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _flush?.cancel();
    unawaited(_save());
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _onChanged() {
    _flush?.cancel();
    _flush = Timer(const Duration(seconds: 2), () => unawaited(_save()));
  }

  Future<void> _save() => _controller.write(
    widget.id,
    title: _title.text,
    body: _body.text,
  );

  Future<void> _togglePin() async {
    await _controller.setPinned(widget.id, !_pinned);
    if (mounted) {
      setState(() => _pinned = !_pinned);
    }
  }

  Future<void> _delete() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete this note?'),
            content: const Text('It disappears from the shelf and is purged after thirty days.'),
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
      await _controller.delete(widget.id);
      if (mounted) {
        context.go('/notes');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Note',
      padding: EdgeInsets.zero,
      actions: <Widget>[
        IconButton(
          icon: Icon(_pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined, size: 20),
          color: _pinned ? tokens.palette.accent : tokens.palette.inkFaint,
          tooltip: _pinned ? 'Unpin' : 'Pin',
          onPressed: _togglePin,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 20),
          color: tokens.palette.inkFaint,
          tooltip: 'Delete',
          onPressed: _delete,
        ),
      ],
      child: !_loaded
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(Space.lg),
              children: <Widget>[
                TextField(
                  controller: _title,
                  style: type.pageTitle.copyWith(color: tokens.palette.ink),
                  cursorColor: tokens.palette.accent,
                  onChanged: (_) => _onChanged(),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Title',
                    hintStyle: type.pageTitle.copyWith(color: tokens.palette.inkFaint),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: Space.sm),
                TextField(
                  controller: _body,
                  style: type.prose.copyWith(color: tokens.palette.ink),
                  cursorColor: tokens.palette.accent,
                  minLines: 8,
                  maxLines: null,
                  onChanged: (_) => _onChanged(),
                  decoration: InputDecoration.collapsed(
                    hintText: 'The thing that has no date.',
                    hintStyle: type.prose.copyWith(color: tokens.palette.inkFaint),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
    );
  }
}
