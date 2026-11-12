import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';

/// The kinds of action the app offers.
enum PaperButtonVariant {
  /// The one action a screen wants.
  primary,

  /// A second action, drawn on paper.
  secondary,

  /// An action that destroys something.
  destructive,

  /// A link-like action with no surface.
  quiet,
}

/// A button in the app's own shape.
///
/// A press scales the button to .98 for 120 ms (§6.4). There is no ripple: the paper does
/// not splash.
class PaperButton extends StatefulWidget {
  const PaperButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = PaperButtonVariant.primary,
    this.busy = false,
    this.expand = true,
    this.leading,
  });

  /// The words on the button.
  final String label;

  /// What happens when the button is pressed. A null value disables the button.
  final VoidCallback? onPressed;

  /// The kind of action.
  final PaperButtonVariant variant;

  /// Whether the button is waiting for something to finish.
  final bool busy;

  /// Whether the button takes the width of its parent.
  final bool expand;

  /// A small mark in front of the words.
  final Widget? leading;

  @override
  State<PaperButton> createState() => _PaperButtonState();
}

class _PaperButtonState extends State<PaperButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.busy;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;

    final (
      Color background,
      Color foreground,
      Color? border,
    ) = switch (widget.variant) {
      PaperButtonVariant.primary => (palette.accent, palette.paper, null),
      PaperButtonVariant.secondary => (palette.paperSunk, palette.ink, null),
      PaperButtonVariant.destructive => (palette.seal, palette.paper, null),
      PaperButtonVariant.quiet => (Colors.transparent, palette.accent, null),
    };

    final Widget content = widget.busy
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.leading != null) ...<Widget>[
                widget.leading!,
                const SizedBox(width: Space.xs),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: PaperType.of(context).uiBodyStrong.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );

    final Widget button = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.input),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        child: SizedBox(height: 20, child: Center(child: content)),
      ),
    );

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: Motion.press,
      curve: Curves.easeOut,
      child: Semantics(
        button: true,
        enabled: _enabled,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTap: _enabled ? widget.onPressed : null,
          child: widget.expand ? SizedBox(width: double.infinity, child: button) : button,
        ),
      ),
    );
  }
}
