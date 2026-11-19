import 'dart:async';

import 'package:aroel/core/day.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:aroel/ui/widgets/paper_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The editor (§5.4).
///
/// The entry attaches to the day it was written on, even at 00:30. Every keystroke lands
/// in SQLite with a two-second debounced flush; back navigation keeps the text, because
/// the text is already saved wherever you navigate to.
class WriteScreen extends ConsumerStatefulWidget {
  const WriteScreen({super.key, this.localDate});

  /// The day the entry belongs to; `null` means today.
  final String? localDate;

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  final TextEditingController _body = TextEditingController();
  Timer? _flush;
  int _words = 0;
  bool _loaded = false;

  // Captured up front: `ref` is off limits once the widget is going away.
  late final DayService _service = ref.read(dayServiceProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final DayService service = _service;
    final String day = widget.localDate ?? service.today();
    final DayEntry? entry = await service.readEntry(day);
    if (!mounted) {
      return;
    }
    setState(() {
      _body.text = entry?.body ?? '';
      _words = entry?.wordCount ?? 0;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _flush?.cancel();
    unawaited(_save(_body.text));
    _body.dispose();
    super.dispose();
  }

  void _onChanged(String body) {
    _flush?.cancel();
    _flush = Timer(const Duration(seconds: 2), () => unawaited(_save(body)));
    setState(() => _words = _countWords(body));
  }

  Future<void> _save(String body) async {
    final DayService service = _service;
    await service.writeEntry(widget.localDate ?? service.today(), body);
  }

  int _countWords(String text) {
    int count = 0;
    bool inside = false;
    for (final int codeUnit in text.codeUnits) {
      if (_isWhiteSpace(codeUnit)) {
        inside = false;
      } else if (!inside) {
        inside = true;
        count++;
      }
    }
    return count;
  }

  bool _isWhiteSpace(int codeUnit) => codeUnit == 0x20 || codeUnit == 0x09 || codeUnit == 0x0A || codeUnit == 0x0D;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    return PaperScaffold(
      title: 'Write',
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: Space.md),
          child: Center(
            child: Text(
              _words == 0 ? '' : '$_words words',
              style: type.caption.copyWith(color: tokens.palette.inkFaint),
            ),
          ),
        ),
      ],
      child: !_loaded
          ? const SizedBox.shrink()
          : TextField(
              controller: _body,
              autofocus: true,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: type.prose.copyWith(color: tokens.palette.ink),
              cursorColor: tokens.palette.accent,
              onChanged: _onChanged,
              decoration: const InputDecoration.collapsed(hintText: 'However this day was.').copyWith(
                hintStyle: type.prose.copyWith(color: tokens.palette.inkFaint),
              ),
            ),
    );
  }
}
