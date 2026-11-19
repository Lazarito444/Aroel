using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Data.Services;

/// <summary>One day, as the server answers with it.</summary>
/// <param name="LocalDate">The day, in the user's timezone.</param>
/// <param name="RatingHalf">The rating in half points, when the day was rated.</param>
/// <param name="Note">The one-line note, when there is one.</param>
/// <param name="RatedAt">When the rating was set, in UTC.</param>
/// <param name="UpdatedAt">When the day last changed.</param>
public sealed record ServiceDay(
    string LocalDate,
    int? RatingHalf,
    string? Note,
    DateTimeOffset? RatedAt,
    DateTimeOffset UpdatedAt);

/// <summary>What an insights window answers with (§5.8).</summary>
/// <param name="Window">`week` or `month`.</param>
/// <param name="From">The first day in the window.</param>
/// <param name="To">The last day in the window.</param>
/// <param name="DaysRated">The days that were rated.</param>
/// <param name="AverageHalfPoints">The average rating in half points, when anything was rated.</param>
/// <param name="EntriesWritten">The entries written.</param>
/// <param name="GratitudeLines">The gratitude lines filled.</param>
/// <param name="MostUsedTags">The tags most used, most used first.</param>
/// <param name="BestDay">The best rated day, when anything was rated.</param>
/// <param name="HighestSentimentDay">The day with the highest tone, when one was picked.</param>
public sealed record ServiceInsights(
    string Window,
    string From,
    string To,
    int DaysRated,
    int? AverageHalfPoints,
    int EntriesWritten,
    int GratitudeLines,
    IReadOnlyList<ServiceTagCount> MostUsedTags,
    ServiceDay? BestDay,
    ServiceDay? HighestSentimentDay);

/// <summary>One tag and its count in the window.</summary>
/// <param name="Label">The label of the tag.</param>
/// <param name="Count">How many days carried it.</param>
public sealed record ServiceTagCount(string Label, int Count);

/// <summary>
/// The read models of the days (§5.7, §7.2).
/// </summary>
/// <remarks>
/// The client computes its own review on-device; these exist for anything else that
/// reads the journal from the server, and they answer with the same honest arithmetic:
/// rated days only, no model, no prose.
/// </remarks>
public sealed class DayReadService
{
    private readonly AroelDbContext _db;

    /// <summary>
    /// Initialises the service.
    /// </summary>
    /// <param name="db">The database of the host.</param>
    public DayReadService(AroelDbContext db)
    {
        ArgumentNullException.ThrowIfNull(db);
        _db = db;
    }

    /// <summary>
    /// Reads the days of a user in a range, oldest first.
    /// </summary>
    /// <param name="userId">The user the days belong to.</param>
    /// <param name="from">The first day, inclusive.</param>
    /// <param name="to">The last day, inclusive.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The days, ordered by date.</returns>
    public async Task<IReadOnlyList<ServiceDay>> RangeAsync(Guid userId, LocalDate from, LocalDate to, CancellationToken cancellationToken = default)
    {
        List<CoreDay> days = await _db.Set<CoreDay>()
            .Where(day => day.UserId == userId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        days = [.. days
            .Where(day => day.LocalDate.Value >= from.Value && day.LocalDate.Value <= to.Value)
            .OrderBy(day => day.LocalDate.Value)];

        return [.. days.Select(Map)];
    }

    /// <summary>
    /// Computes the insights of a window (§5.8).
    /// </summary>
    /// <param name="userId">The user the rows belong to.</param>
    /// <param name="from">The first day, inclusive.</param>
    /// <param name="to">The last day, inclusive.</param>
    /// <param name="window">The name of the window, `week` or `month`.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The numbers of the window.</returns>
    public async Task<ServiceInsights> InsightsAsync(Guid userId, LocalDate from, LocalDate to, string window, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(window);

        List<CoreDay> days = await _db.Set<CoreDay>()
            .Include(day => day.GratitudeItems)
            .Include(day => day.Tags)
            .Include(day => day.Sentiment)
            .Where(day => day.UserId == userId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        days = [.. days.Where(day => day.LocalDate.Value >= from.Value && day.LocalDate.Value <= to.Value)];

        List<Guid> dayIds = [.. days.Select(day => day.Id)];
        List<CoreEntry> entries = dayIds.Count == 0
            ? []
            : await _db.Set<CoreEntry>()
                .Where(entry => dayIds.Contains(entry.DayId) && entry.DeletedAt == null)
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);

        List<Guid> tagIds = [.. days.SelectMany(day => day.Tags).Select(tag => tag.TagId).Distinct()];
        Dictionary<Guid, string> labels = tagIds.Count == 0
            ? []
            : await _db.Set<CoreTag>()
                .Where(tag => tagIds.Contains(tag.Id))
                .ToDictionaryAsync(tag => tag.Id, tag => tag.Label, cancellationToken)
                .ConfigureAwait(false);

        List<int> ratings = [.. days.Where(day => day.Rating is not null).Select(day => day.Rating!.Value.HalfPoints)];
        int? average = ratings.Count == 0 ? null : (int)Math.Round(ratings.Average());

        List<DayTagPair> dayTags = [.. days.SelectMany(day => day.Tags.Select(tag => new DayTagPair(day.LocalDate, tag.TagId)))];

        List<ServiceTagCount> mostUsed = [.. dayTags
            .Where(pair => labels.ContainsKey(pair.TagId))
            .GroupBy(pair => labels[pair.TagId])
            .Select(group => new ServiceTagCount(group.Key, group.Count()))
            .OrderByDescending(tag => tag.Count)
            .ThenBy(tag => tag.Label, StringComparer.Ordinal)
            .Take(3)];

        ServiceDay? best = days.Where(day => day.Rating is not null)
            .OrderByDescending(day => day.Rating!.Value.HalfPoints)
            .ThenByDescending(day => day.LocalDate)
            .Select(Map)
            .FirstOrDefault();

        ServiceDay? highestTone = days.Where(day => day.Sentiment?.Rating is not null)
            .OrderByDescending(day => day.Sentiment!.Rating!.Value.HalfPoints)
            .ThenByDescending(day => day.LocalDate)
            .Select(Map)
            .FirstOrDefault();

        return new ServiceInsights(
            window,
            from.ToString(),
            to.ToString(),
            ratings.Count,
            average,
            entries.Count(entry => entry.BodyMarkdown.Trim().Length > 0),
            days.SelectMany(day => day.GratitudeItems).Count(item => item.Text.Trim().Length > 0),
            mostUsed,
            best,
            highestTone);
    }

    private static ServiceDay Map(CoreDay day)
    {
        return new(
        day.LocalDate.ToString(),
        day.Rating?.HalfPoints,
        day.Note,
        day.RatedAt,
        day.UpdatedAt);
    }

    private readonly record struct DayTagPair(LocalDate LocalDate, Guid TagId);
}
