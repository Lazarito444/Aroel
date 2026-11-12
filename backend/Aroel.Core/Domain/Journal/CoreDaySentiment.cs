using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// The tone of a day: how it read, and where that judgement came from.
/// </summary>
/// <remarks>
/// There is at most one of these per day. A tone picked by hand wins over one derived on
/// the device, because the user's own word is the better answer and the classifier is
/// only a guess at it.
/// </remarks>
public sealed class CoreDaySentiment : SyncableEntity
{
    private CoreDaySentiment()
    {
    }

    private CoreDaySentiment(Guid id, Guid userId, Guid dayId, SentimentSource source, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        DayId = dayId;
        Source = source;
        RecordedAt = now;
    }

    /// <summary>
    /// Gets the user the tone belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the day the tone belongs to.
    /// </summary>
    public Guid DayId { get; private set; }

    /// <summary>
    /// Gets the tone on the same half point scale as a rating, when one was determined.
    /// </summary>
    public RatingHalf? Rating { get; private set; }

    /// <summary>
    /// Gets the emotion the tone was mapped to, when it was mapped to one.
    /// </summary>
    public Guid? EmotionId { get; private set; }

    /// <summary>
    /// Gets where the tone came from.
    /// </summary>
    public SentimentSource Source { get; private set; }

    /// <summary>
    /// Gets the moment the tone was recorded, in UTC.
    /// </summary>
    public DateTimeOffset RecordedAt { get; private set; }

    /// <summary>
    /// Creates the tone of a day.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the tone belongs to.</param>
    /// <param name="dayId">The day the tone belongs to.</param>
    /// <param name="source">Where the tone came from.</param>
    /// <param name="now">The moment the tone was recorded, in UTC.</param>
    /// <returns>The tone, or a failure when a field does not hold up.</returns>
    public static Result<CoreDaySentiment> Create(Guid id, Guid userId, Guid dayId, SentimentSource source, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreDaySentiment>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : Enum.IsDefined(source)
                ? Result.Success(new CoreDaySentiment(id, userId, dayId, source, now))
                : Result.Failure<CoreDaySentiment>(new AppError(ErrorCodes.SentimentSourceInvalid, source));
    }

    /// <summary>
    /// Records the tone of the day.
    /// </summary>
    /// <param name="rating">The tone on the half point scale, when there is one.</param>
    /// <param name="emotionId">The emotion the tone was mapped to, when there is one.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The tone.</returns>
    public Result<CoreDaySentiment> SetTone(RatingHalf? rating, Guid? emotionId, DateTimeOffset now)
    {
        Rating = rating;
        EmotionId = emotionId;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Records that the tone was derived on the device rather than picked by hand.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The tone.</returns>
    public Result<CoreDaySentiment> MarkOnDevice(DateTimeOffset now)
    {
        Source = SentimentSource.OnDevice;
        Touch(now);
        return Result.Success(this);
    }
}
