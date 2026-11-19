using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace Aroel.Api.Jwt;

/// <summary>
/// Reads the Bearer token of a request and puts the caller's claims in the context.
/// </summary>
/// <remarks>
/// The API validates its own HS256 tokens; there is no external authority to ask. A
/// missing or invalid token is simply unauthenticated — the endpoints that need one say
/// <c>RequireAuthorization()</c>.
/// </remarks>
internal sealed class AroelJwtAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly JwtTokenService _tokens;

    /// <summary>
    /// Initialises the handler.
    /// </summary>
    /// <param name="options">The scheme options.</param>
    /// <param name="logger">The logger factory.</param>
    /// <param name="encoder">The encoder.</param>
    /// <param name="clock">The clock.</param>
    /// <param name="tokens">The token service of the host.</param>
    [Obsolete]
    public AroelJwtAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock,
        JwtTokenService tokens)
        : base(options, logger, encoder, clock)
    {
        ArgumentNullException.ThrowIfNull(tokens);
        _tokens = tokens;
    }

    /// <inheritdoc />
    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        string? header = Request.Headers.Authorization;
        if (header is null || !header.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return Task.FromResult(AuthenticateResult.NoResult());
        }

        string token = header["Bearer ".Length..].Trim();
        ClaimsPrincipal? principal = _tokens.Validate(token);

        return Task.FromResult(
            principal is null
                ? AuthenticateResult.Fail("The token does not hold up.")
                : AuthenticateResult.Success(
                    new AuthenticationTicket(principal, JwtTokenService.AuthenticationSchemes.Bearer)));
    }
}
