/// Markdown-lite, the way Aroel writes entries (§5.4).
///
/// Bold, italic, headings, lists and quotes. Nothing else, on purpose: the editor stores
/// the text verbatim, and the reading view adds only this much styling back. The parser
/// is pure and deterministic so it can be tested without a widget.
sealed class MarkdownBlock {
  const MarkdownBlock();
}

/// A heading, `#` to `###`.
class MarkdownHeading extends MarkdownBlock {
  /// Creates a heading.
  const MarkdownHeading(this.level, this.text);

  /// The heading level, 1 to 3.
  final int level;

  /// The heading text, without the markers.
  final String text;
}

/// A quotation, `> text`.
class MarkdownQuote extends MarkdownBlock {
  /// Creates a quote.
  const MarkdownQuote(this.text);

  /// The quoted text.
  final String text;
}

/// A list item, `- text` or `* text`.
class MarkdownBullet extends MarkdownBlock {
  /// Creates a bullet.
  const MarkdownBullet(this.text);

  /// The item text.
  final String text;
}

/// A paragraph, any other non-blank line.
class MarkdownParagraph extends MarkdownBlock {
  /// Creates a paragraph.
  const MarkdownParagraph(this.text);

  /// The paragraph text.
  final String text;
}

/// One run of text inside a block, with its weight and slant.
class MarkdownRun {
  /// Creates a run.
  const MarkdownRun(this.text, {this.bold = false, this.italic = false});

  /// The text of the run.
  final String text;

  /// Whether the run is bold (`**text**`).
  final bool bold;

  /// Whether the run is italic (`*text*`).
  final bool italic;
}

/// Parses markdown-lite into blocks.
///
/// Lines are trimmed; blank lines separate paragraphs. Unknown markers are treated as
/// prose, never as code.
List<MarkdownBlock> parseMarkdownLite(String source) {
  final List<MarkdownBlock> blocks = <MarkdownBlock>[];

  for (final String raw in source.split('\n')) {
    final String line = raw.trim();
    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('### ')) {
      blocks.add(MarkdownHeading(3, line.substring(4)));
      continue;
    }
    if (line.startsWith('## ')) {
      blocks.add(MarkdownHeading(2, line.substring(3)));
      continue;
    }
    if (line.startsWith('# ')) {
      blocks.add(MarkdownHeading(1, line.substring(2)));
      continue;
    }
    if (line.startsWith('> ')) {
      blocks.add(MarkdownQuote(line.substring(2)));
      continue;
    }
    if (line.startsWith('- ') || line.startsWith('* ')) {
      blocks.add(MarkdownBullet(line.substring(2)));
      continue;
    }

    blocks.add(MarkdownParagraph(line));
  }

  return blocks;
}

/// Parses the inline emphasis of one line.
List<MarkdownRun> parseInlineRuns(String line) {
  final List<MarkdownRun> runs = <MarkdownRun>[];
  final RegExp pattern = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
  int index = 0;

  for (final RegExpMatch match in pattern.allMatches(line)) {
    if (match.start > index) {
      runs.add(MarkdownRun(line.substring(index, match.start)));
    }

    final String token = match.group(0)!;
    if (token.startsWith('**')) {
      runs.add(MarkdownRun(token.substring(2, token.length - 2), bold: true));
    } else {
      runs.add(MarkdownRun(token.substring(1, token.length - 1), italic: true));
    }

    index = match.end;
  }

  if (index < line.length) {
    runs.add(MarkdownRun(line.substring(index)));
  }

  if (runs.isEmpty) {
    runs.add(const MarkdownRun(''));
  }

  return runs;
}
