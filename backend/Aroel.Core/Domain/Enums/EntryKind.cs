namespace Aroel.Core.Domain.Enums;

/// <summary>
/// What kind of writing a day carries.
/// </summary>
public enum EntryKind
{
    /// <summary>
    /// Free writing: the day's own prose.
    /// </summary>
    Free = 0,

    /// <summary>
    /// A short note that only records a mood, without prose.
    /// </summary>
    MoodOnly = 1
}
