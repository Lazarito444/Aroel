import 'package:aroel/core/markdown_lite.dart';
import 'package:aroel/ui/paper_theme.dart';
import 'package:aroel/ui/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// The markdown-lite renderer for entries (§5.4).
///
/// Bold, italic, headings, lists and quotes; everything else is prose. Newsreader all
/// the way down, because this is the user's own writing.
class MarkdownLite extends StatelessWidget {
  const MarkdownLite(this.source, {super.key});

  /// The text to render.
  final String source;

  @override
  Widget build(BuildContext context) {
    final PaperTokens tokens = PaperTokens.of(context);
    final PaperType type = PaperType.of(context);

    final TextStyle prose = type.prose.copyWith(color: tokens.palette.ink);
    final List<MarkdownBlock> blocks = parseMarkdownLite(source);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final MarkdownBlock block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: _BlockView(block: block, type: type, tokens: tokens, prose: prose),
          ),
      ],
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.type, required this.tokens, required this.prose});

  final MarkdownBlock block;
  final PaperType type;
  final PaperTokens tokens;
  final TextStyle prose;

  @override
  Widget build(BuildContext context) {
    switch (block) {
      case MarkdownHeading(:final level, :final text):
        return Text(
          text,
          style: switch (level) {
            1 => type.display,
            2 => type.pageTitle,
            _ => prose.copyWith(fontWeight: FontWeight.w600),
          },
        );
      case MarkdownQuote(:final text):
        return Container(
          padding: const EdgeInsets.only(left: Space.sm),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: tokens.palette.border, width: 2)),
          ),
          child: Text.rich(parseInline(text), style: type.proseItalic.copyWith(color: tokens.palette.inkSoft)),
        );
      case MarkdownBullet(:final text):
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('·', style: prose),
            ),
            const SizedBox(width: Space.xs),
            Expanded(child: Text.rich(parseInline(text), style: prose)),
          ],
        );
      case MarkdownParagraph(:final text):
        return Text.rich(parseInline(text), style: prose);
    }
  }

  InlineSpan parseInline(String line) {
    return TextSpan(
      children: <InlineSpan>[
        for (final MarkdownRun run in parseInlineRuns(line))
          TextSpan(
            text: run.text,
            style: TextStyle(
              fontWeight: run.bold ? FontWeight.w600 : null,
              fontStyle: run.italic ? FontStyle.italic : null,
            ),
          ),
      ],
    );
  }
}
