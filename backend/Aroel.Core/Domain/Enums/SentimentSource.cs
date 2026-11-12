namespace Aroel.Core.Domain.Enums;

/// <summary>
/// Where a day's sentiment came from.
/// </summary>
public enum SentimentSource
{
    /// <summary>
    /// The user picked the tone by hand.
    /// </summary>
    Manual = 0,

    /// <summary>
    /// An on-device classifier derived the tone from what the user wrote.
    /// </summary>
    OnDevice = 1
}
