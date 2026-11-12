using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Streak;

/// <summary>
/// A day the user chose to recover by hand after missing it.
/// </summary>
/// <remarks>
/// Recovery is free and unlimited, and it is recorded rather than inferred, so that a
/// recovered day can be marked as recovered in the streak view. Nothing about it is
/// shaming: the user decided to keep the day, and that is the end of it.
/// </remarks>
public sealed class CoreStreakRestoration : Entity
{
    private CoreStreakRestoration()
    {
    }

    private CoreStreakRestoration(Guid id, Guid userId, LocalDate localDate, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        LocalDate = localDate;
    }

    /// <summary>
    /// Gets the user the recovery belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the day that was recovered.
    /// </summary>
    public LocalDate LocalDate { get; private set; }

    /// <summary>
    /// Creates a recovery.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the recovery belongs to.</param>
    /// <param name="localDate">The day that was recovered.</param>
    /// <param name="now">The moment the recovery was recorded, in UTC.</param>
    /// <returns>The recovery, or a failure when the identifier is missing.</returns>
    public static Result<CoreStreakRestoration> Create(Guid id, Guid userId, LocalDate localDate, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreStreakRestoration>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : Result.Success(new CoreStreakRestoration(id, userId, localDate, now));
    }
}
