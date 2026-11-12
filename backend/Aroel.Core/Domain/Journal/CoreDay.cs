using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// The record of one calendar day: its rating, its one-line note, its gratitude lines,
/// its tags and its tone.
/// </summary>
/// <remarks>
/// The day is the spine of the product: everything the app calls history or analytics is
/// a query over these rows, so there is no aggregation guesswork and no timezone drift.
/// A day holds at most five tags and three gratitude lines, and both limits live here
/// rather than in the interface that happens to enforce them today.
/// </remarks>
public sealed class CoreDay : SyncableEntity
{
    /// <summary>
    /// The longest one-line note the domain accepts.
    /// </summary>
    public const int MaxNoteLength = 280;

    /// <summary>
    /// The most tags a day can carry.
    /// </summary>
    public const int MaxTags = 5;

    /// <summary>
    /// The most gratitude lines a day can carry.
    /// </summary>
    public const int MaxGratitudeItems = 3;

    private readonly List<CoreGratitudeItem> _gratitudeItems = [];
    private readonly List<CoreDayTag> _tags = [];

    private CoreDay()
    {
    }

    private CoreDay(Guid id, Guid userId, LocalDate localDate, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        LocalDate = localDate;
    }

    /// <summary>
    /// Gets the user the day belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the calendar day, in the user's own timezone.
    /// </summary>
    public LocalDate LocalDate { get; private set; }

    /// <summary>
    /// Gets the rating of the day, or <see langword="null"/> when the day was not rated.
    /// </summary>
    /// <remarks>
    /// An unrated day is absent, not zero: on a scale that starts at zero, zero is a real
    /// score for a real day, so it cannot double as "no score".
    /// </remarks>
    public RatingHalf? Rating { get; private set; }

    /// <summary>
    /// Gets the one-line note of the day, when it carries one.
    /// </summary>
    public string? Note { get; private set; }

    /// <summary>
    /// Gets the moment the day was rated, in UTC, when it was rated.
    /// </summary>
    public DateTimeOffset? RatedAt { get; private set; }

    /// <summary>
    /// Gets the tone of the day, when one was recorded.
    /// </summary>
    public CoreDaySentiment? Sentiment { get; private set; }

    /// <summary>
    /// Gets the gratitude lines of the day, in the order they were written.
    /// </summary>
    public IReadOnlyList<CoreGratitudeItem> GratitudeItems => _gratitudeItems;

    /// <summary>
    /// Gets the tags applied to the day.
    /// </summary>
    public IReadOnlyList<CoreDayTag> Tags => _tags;

    /// <summary>
    /// Creates a day.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the day belongs to.</param>
    /// <param name="localDate">The calendar day, in the user's own timezone.</param>
    /// <param name="now">The moment the day was created, in UTC.</param>
    /// <returns>The day, or a failure when the identifier is missing.</returns>
    public static Result<CoreDay> Create(Guid id, Guid userId, LocalDate localDate, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreDay>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : Result.Success(new CoreDay(id, userId, localDate, now));
    }

    /// <summary>
    /// Rates the day.
    /// </summary>
    /// <param name="rating">The rating of the day.</param>
    /// <param name="now">The moment of the rating, in UTC.</param>
    /// <returns>The day.</returns>
    public Result<CoreDay> SetRating(RatingHalf rating, DateTimeOffset now)
    {
        Rating = rating;
        RatedAt = now;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Takes the rating back, leaving the day unrated rather than rated zero.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day.</returns>
    public Result<CoreDay> ClearRating(DateTimeOffset now)
    {
        Rating = null;
        RatedAt = null;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Writes the one-line note of the day.
    /// </summary>
    /// <param name="note">The note; trimmed before storing, and blank text clears it.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day, or a failure when the note is longer than the domain accepts.</returns>
    public Result<CoreDay> SetNote(string? note, DateTimeOffset now)
    {
        return ValidateNote(note).Map(content =>
        {
            Note = content;
            Touch(now);
            return this;
        });
    }

    /// <summary>
    /// Writes the gratitude line that sits at a position, replacing the one already there.
    /// </summary>
    /// <param name="itemId">The identifier for the line, used only when the position is filled for the first time.</param>
    /// <param name="position">The position to fill, from one to three.</param>
    /// <param name="text">The text of the line; trimmed before storing.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day, or a failure when the position or the text does not hold up.</returns>
    public Result<CoreDay> SetGratitudeItem(Guid itemId, int position, string text, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(text);

        CoreGratitudeItem? existing = _gratitudeItems.FirstOrDefault(item => item.Position == position);

        return existing is null
            ? CoreGratitudeItem.Create(itemId, Id, position, text, now).Map(item =>
            {
                _gratitudeItems.Add(item);
                Touch(now);
                return this;
            })
            : existing.SetText(text, now).Map(item =>
            {
                Touch(now);
                return this;
            });
    }

    /// <summary>
    /// Removes the gratitude line that sits at a position.
    /// </summary>
    /// <param name="position">The position to clear.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day.</returns>
    public Result<CoreDay> RemoveGratitudeItem(int position, DateTimeOffset now)
    {
        CoreGratitudeItem? existing = _gratitudeItems.FirstOrDefault(item => item.Position == position);

        if (existing is not null)
        {
            _gratitudeItems.Remove(existing);
            Touch(now);
        }

        return Result.Success(this);
    }

    /// <summary>
    /// Applies a tag to the day.
    /// </summary>
    /// <param name="dayTagId">The identifier of the link between the day and the tag.</param>
    /// <param name="tagId">The tag to apply.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day, or a failure when the day already carries the tag or has five.</returns>
    public Result<CoreDay> AddTag(Guid dayTagId, Guid tagId, DateTimeOffset now)
    {
        return ValidateTagAddition(tagId).Bind(validTagId =>
            CoreDayTag.Create(dayTagId, Id, validTagId, now).Map(tag =>
            {
                _tags.Add(tag);
                Touch(now);
                return this;
            }));
    }

    /// <summary>
    /// Takes a tag off the day.
    /// </summary>
    /// <param name="tagId">The tag to remove.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day.</returns>
    public Result<CoreDay> RemoveTag(Guid tagId, DateTimeOffset now)
    {
        CoreDayTag? existing = _tags.FirstOrDefault(tag => tag.TagId == tagId);

        if (existing is not null)
        {
            _tags.Remove(existing);
            Touch(now);
        }

        return Result.Success(this);
    }

    /// <summary>
    /// Records the tone of the day, replacing a tone already recorded.
    /// </summary>
    /// <param name="sentiment">The tone; it must belong to this day.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day, or a failure when the tone belongs to another day.</returns>
    public Result<CoreDay> SetSentiment(CoreDaySentiment sentiment, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(sentiment);

        return sentiment.DayId == Id
            ? ApplySentiment(sentiment, now)
            : Result.Failure<CoreDay>(new AppError(ErrorCodes.DaySentimentMismatch, sentiment.DayId.ToString(), Id.ToString()));
    }

    /// <summary>
    /// Drops the tone of the day.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The day.</returns>
    public Result<CoreDay> ClearSentiment(DateTimeOffset now)
    {
        Sentiment = null;
        Touch(now);
        return Result.Success(this);
    }

    private Result<CoreDay> ApplySentiment(CoreDaySentiment sentiment, DateTimeOffset now)
    {
        Sentiment = sentiment;
        Touch(now);
        return Result.Success(this);
    }

    private Result<Guid> ValidateTagAddition(Guid tagId)
    {
        bool duplicate = _tags.Any(tag => tag.TagId == tagId);
        bool full = _tags.Count >= MaxTags;

        return duplicate
            ? Result.Failure<Guid>(new AppError(ErrorCodes.DayTagDuplicate, tagId.ToString()))
            : full
                ? Result.Failure<Guid>(new AppError(ErrorCodes.DayTagLimitExceeded, MaxTags))
                : Result.Success(tagId);
    }

    private static Result<string?> ValidateNote(string? note)
    {
        string trimmed = note?.Trim() ?? string.Empty;

        return trimmed.Length == 0
            ? Result.Success<string?>(null)
            : trimmed.Length > MaxNoteLength
                ? Result.Failure<string?>(new AppError(ErrorCodes.DayNoteTooLong, MaxNoteLength))
                : Result.Success<string?>(trimmed);
    }
}
