import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A field in the app's own shape: a label above, the input sunk into the paper.
class PaperTextField extends StatefulWidget {
  const PaperTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.autofocus = false,
    this.enabled = true,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.formatters,
  });

  /// The label above the field, set in Inter.
  final String label;

  /// The controller of the field.
  final TextEditingController? controller;

  /// The placeholder inside the field.
  final String? hint;

  /// Whether the field hides what is typed into it.
  final bool obscure;

  /// The keyboard the field asks for.
  final TextInputType? keyboardType;

  /// What the keyboard's action button does.
  final TextInputAction? textInputAction;

  /// What happens when the keyboard's action button is pressed.
  final ValueChanged<String>? onSubmitted;

  /// What happens when the text changes.
  final ValueChanged<String>? onChanged;

  /// The reason the field is unhappy, shown underneath it.
  final String? errorText;

  /// Whether the field takes the focus when it appears.
  final bool autofocus;

  /// Whether the field can be typed into.
  final bool enabled;

  /// The longest text the field accepts.
  final int? maxLength;

  /// How the keyboard capitalises what is typed.
  final TextCapitalization textCapitalization;

  /// The formatters applied to what is typed.
  final List<TextInputFormatter>? formatters;

  @override
  State<PaperTextField> createState() => _PaperTextFieldState();
}

class _PaperTextFieldState extends State<PaperTextField> {
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  late final bool _ownsController = widget.controller == null;
  bool _hidden = true;

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperPalette palette = tokens.palette;
    final PaperType type = PaperType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label.toUpperCase(), style: type.label),
        const SizedBox(height: Space.xs),
        TextField(
          controller: _controller,
          obscureText: widget.obscure && _hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.formatters,
          cursorColor: palette.accent,
          cursorWidth: 1.5,
          style: type.uiBody.copyWith(color: palette.ink),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.paperSunk,
            hintText: widget.hint,
            hintStyle: type.uiBody.copyWith(color: palette.inkFaint),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Space.sm,
              vertical: Space.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.input),
              borderSide: BorderSide(color: palette.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.input),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.input),
              borderSide: BorderSide(color: palette.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.input),
              borderSide: BorderSide(color: palette.seal),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.input),
              borderSide: BorderSide(color: palette.seal, width: 1.5),
            ),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    color: palette.inkFaint,
                    tooltip: _hidden ? 'Show the password' : 'Hide the password',
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
        if (widget.errorText != null) ...<Widget>[
          const SizedBox(height: Space.xs),
          Text(
            widget.errorText!,
            style: type.uiBody.copyWith(color: palette.seal),
          ),
        ],
      ],
    );
  }
}
