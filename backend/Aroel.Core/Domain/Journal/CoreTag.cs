using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// A tag in the user's own vocabulary of contexts: work, family, exercise, poor sleep.
/// </summary>
/// <remarks>
/// Tags belong to the user, not to the day, so that the same word can be applied to a
/// hundred days and still mean one thing. The vocabulary starts empty and is whatever the
/// user has typed; nothing is seeded behind their back.
/// </remarks>
public sealed class CoreTag : SyncableEntity
{
    /// <summary>
    /// The longest tag label the domain accepts.
    /// </summary>
    public const int MaxLabelLength = 40;

    private CoreTag()
    {
    }

    private CoreTag(Guid id, Guid userId, string label, string? color, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        Label = label;
        Color = color;
    }

    /// <summary>
    /// Gets the user the tag belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the text of the tag.
    /// </summary>
    public string Label { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the colour of the tag, as a hex colour, when the user gave it one.
    /// </summary>
    public string? Color { get; private set; }

    /// <summary>
    /// Creates a tag.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the tag belongs to.</param>
    /// <param name="label">The text of the tag; trimmed before storing.</param>
    /// <param name="color">The colour of the tag, as a hex colour, when it has one.</param>
    /// <param name="now">The moment the tag was created, in UTC.</param>
    /// <returns>The tag, or a failure when a field does not hold up.</returns>
    public static Result<CoreTag> Create(Guid id, Guid userId, string label, string? color, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(label);

        return id == Guid.Empty
            ? Result.Failure<CoreTag>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateLabel(label).Bind(text =>
                ValidateColor(color).Map(shade =>
                    new CoreTag(id, userId, text, shade, now)));
    }

    /// <summary>
    /// Changes the text of the tag.
    /// </summary>
    /// <param name="label">The new text; trimmed before storing.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The tag, or a failure when the text does not hold up.</returns>
    public Result<CoreTag> Rename(string label, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(label);

        return ValidateLabel(label).Map(text =>
        {
            Label = text;
            Touch(now);
            return this;
        });
    }

    /// <summary>
    /// Changes the colour of the tag.
    /// </summary>
    /// <param name="color">The new colour, as a hex colour, or <see langword="null"/> for none.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The tag, or a failure when the colour does not hold up.</returns>
    public Result<CoreTag> Recolor(string? color, DateTimeOffset now)
    {
        return ValidateColor(color).Map(shade =>
        {
            Color = shade;
            Touch(now);
            return this;
        });
    }

    private static Result<string> ValidateLabel(string label)
    {
        if (string.IsNullOrWhiteSpace(label))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.TagLabelEmpty));
        }

        string trimmed = label.Trim();

        return trimmed.Length > MaxLabelLength
            ? Result.Failure<string>(new AppError(ErrorCodes.TagLabelTooLong, MaxLabelLength))
            : Result.Success(trimmed);
    }

    private static Result<string?> ValidateColor(string? color)
    {
        if (string.IsNullOrWhiteSpace(color))
        {
            return Result.Success<string?>(null);
        }

        string trimmed = color.Trim();
        bool hex = trimmed.Length is 4 or 7 && trimmed[0] == '#';

        if (hex)
        {
            foreach (char digit in trimmed[1..])
            {
                if (!char.IsAsciiHexDigit(digit))
                {
                    hex = false;
                    break;
                }
            }
        }

        return hex
            ? Result.Success<string?>(trimmed)
            : Result.Failure<string?>(new AppError(ErrorCodes.TagColorInvalid, trimmed));
    }
}
