using System.Security.Claims;
using Aroel.Api.Contracts;
using Aroel.Data.Services;

namespace Aroel.Api.Endpoints;

/// <summary>
/// The account endpoints (§7.2).
/// </summary>
/// <remarks>
/// Every failure answers with a code the client turns into a sentence. The journal is
/// never gated: writing never asks for an account, and sync asks only for a confirmed
/// address (§5.1).
/// </remarks>
internal static class AuthEndpoints
{
    /// <summary>Maps the auth endpoints onto the app.</summary>
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        RouteGroupBuilder auth = app.MapGroup("/auth");

        auth.MapPost("/register", RegisterAsync)
            .RequireRateLimiting("auth");

        auth.MapPost("/login", LoginAsync)
            .RequireRateLimiting("auth");

        auth.MapPost("/oauth", OAuthAsync)
            .RequireRateLimiting("auth");

        auth.MapPost("/refresh", RefreshAsync)
            .RequireRateLimiting("auth");

        auth.MapPost("/logout", LogoutAsync)
            .RequireRateLimiting("auth");

        auth.MapPost("/password", ChangePasswordAsync)
            .RequireAuthorization()
            .RequireRateLimiting("auth");

        auth.MapPost("/email-verification", SendVerificationAsync)
            .RequireAuthorization()
            .RequireRateLimiting("auth");

        app.MapGet("/auth/confirm-email", ConfirmEmailAsync)
            .RequireRateLimiting("auth");

        return app;
    }

    private static async Task<IResult> RegisterAsync(RegisterRequest request, AuthService auth, CancellationToken cancellationToken)
    {
        ServiceAuthResult result = await auth.RegisterAsync(
            request.UserId,
            request.Email,
            request.Password,
            request.DisplayName,
            request.TimeZone,
            request.Locale,
            cancellationToken).ConfigureAwait(false);

        return result.Succeeded
            ? Results.Ok(ToResponse(result))
            : Fail(result.ErrorCode!);
    }

    private static async Task<IResult> LoginAsync(LoginRequest request, AuthService auth, CancellationToken cancellationToken)
    {
        ServiceAuthResult result = await auth.LoginAsync(request.Email, request.Password, cancellationToken).ConfigureAwait(false);

        return result.Succeeded
            ? Results.Ok(ToResponse(result))
            : Fail(result.ErrorCode!);
    }

    private static async Task<IResult> OAuthAsync(OAuthRequest request, AuthService auth, CancellationToken cancellationToken)
    {
        ServiceAuthResult result = await auth.OAuthAsync(
            request.Provider,
            request.IdToken,
            request.UserId,
            request.TimeZone,
            request.Locale,
            request.DisplayName,
            cancellationToken).ConfigureAwait(false);

        return result.Succeeded
            ? Results.Ok(ToResponse(result))
            : Fail(result.ErrorCode!);
    }

    private static async Task<IResult> RefreshAsync(RefreshRequest request, AuthService auth, CancellationToken cancellationToken)
    {
        ServiceAuthResult result = await auth.RefreshAsync(request.RefreshToken, cancellationToken).ConfigureAwait(false);
        if (!result.Succeeded)
        {
            return Fail(result.ErrorCode!, StatusCodes.Status401Unauthorized);
        }

        ServiceTokens tokens = result.Tokens!;
        return Results.Ok(new TokenResponse(
            tokens.AccessToken,
            tokens.RefreshToken,
            tokens.AccessTokenExpiresAt,
            tokens.RefreshTokenExpiresAt));
    }

    private static async Task<IResult> LogoutAsync(RefreshRequest? request, AuthService auth, CancellationToken cancellationToken)
    {
        if (request is not null && !string.IsNullOrEmpty(request.RefreshToken))
        {
            await auth.LogoutAsync(request.RefreshToken, cancellationToken).ConfigureAwait(false);
        }

        return Results.NoContent();
    }

    private static async Task<IResult> ChangePasswordAsync(
        PasswordChangeRequest request,
        ClaimsPrincipal user,
        AuthService auth,
        CancellationToken cancellationToken)
    {
        string? code = await auth.ChangePasswordAsync(
            UserId(user),
            request.CurrentPassword,
            request.NewPassword,
            cancellationToken).ConfigureAwait(false);

        return code is null
            ? Results.NoContent()
            : Fail(code, code == "auth.invalid_credentials" ? StatusCodes.Status401Unauthorized : StatusCodes.Status400BadRequest);
    }

    private static async Task<IResult> SendVerificationAsync(
        ClaimsPrincipal user,
        AuthService auth,
        CancellationToken cancellationToken)
    {
        await auth.SendVerificationAsync(UserId(user), cancellationToken).ConfigureAwait(false);
        return Results.NoContent();
    }

    private static async Task<IResult> ConfirmEmailAsync(Guid userId, string token, AuthService auth)
    {
        string? code = await auth.ConfirmEmailAsync(userId, token).ConfigureAwait(false);
        return code is null ? Results.NoContent() : Fail(code, StatusCodes.Status400BadRequest);
    }

    internal static AuthResponse ToResponse(ServiceAuthResult result)
    {
        return new(
        new UserResponse(
            result.User!.Id.ToString(),
            result.User.Email,
            result.User.DisplayName,
            result.User.TimeZone,
            result.User.Locale,
            result.User.EmailVerified,
            result.User.CreatedAt,
            result.User.UpdatedAt),
        new TokenResponse(
            result.Tokens!.AccessToken,
            result.Tokens.RefreshToken,
            result.Tokens.AccessTokenExpiresAt,
            result.Tokens.RefreshTokenExpiresAt));
    }

    internal static IResult Fail(string code, int status = StatusCodes.Status400BadRequest)
    {
        int statusCode = code switch
        {
            "auth.email_taken" => StatusCodes.Status409Conflict,
            "auth.user_id_taken" => StatusCodes.Status409Conflict,
            "auth.invalid_credentials" => StatusCodes.Status401Unauthorized,
            "auth.account_locked" => StatusCodes.Status403Forbidden,
            "refresh_token.reused" => StatusCodes.Status401Unauthorized,
            "refresh_token.expired" => StatusCodes.Status401Unauthorized,
            "auth.rate_limited" => StatusCodes.Status429TooManyRequests,
            _ => status
        };

        return Results.Json(new ErrorResponse(code), statusCode: statusCode);
    }

    internal static Guid UserId(ClaimsPrincipal user)
    {
        return Guid.TryParse(user.FindFirstValue(ClaimTypes.NameIdentifier), out Guid id)
            ? id
            : throw new InvalidOperationException("The subject of the token is not a user identifier.");
    }

    internal static bool EmailVerified(ClaimsPrincipal user)
    {
        return string.Equals(user.FindFirstValue("email_verified"), "true", StringComparison.OrdinalIgnoreCase);
    }
}
