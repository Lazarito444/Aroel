import 'package:aroel/core/note_controller.dart';
import 'package:aroel/core/notes.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// The shelf (§5.6): pinned first, then newest first. A note has no date.
class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotesState state = ref.watch(noteControllerProvider);
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Notes',
      padding: EdgeInsets.zero,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_rounded, size: 22),
          color: tokens.palette.accent,
          tooltip: 'New note',
          onPressed: () => _createAndOpen(context, ref),
        ),
      ],
      child: state.loading
          ? const SizedBox.shrink()
          : state.notes.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Text(
                'Nothing on the shelf yet.\n\nA note is for the things that have no date. Pin the ones you reach for.',
                style: type.prose.copyWith(color: tokens.palette.inkSoft),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(Space.md),
              children: <Widget>[
                for (final Note note in state.notes)
                  _NoteTile(
                    note: note,
                    onTap: () => context.go('/notes/${note.id}'),
                    onTogglePin: () => ref.read(noteControllerProvider.notifier).setPinned(note.id, !note.pinned),
                  ),
              ],
            ),
    );
  }

  Future<void> _createAndOpen(BuildContext context, WidgetRef ref) async {
    final Note? note = await ref.read(noteControllerProvider.notifier).create();
    if (note != null && context.mounted) {
      context.go('/notes/${note.id}');
    }
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onTap, required this.onTogglePin});

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);
    final String firstLine = note.body.split('\n').firstWhere((String line) => line.trim().isNotEmpty, orElse: () => '');
    final String title = note.title.trim().isNotEmpty ? note.title : (firstLine.isEmpty ? 'Untitled' : firstLine);
    final String snippet = firstLine.isEmpty ? '' : (firstLine.length > 90 ? '${firstLine.substring(0, 87)}...' : firstLine);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.chip),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.sm),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tokens.palette.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (note.pinned) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: Space.xs, top: 2),
                  child: Icon(Icons.push_pin_rounded, size: 14, color: tokens.palette.accent),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: type.pageTitle.copyWith(color: tokens.palette.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (snippet.isNotEmpty && snippet != title) ...<Widget>[
                      const SizedBox(height: Space.xxs),
                      Text(
                        snippet,
                        style: type.uiBody.copyWith(color: tokens.palette.inkSoft),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: Space.xxs),
                    Text(
                      '${DateFormat('d MMM').format(note.updatedAt.toLocal())} · ${note.wordCount} words',
                      style: type.caption.copyWith(color: tokens.palette.inkFaint),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  note.pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: 18,
                ),
                color: note.pinned ? tokens.palette.accent : tokens.palette.inkFaint,
                tooltip: note.pinned ? 'Unpin' : 'Pin',
                onPressed: onTogglePin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
