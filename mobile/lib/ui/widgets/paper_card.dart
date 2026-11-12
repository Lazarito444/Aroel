import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';

/// A card: paper raised, one hairline border, warm shadow (§6.3).
class PaperCard extends StatelessWidget {
  const PaperCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.borderColor,
  });

  /// The content of the card.
  final Widget child;

  /// The padding around [child].
  final EdgeInsets padding;

  /// What happens when the card is tapped.
  final VoidCallback? onTap;

  /// Whether the card is drawn as chosen.
  final bool selected;

  /// A border colour of the reader's choosing.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final Color border = borderColor ?? (selected ? palette.accent : palette.border);

    final Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.paperRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: border, width: 1),
        boxShadow: tokens.elevation.e1,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return surface;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.card),
        child: surface,
      ),
    );
  }
}
