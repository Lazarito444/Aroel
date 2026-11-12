namespace Aroel.Core.Domain.Text;

/// <summary>
/// Counts the words in a piece of text.
/// </summary>
/// <remarks>
/// Markdown markers count as part of the word they surround, so <c>**bold**</c> is one
/// word. The count is a reading aid, not a billing figure, and must stay predictable
/// rather than clever.
/// </remarks>
public static class WordCounter
{
    /// <summary>
    /// Counts the words in the given text.
    /// </summary>
    /// <param name="text">The text to count.</param>
    /// <returns>The number of words; zero for empty or blank text.</returns>
    public static int Count(string text)
    {
        ArgumentNullException.ThrowIfNull(text);

        int count = 0;
        bool insideWord = false;
        foreach (char character in text)
        {
            if (char.IsWhiteSpace(character))
            {
                insideWord = false;
            }
            else if (!insideWord)
            {
                insideWord = true;
                count++;
            }
        }

        return count;
    }
}
