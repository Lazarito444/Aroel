namespace Aroel.Application.Auth;

/// <summary>
/// Mints and validates the server's access tokens (§7.2).
/// </summary>
/// <remarks>
/// Short-lived, fifteen minutes; a claim about identity, never about permission.
/// </remarks>
public interface IAccessTokenService
{
    /// <summary>
    /// Issues an access token.
    /// </summary>
    /// <param name="userId">The subject of the token.</param>
    /// <param name="email">The email claim.</param>
    /// <param name="emailVerified">Whether the address is confirmed.</param>
    /// <returns>The token and the moment it stops being accepted.</returns>
    (string Token, DateTimeOffset ExpiresAt) Issue(Guid userId, string email, bool emailVerified);
}
