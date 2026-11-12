using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// The link between a day and one of the user's context tags.
/// </summary>
/// <remarks>
/// The tag itself belongs to the user's vocabulary and is shared across days; this link
/// is what makes a tag mean "this kind of day" once enough days carry it.
/// </remarks>
public sealed class CoreDayTag : SyncableEntity
{
    private CoreDayTag()
    {
    }

    private CoreDayTag(Guid id, Guid dayId, Guid tagId, DateTimeOffset now)
        : base(id, now)
    {
        DayId = dayId;
        TagId = tagId;
    }

    /// <summary>
    /// Gets the day the tag was applied to.
    /// </summary>
    public Guid DayId { get; private set; }

    /// <summary>
    /// Gets the tag that was applied.
    /// </summary>
    public Guid TagId { get; private set; }

    /// <summary>
    /// Creates the link between a day and a tag.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="dayId">The day the tag was applied to.</param>
    /// <param name="tagId">The tag that was applied.</param>
    /// <param name="now">The moment the tag was applied, in UTC.</param>
    /// <returns>The link, or a failure when the identifier is missing.</returns>
    public static Result<CoreDayTag> Create(Guid id, Guid dayId, Guid tagId, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreDayTag>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : Result.Success(new CoreDayTag(id, dayId, tagId, now));
    }
}
