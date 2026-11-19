/// Counts the words in a piece of text.
///
/// Markdown markers count as part of the word they surround, so `**bold**` is one word.
/// The count is a reading aid, not a billing figure, and must stay predictable rather
/// than clever. Mirrors `Aroel.Core.Domain.Text.WordCounter`.
abstract final class WordCounter {
  /// Counts the words in [text]; zero for empty or blank text.
  static int count(String text) {
    int count = 0;
    bool insideWord = false;
    for (final int codeUnit in text.codeUnits) {
      if (_isWhiteSpace(codeUnit)) {
        insideWord = false;
      } else if (!insideWord) {
        insideWord = true;
        count++;
      }
    }
    return count;
  }

  static bool _isWhiteSpace(int codeUnit) => codeUnit == 0x20 || codeUnit == 0x09 || codeUnit == 0x0A || codeUnit == 0x0D || codeUnit == 0x0B || codeUnit == 0x0C || codeUnit == 0xA0;
}
