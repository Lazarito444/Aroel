import 'package:aroel/core/day.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_sheet.dart';
import 'package:aroel/ui/widgets/paper_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The tag row of a day (§5.3): the five most recently used tags plus a way to add one.
///
/// Selected tags lead, then recent ones not yet on the day. The count on the trailing
/// edge shows how many of the five slots the day carries.
class TagPicker extends ConsumerWidget {
  const TagPicker({
    required this.selected,
    required this.recentTags,
    required this.onToggle,
    required this.onCreateAndToggle,
    required this.onSearch,
    super.key,
  });

  /// The tags on the day, most recently added first.
  final List<DayTagView> selected;

  /// The most recently used tags, for the row.
  final List<DayTagView> recentTags;

  /// What happens when a tag is tapped.
  final ValueChanged<String> onToggle;

  /// What happens when a new tag is made and put on the day.
  final ValueChanged<String> onCreateAndToggle;

  /// The search behind the sheet, given what the reader typed.
  final Future<List<DayTagView>> Function(String query) onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    final Set<String> onDay = selected.map((DayTagView tag) => tag.id).toSet();
    final List<DayTagView> row = <DayTagView>[
      ...selected,
      ...recentTags.where((DayTagView tag) => !onDay.contains(tag.id)),
    ].take(5).toList();

    return Row(
      children: <Widget>[
        for (final DayTagView tag in row)
          Padding(
            padding: const EdgeInsets.only(right: Space.xs),
            child: _TagChip(
              label: tag.label,
              selected: onDay.contains(tag.id),
              onTap: () => onToggle(tag.id),
            ),
          ),
        _TagChip(
          label: '+',
          selected: false,
          onTap: () => _showSheet(context),
        ),
        const Spacer(),
        if (selected.isNotEmpty)
          Text(
            '${selected.length}/5',
            style: type.caption.copyWith(color: tokens.palette.inkFaint),
          ),
      ],
    );
  }

  Future<void> _showSheet(BuildContext context) async {
    await showPaperSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => _TagSheet(
        selected: selected,
        onSearch: onSearch,
        onCreateAndToggle: onCreateAndToggle,
        onToggle: onToggle,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.chip),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? tokens.palette.sage.withValues(alpha: 0.18) : tokens.palette.paperSunk,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(
              color: selected ? tokens.palette.sage : tokens.palette.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xxs),
            child: Text(
              label,
              style: type.uiBodyStrong.copyWith(
                color: selected ? tokens.palette.sage : tokens.palette.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagSheet extends StatefulWidget {
  const _TagSheet({
    required this.selected,
    required this.onSearch,
    required this.onCreateAndToggle,
    required this.onToggle,
  });

  final List<DayTagView> selected;
  final Future<List<DayTagView>> Function(String query) onSearch;
  final ValueChanged<String> onCreateAndToggle;
  final ValueChanged<String> onToggle;

  @override
  State<_TagSheet> createState() => _TagSheetState();
}

class _TagSheetState extends State<_TagSheet> {
  final TextEditingController _query = TextEditingController();
  List<DayTagView> _results = const <DayTagView>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final List<DayTagView> results = await widget.onSearch(query);
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PaperType type = PaperType.of(context);
    final PaperTokens tokens = PaperTokens.of(context);
    final Set<String> onDay = widget.selected.map((DayTagView tag) => tag.id).toSet();
    final String query = _query.text.trim();
    final bool exactExists = _results.any((DayTagView tag) => tag.label.toLowerCase() == query.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const PaperSheetTitle('Tags for this day', subtitle: 'Context, not category. Five is enough.'),
        const SizedBox(height: Space.md),
        PaperTextField(
          label: 'Tag',
          hint: 'work, family, outside...',
          controller: _query,
          autofocus: true,
          onChanged: _search,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: Space.sm),
        if (query.isNotEmpty && !exactExists && !_loading)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add, size: 20, color: tokens.palette.accent),
              title: Text(
                'Create \'$query\'',
                style: type.uiBodyStrong.copyWith(color: tokens.palette.accent),
              ),
              onTap: () {
                widget.onCreateAndToggle(query);
                Navigator.of(context).pop();
              },
            ),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (final DayTagView tag in _results)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    tag.label,
                    style: type.uiBody.copyWith(color: tokens.palette.ink),
                  ),
                  trailing: Icon(
                    onDay.contains(tag.id) ? Icons.check_rounded : Icons.add,
                    size: 20,
                    color: onDay.contains(tag.id) ? tokens.palette.sage : tokens.palette.inkFaint,
                  ),
                  onTap: () {
                    widget.onToggle(tag.id);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
