using System.Security.Claims;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Data.Services;

namespace Aroel.Api.Endpoints;

/// <summary>One day, as the wire answers with it.</summary>
internal sealed record DayResponse(
    string LocalDate,
    int? RatingHalf,
    string? Note,
    DateTimeOffset? RatedAt,
    DateTimeOffset UpdatedAt);

/// <summary>What a read of days answers with.</summary>
internal sealed record DaysResponse(IReadOnlyList<DayResponse> Days);

/// <summary>One tag count, as the wire answers with it.</summary>
internal sealed record TagCountResponse(string Label, int Count);

/// <summary>What insights answer with.</summary>
internal sealed record InsightsResponse(
    string Window,
    string From,
    string To,
    int DaysRated,
    int? AverageHalfPoints,
    int EntriesWritten,
    int GratitudeLines,
    IReadOnlyList<TagCountResponse> MostUsedTags,
    DayResponse? BestDay,
    DayResponse? HighestSentimentDay);

/// <summary>
/// The days read endpoints (§7.2, §5.7).
/// </summary>
internal static class DayEndpoints
{
    /// <summary>Maps the days endpoints onto the app.</summary>
    public static IEndpointRouteBuilder MapDayEndpoints(this IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        app.MapGet("/days", GetDaysAsync).RequireAuthorization();
        app.MapGet("/insights", GetInsightsAsync)
            .RequireAuthorization()
            .RequireRateLimiting("insights");

        return app;
    }

    private static async Task<IResult> GetDaysAsync(
        DateOnly? from,
        DateOnly? to,
        ClaimsPrincipal user,
        DayReadService days,
        CancellationToken cancellationToken)
    {
        if (from is null || to is null)
        {
            return AuthEndpoints.Fail("request.invalid", StatusCodes.Status400BadRequest);
        }

        LocalDate start = LocalDate.From(from.Value.Year, from.Value.Month, from.Value.Day);
        LocalDate end = LocalDate.From(to.Value.Year, to.Value.Month, to.Value.Day);

        if (end.Value < start.Value)
        {
            return AuthEndpoints.Fail("request.invalid", StatusCodes.Status400BadRequest);
        }

        IReadOnlyList<ServiceDay> range = await days.RangeAsync(
            AuthEndpoints.UserId(user),
            start,
            end,
            cancellationToken).ConfigureAwait(false);

        return Results.Ok(new DaysResponse([.. range.Select(Map)]));
    }

    private static async Task<IResult> GetInsightsAsync(
        string? window,
        DateOnly? from,
        DateOnly? to,
        ClaimsPrincipal user,
        DayReadService days,
        TimeProvider timeProvider,
        CancellationToken cancellationToken)
    {
        string name = (window ?? "week").Trim().ToLowerInvariant();
        if (name is not ("week" or "month"))
        {
            return AuthEndpoints.Fail("request.invalid", StatusCodes.Status400BadRequest);
        }

        LocalDate start;
        LocalDate end;
        if (from is not null && to is not null)
        {
            start = LocalDate.From(from.Value.Year, from.Value.Month, from.Value.Day);
            end = LocalDate.From(to.Value.Year, to.Value.Month, to.Value.Day);
        }
        else
        {
            DateTimeOffset now = timeProvider.GetUtcNow();
            if (name == "week")
            {
                DateTimeOffset weekStart = now.Date.AddDays(-6);
                start = LocalDate.From(weekStart.Year, weekStart.Month, weekStart.Day);
                end = LocalDate.From(now.Year, now.Month, now.Day);
            }
            else
            {
                DateTime monthStart = new(now.Year, now.Month, 1);
                DateTime monthEnd = monthStart.AddMonths(1).AddDays(-1);
                start = LocalDate.From(monthStart.Year, monthStart.Month, monthStart.Day);
                end = LocalDate.From(monthEnd.Year, monthEnd.Month, monthEnd.Day);
            }
        }

        if (end.Value < start.Value)
        {
            return AuthEndpoints.Fail("request.invalid", StatusCodes.Status400BadRequest);
        }

        ServiceInsights insights = await days.InsightsAsync(
            AuthEndpoints.UserId(user),
            start,
            end,
            name,
            cancellationToken).ConfigureAwait(false);

        return Results.Ok(new InsightsResponse(
            insights.Window,
            insights.From,
            insights.To,
            insights.DaysRated,
            insights.AverageHalfPoints,
            insights.EntriesWritten,
            insights.GratitudeLines,
            [.. insights.MostUsedTags.Select(tag => new TagCountResponse(tag.Label, tag.Count))],
            insights.BestDay is null ? null : Map(insights.BestDay),
            insights.HighestSentimentDay is null ? null : Map(insights.HighestSentimentDay)));
    }

    private static DayResponse Map(ServiceDay day)
    {
        return new(
        day.LocalDate,
        day.RatingHalf,
        day.Note,
        day.RatedAt,
        day.UpdatedAt);
    }
}
