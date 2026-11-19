using System.Security.Claims;
using Aroel.Api.Contracts;
using Aroel.Data.Services;

namespace Aroel.Api.Endpoints;

/// <summary>
/// The sync endpoints (§7.3).
/// </summary>
/// <remarks>
/// Verification is required before the first sync and never before writing (§5.1). A
/// device that has not confirmed its address gets a plain 403 with a code the client
/// turns into a sentence. Everything else is a merge: the server never blocks on the
/// network being slow, and neither should the client.
/// </remarks>
internal static class SyncEndpoints
{
    /// <summary>Maps the sync endpoints onto the app.</summary>
    public static IEndpointRouteBuilder MapSyncEndpoints(this IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        app.MapGet("/sync", PullAsync)
            .RequireAuthorization()
            .RequireRateLimiting("sync");

        app.MapPost("/sync/batch", PushAsync)
            .RequireAuthorization()
            .RequireRateLimiting("sync");

        return app;
    }

    private static async Task<IResult> PullAsync(long? since, ClaimsPrincipal user, SyncService sync, CancellationToken cancellationToken)
    {
        if (!AuthEndpoints.EmailVerified(user))
        {
            return AuthEndpoints.Fail("auth.email_not_verified", StatusCodes.Status403Forbidden);
        }

        SyncPullPage page = await sync.PullAsync(AuthEndpoints.UserId(user), since ?? 0, cancellationToken).ConfigureAwait(false);

        return Results.Ok(new SyncPullResponse(
            page.Cursor,
            page.HasMore,
            [.. page.Rows.Select(ToWire)]));
    }

    private static async Task<IResult> PushAsync(SyncBatchRequest request, ClaimsPrincipal user, SyncService sync, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);

        if (!AuthEndpoints.EmailVerified(user))
        {
            return AuthEndpoints.Fail("auth.email_not_verified", StatusCodes.Status403Forbidden);
        }

        IReadOnlyList<SyncOperationDto> operations = [.. request.Operations
            .Select(operation => new SyncOperationDto(
                operation.Table,
                operation.Op,
                operation.Id,
                operation.UpdatedAt,
                operation.Data))];

        SyncBatchResult result = await sync.PushAsync(AuthEndpoints.UserId(user), operations, cancellationToken).ConfigureAwait(false);

        return Results.Ok(new SyncBatchResponse(
            result.Cursor,
            [.. result.Rows.Select(ToWire)],
            [.. result.Errors.Select(error => new SyncOperationError(error.Table, error.Op, error.Id, error.Code))]));
    }

    private static SyncRow ToWire(SyncRowDto row)
    {
        return new(
        row.Table,
        row.Op,
        row.Id,
        row.UpdatedAt,
        row.SyncSeq,
        row.Data);
    }
}
