import 'package:aroel/core/markdown_lite.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMarkdownLite', () {
    test('a plain line is a paragraph', () {
      final List<MarkdownBlock> blocks = parseMarkdownLite('a quiet morning');

      expect(blocks, hasLength(1));
      expect(blocks.single, isA<MarkdownParagraph>());
      expect((blocks.single as MarkdownParagraph).text, 'a quiet morning');
    });

    test('headings, quotes and bullets are recognised', () {
      final List<MarkdownBlock> blocks = parseMarkdownLite(
        '# the day\n## a section\n### a note\n> something bigger\n- tea\n* walk',
      );

      expect(blocks[0], isA<MarkdownHeading>());
      expect((blocks[0] as MarkdownHeading).level, 1);
      expect((blocks[1] as MarkdownHeading).level, 2);
      expect((blocks[2] as MarkdownHeading).level, 3);
      expect(blocks[3], isA<MarkdownQuote>());
      expect(blocks[4], isA<MarkdownBullet>());
      expect(blocks[5], isA<MarkdownBullet>());
    });

    test('blank lines separate paragraphs without becoming blocks', () {
      final List<MarkdownBlock> blocks = parseMarkdownLite('one\n\ntwo');

      expect(blocks, hasLength(2));
    });

    test('leading markers in the middle of a line are prose', () {
      final List<MarkdownBlock> blocks = parseMarkdownLite('well # this is not a heading');

      expect(blocks.single, isA<MarkdownParagraph>());
    });
  });

  group('parseInlineRuns', () {
    test('bold and italic are split out', () {
      final List<MarkdownRun> runs = parseInlineRuns('a **good** day, *really* good');

      expect(runs.map((MarkdownRun run) => run.text).toList(), <String>['a ', 'good', ' day, ', 'really', ' good']);
      expect(runs[1].bold, isTrue);
      expect(runs[3].italic, isTrue);
    });

    test('plain text stays plain', () {
      final List<MarkdownRun> runs = parseInlineRuns('nothing special');

      expect(runs, hasLength(1));
      expect(runs.single.bold, isFalse);
      expect(runs.single.italic, isFalse);
    });
  });
}
