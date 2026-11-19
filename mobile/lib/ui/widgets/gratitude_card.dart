import 'dart:async';

import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_card.dart';
import 'package:material_ui/material_ui.dart';

/// The three small things (§5.3). Optional, autosaved, a tick when a line is filled.
///
/// Lines are saved on focus loss and on a two-second debounce while the reader types.
class GratitudeCard extends StatefulWidget {
  const GratitudeCard({
    required this.lines,
    required this.onChanged,
    super.key,
  });

  /// The three lines as the store holds them; an empty string is an unwritten line.
  final List<String> lines;

  /// What happens when a line is written, at position one to three.
  final void Function(int position, String text) onChanged;

  @override
  State<GratitudeCard> createState() => _GratitudeCardState();
}

class _GratitudeCardState extends State<GratitudeCard> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      3,
      (int index) => TextEditingController(text: widget.lines[index]),
    );
    _focusNodes = List<FocusNode>.generate(3, (int _) => FocusNode());
    for (int index = 0; index < 3; index++) {
      final int line = index;
      _focusNodes[line].addListener(() {
        if (!_focusNodes[line].hasFocus) {
          _save(line);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant GratitudeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (int index = 0; index < 3; index++) {
      if (!_focusNodes[index].hasFocus && _controllers[index].text != widget.lines[index]) {
        _controllers[index].text = widget.lines[index];
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _save(int line) {
    widget.onChanged(line + 1, _controllers[line].text);
  }

  void _onChanged(int line) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => _save(line));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('THREE SMALL THINGS', style: type.label),
          const SizedBox(height: Space.sm),
          for (int index = 0; index < 3; index++) ...<Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: Space.md,
                  child: _controllers[index].text.trim().isNotEmpty
                      ? Icon(Icons.check_rounded, size: 16, color: tokens.palette.sage)
                      : Text(
                          '${index + 1}.',
                          style: type.caption.copyWith(color: tokens.palette.inkFaint),
                        ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    style: type.prose.copyWith(color: tokens.palette.ink),
                    onChanged: (_) => _onChanged(index),
                    decoration: const InputDecoration.collapsed(
                      hintText: 'A small thing',
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: null,
                  ),
                ),
              ],
            ),
            if (index < 2) Divider(height: Space.md, thickness: 1, color: tokens.palette.border),
          ],
        ],
      ),
    );
  }
}
