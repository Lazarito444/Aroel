import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';

/// A choice the reader makes, offered as a row on paper.
class PaperOption extends StatelessWidget {
  const PaperOption({
    required this.title,
    required this.onTap,
    super.key,
    this.description,
    this.selected = false,
  });

  /// The words that name the choice.
  final String title;

  /// A line that says what the choice is for.
  final String? description;

  /// What happens when the choice is taken.
  final VoidCallback onTap;

  /// Whether the choice is the one that has been taken.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final PaperType type = PaperType.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Space.md),
          decoration: BoxDecoration(
            color: palette.paperRaised,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(
              color: selected ? palette.accent : palette.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: tokens.elevation.e1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: type.uiBodyStrong.copyWith(color: palette.ink),
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: Space.xxs),
                      Text(
                        description!,
                        style: type.uiBody.copyWith(color: palette.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: Space.sm),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? palette.accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? palette.accent : palette.border,
                    width: 1.5,
                  ),
                ),
                child: selected ? Icon(Icons.check_rounded, size: 12, color: palette.paper) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
