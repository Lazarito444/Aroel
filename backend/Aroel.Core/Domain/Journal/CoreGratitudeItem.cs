using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// One of the three small things the user names on a day.
/// </summary>
/// <remarks>
/// A gratitude line belongs to the day it was written on and counts for nothing else: it
/// never leaves the day record and never appears anywhere but in the day it hangs off.
/// </remarks>
public sealed class CoreGratitudeItem : SyncableEntity
{
    /// <summary>
    /// The longest gratitude line the domain accepts.
    /// </summary>
    public const int MaxTextLength = 140;

    /// <summary>
    /// The lowest position a line can occupy.
    /// </summary>
    public const int MinimumPosition = 1;

    /// <summary>
    /// The highest position a line can occupy.
    /// </summary>
    public const int MaximumPosition = 3;

    private CoreGratitudeItem()
    {
    }

    private CoreGratitudeItem(Guid id, Guid dayId, int position, string text, DateTimeOffset now)
        : base(id, now)
    {
        DayId = dayId;
        Position = position;
        Text = text;
    }

    /// <summary>
    /// Gets the day the line belongs to.
    /// </summary>
    public Guid DayId { get; private set; }

    /// <summary>
    /// Gets the position the line occupies, from one to three.
    /// </summary>
    public int Position { get; private set; }

    /// <summary>
    /// Gets the text of the line.
    /// </summary>
    public string Text { get; private set; } = string.Empty;

    /// <summary>
    /// Creates a gratitude line.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="dayId">The day the line belongs to.</param>
    /// <param name="position">The position to occupy, from one to three.</param>
    /// <param name="text">The text of the line; trimmed before storing.</param>
    /// <param name="now">The moment the line was written, in UTC.</param>
    /// <returns>The line, or a failure when a field does not hold up.</returns>
    public static Result<CoreGratitudeItem> Create(Guid id, Guid dayId, int position, string text, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(text);

        return id == Guid.Empty
            ? Result.Failure<CoreGratitudeItem>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidatePosition(position).Bind(validPosition =>
                ValidateText(text).Map(content =>
                    new CoreGratitudeItem(id, dayId, validPosition, content, now)));
    }

    /// <summary>
    /// Changes the text of the line.
    /// </summary>
    /// <param name="text">The new text; trimmed before storing.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The line, or a failure when the text does not hold up.</returns>
    public Result<CoreGratitudeItem> SetText(string text, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(text);

        return ValidateText(text).Map(content =>
        {
            Text = content;
            Touch(now);
            return this;
        });
    }

    private static Result<int> ValidatePosition(int position)
    {
        return position is < MinimumPosition or > MaximumPosition
            ? Result.Failure<int>(new AppError(ErrorCodes.GratitudePositionOutOfRange, position, MinimumPosition, MaximumPosition))
            : Result.Success(position);
    }

    private static Result<string> ValidateText(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.GratitudeTextEmpty));
        }

        string trimmed = text.Trim();

        return trimmed.Length > MaxTextLength
            ? Result.Failure<string>(new AppError(ErrorCodes.GratitudeTextTooLong, MaxTextLength))
            : Result.Success(trimmed);
    }
}
