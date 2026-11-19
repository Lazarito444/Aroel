using System.Security.Claims;
using Aroel.Api.Contracts;
using Aroel.Data.Services;

namespace Aroel.Api.Endpoints;

/// <summary>
/// The journal profile endpoints (§7.2).
/// </summary>
internal static class MeEndpoints
{
    /// <summary>Maps the profile endpoints onto the app.</summary>
    public static IEndpointRouteBuilder MapMeEndpoints(this IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        app.MapGet("/me", GetMeAsync).RequireAuthorization();
        app.MapPatch("/me", UpdateMeAsync).RequireAuthorization();
        app.MapDelete("/me", DeleteMeAsync).RequireAuthorization();

        return app;
    }

    private static async Task<IResult> GetMeAsync(ClaimsPrincipal user, AuthService auth, CancellationToken cancellationToken)
    {
        ServiceUser? me = await auth.GetMeAsync(AuthEndpoints.UserId(user), cancellationToken).ConfigureAwait(false);
        return me is null
            ? AuthEndpoints.Fail("user.not_found", StatusCodes.Status404NotFound)
            : Results.Ok(ToResponse(me));
    }

    private static async Task<IResult> UpdateMeAsync(UpdateMeRequest request, ClaimsPrincipal user, AuthService auth, CancellationToken cancellationToken)
    {
        (ServiceUser? me, string? errorCode) = await auth.UpdateMeAsync(
            AuthEndpoints.UserId(user),
            request.DisplayName,
            request.TimeZone,
            cancellationToken).ConfigureAwait(false);

        return me is null
            ? AuthEndpoints.Fail(errorCode ?? "user.not_found", StatusCodes.Status400BadRequest)
            : Results.Ok(ToResponse(me));
    }

    private static async Task<IResult> DeleteMeAsync(ClaimsPrincipal user, AuthService auth, CancellationToken cancellationToken)
    {
        await auth.DeleteMeAsync(AuthEndpoints.UserId(user), cancellationToken).ConfigureAwait(false);
        return Results.NoContent();
    }

    private static UserResponse ToResponse(ServiceUser me)
    {
        return new(
        me.Id.ToString(),
        me.Email,
        me.DisplayName,
        me.TimeZone,
        me.Locale,
        me.EmailVerified,
        me.CreatedAt,
        me.UpdatedAt);
    }
}
