namespace Aroel.Core.Domain.Enums;

/// <summary>
/// The family an emotion belongs to, derived from Plutchik and trimmed to what people
/// actually write about.
/// </summary>
public enum EmotionFamily
{
    /// <summary>
    /// Joy and its neighbours.
    /// </summary>
    Joy = 0,

    /// <summary>
    /// Trust and its neighbours.
    /// </summary>
    Trust = 1,

    /// <summary>
    /// Calm and its neighbours.
    /// </summary>
    Calm = 2,

    /// <summary>
    /// Sadness and its neighbours.
    /// </summary>
    Sadness = 3,

    /// <summary>
    /// Fear and its neighbours.
    /// </summary>
    Fear = 4,

    /// <summary>
    /// Anger and its neighbours.
    /// </summary>
    Anger = 5,

    /// <summary>
    /// Shame and its neighbours.
    /// </summary>
    Shame = 6,

    /// <summary>
    /// Surprise and its neighbours.
    /// </summary>
    Surprise = 7
}
