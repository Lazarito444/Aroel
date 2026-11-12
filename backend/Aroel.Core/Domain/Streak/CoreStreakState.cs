using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Streak;

/// <summary>
/// The streak: how many days in a row the user has kept, and how far it has ever run.
/// </summary>
/// <remarks>
/// A day counts when any of these happened: a rating, a tag, a gratitude line or something
/// written. One missed day is forgiven with the grace token; two missed days in a row
/// break the streak, and a fresh streak starts with a fresh token.
/// <para>
/// The streak is evaluated lazily, against the last day that was kept, rather than by a
/// nightly job: nothing here runs on a schedule, and the answer is the same whenever it
/// is asked for. Recovering a missed day by hand is free and unlimited.
/// </para>
/// </remarks>
public sealed class CoreStreakState : Entity
{
    /// <summary>
    /// The number of grace tokens a streak holds.
    /// </summary>
    /// <remarks>
    /// One token forgives one missed day. The rule for replenishing it over time is still
    /// open in the specification, so today a fresh streak starts with a fresh token.
    /// </remarks>
    public const int MaxGrace = 1;

    private readonly List<CoreStreakRestoration> _restorations = [];

    private CoreStreakState()
    {
    }

    private CoreStreakState(Guid id, Guid userId, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        GraceRemaining = MaxGrace;
    }

    /// <summary>
    /// Gets the user the streak belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the number of days kept in a row.
    /// </summary>
    public int CurrentStreak { get; private set; }

    /// <summary>
    /// Gets the longest run of days the user ever kept.
    /// </summary>
    public int LongestStreak { get; private set; }

    /// <summary>
    /// Gets the number of grace tokens left, which forgive a missed day.
    /// </summary>
    public int GraceRemaining { get; private set; }

    /// <summary>
    /// Gets the last day that was kept, when there is one.
    /// </summary>
    public LocalDate? LastKeptDate { get; private set; }

    /// <summary>
    /// Gets the days the user recovered by hand.
    /// </summary>
    public IReadOnlyList<CoreStreakRestoration> Restorations => _restorations;

    /// <summary>
    /// Creates a streak for a user.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the streak belongs to.</param>
    /// <param name="now">The moment the streak was created, in UTC.</param>
    /// <returns>The streak, or a failure when the identifier is missing.</returns>
    public static Result<CoreStreakState> Create(Guid id, Guid userId, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreStreakState>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : Result.Success(new CoreStreakState(id, userId, now));
    }

    /// <summary>
    /// Records that a day was kept.
    /// </summary>
    /// <param name="date">The day that was kept.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The streak.</returns>
    /// <remarks>
    /// A day already counted changes nothing. A day right after the last kept one extends
    /// the streak. A day with exactly one missed day in between spends the grace token
    /// and extends the streak; a day with two or more missed days in between starts a
    /// fresh streak with a fresh token.
    /// </remarks>
    public Result<CoreStreakState> RecordActivity(LocalDate date, DateTimeOffset now)
    {
        LocalDate? last = LastKeptDate;

        if (last is null)
        {
            CurrentStreak = 1;
            LastKeptDate = date;
        }
        else if (date == last.Value)
        {
            return Result.Success(this);
        }
        else if (date == last.Value.AddDays(1))
        {
            CurrentStreak++;
            LastKeptDate = date;
        }
        else if (date.DaysSince(last.Value) == 2 && GraceRemaining > 0)
        {
            GraceRemaining--;
            CurrentStreak++;
            LastKeptDate = date;
        }
        else
        {
            CurrentStreak = 1;
            GraceRemaining = MaxGrace;
            LastKeptDate = date;
        }

        LongestStreak = Math.Max(LongestStreak, CurrentStreak);
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Records that a missed day was recovered by hand.
    /// </summary>
    /// <param name="restorationId">The identifier of the recovery.</param>
    /// <param name="date">The day that was recovered.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The streak, or a failure when the identifier is missing.</returns>
    /// <remarks>
    /// Recovering a day that comes after the last kept one extends the streak. Recovering a
    /// day inside a gap that has already been closed leaves the count alone: the day is
    /// marked as recovered, and the caller replays the days in order to settle the count.
    /// </remarks>
    public Result<CoreStreakState> Restore(Guid restorationId, LocalDate date, DateTimeOffset now)
    {
        Result<CoreStreakRestoration> restoration = CoreStreakRestoration.Create(restorationId, UserId, date, now);

        return restoration.IsFailure
            ? Result.Failure<CoreStreakState>(restoration.Error!)
            : ApplyRestoration(restoration.Value, date, now);
    }

    private Result<CoreStreakState> ApplyRestoration(CoreStreakRestoration restoration, LocalDate date, DateTimeOffset now)
    {
        _restorations.Add(restoration);

        if (LastKeptDate is null || date.DaysSince(LastKeptDate.Value) > 0)
        {
            return RecordActivity(date, now);
        }

        Touch(now);
        return Result.Success(this);
    }
}
