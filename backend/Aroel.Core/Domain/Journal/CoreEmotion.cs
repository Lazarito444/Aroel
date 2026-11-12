using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// One emotion in the taxonomy the app maps a day's tone onto.
/// </summary>
/// <remarks>
/// The taxonomy is seeded once and never changes shape: the slugs are stable, so an
/// emotion means the same thing across releases and a year of analytics still compares.
/// </remarks>
public sealed class CoreEmotion : Entity
{
    /// <summary>
    /// The longest slug the domain accepts.
    /// </summary>
    public const int MaxSlugLength = 40;

    /// <summary>
    /// The longest label the domain accepts.
    /// </summary>
    public const int MaxLabelLength = 40;

    /// <summary>
    /// The lowest valence bias an emotion can carry.
    /// </summary>
    public const decimal MinimumValenceBias = -1m;

    /// <summary>
    /// The highest valence bias an emotion can carry.
    /// </summary>
    public const decimal MaximumValenceBias = 1m;

    private CoreEmotion()
    {
    }

    private CoreEmotion(Guid id, string slug, string label, EmotionFamily family, decimal valenceBias, DateTimeOffset now)
        : base(id, now)
    {
        Slug = slug;
        Label = label;
        Family = family;
        ValenceBias = valenceBias;
    }

    /// <summary>
    /// Gets the stable slug of the emotion.
    /// </summary>
    public string Slug { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the label shown to the user.
    /// </summary>
    public string Label { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the family the emotion belongs to.
    /// </summary>
    public EmotionFamily Family { get; private set; }

    /// <summary>
    /// Gets how pleasant the emotion is on a scale from minus one to one.
    /// </summary>
    public decimal ValenceBias { get; private set; }

    /// <summary>
    /// Creates an emotion.
    /// </summary>
    /// <param name="id">The identifier of the emotion, which must not be empty.</param>
    /// <param name="slug">The stable slug, lowercased and trimmed before storing.</param>
    /// <param name="label">The label shown to the user; trimmed before storing.</param>
    /// <param name="family">The family the emotion belongs to.</param>
    /// <param name="valenceBias">How pleasant the emotion is, from minus one to one.</param>
    /// <param name="now">The moment the emotion was created, in UTC.</param>
    /// <returns>The emotion, or a failure when a field does not hold up.</returns>
    public static Result<CoreEmotion> Create(Guid id, string slug, string label, EmotionFamily family, decimal valenceBias, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(slug);
        ArgumentNullException.ThrowIfNull(label);

        return id == Guid.Empty
            ? Result.Failure<CoreEmotion>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateSlug(slug).Bind(validSlug =>
                ValidateLabel(label).Bind(validLabel =>
                    ValidateFamily(family, valenceBias).Map(_ =>
                        new CoreEmotion(id, validSlug, validLabel, family, valenceBias, now))));
    }

    private static Result<string> ValidateSlug(string slug)
    {
        if (string.IsNullOrWhiteSpace(slug))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.EmotionSlugEmpty));
        }

        string trimmed = slug.Trim().ToLowerInvariant();

        return trimmed.Length > MaxSlugLength
            ? Result.Failure<string>(new AppError(ErrorCodes.EmotionSlugTooLong, MaxSlugLength))
            : Result.Success(trimmed);
    }

    private static Result<string> ValidateLabel(string label)
    {
        if (string.IsNullOrWhiteSpace(label))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.EmotionLabelEmpty));
        }

        string trimmed = label.Trim();

        return trimmed.Length > MaxLabelLength
            ? Result.Failure<string>(new AppError(ErrorCodes.EmotionLabelTooLong, MaxLabelLength))
            : Result.Success(trimmed);
    }

    private static Result<EmotionFamily> ValidateFamily(EmotionFamily family, decimal valenceBias)
    {
        bool known = Enum.IsDefined(family);
        bool biased = valenceBias is < MinimumValenceBias or > MaximumValenceBias;

        return !known
            ? Result.Failure<EmotionFamily>(new AppError(ErrorCodes.EmotionFamilyInvalid, family))
            : biased
                ? Result.Failure<EmotionFamily>(new AppError(ErrorCodes.EmotionValenceOutOfRange, valenceBias, MinimumValenceBias, MaximumValenceBias))
                : Result.Success(family);
    }
}
