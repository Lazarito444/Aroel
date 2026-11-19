namespace Aroel.Data.Services;

/// <summary>What the service knows about a user, for the wire.</summary>
/// <param name="Id">The identifier of the account and of the journal it owns.</param>
/// <param name="Email">The address of the account.</param>
/// <param name="DisplayName">The name shown in the app.</param>
/// <param name="TimeZone">The timezone identifier the days are counted in.</param>
/// <param name="Locale">The culture name the interface is rendered in.</param>
/// <param name="EmailVerified">Whether the address is confirmed.</param>
/// <param name="CreatedAt">When the account came into being.</param>
/// <param name="UpdatedAt">When the account last changed.</param>
public sealed record ServiceUser(
    Guid Id,
    string Email,
    string DisplayName,
    string TimeZone,
    string Locale,
    bool EmailVerified,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);

/// <summary>The tokens of a session.</summary>
/// <param name="AccessToken">The bearer token, fifteen minutes.</param>
/// <param name="RefreshToken">The opaque token that buys the next pair, sixty days.</param>
/// <param name="AccessTokenExpiresAt">When the bearer token stops being accepted.</param>
/// <param name="RefreshTokenExpiresAt">When the refresh token stops being accepted.</param>
public sealed record ServiceTokens(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset AccessTokenExpiresAt,
    DateTimeOffset RefreshTokenExpiresAt);

/// <summary>What a sign-in answers with.</summary>
/// <param name="Succeeded">Whether the credentials held up.</param>
/// <param name="User">The journal profile, when sign-in succeeded.</param>
/// <param name="Tokens">The session, when sign-in succeeded.</param>
/// <param name="ErrorCode">The code of the failure, when there was one.</param>
public sealed record ServiceAuthResult(bool Succeeded, ServiceUser? User, ServiceTokens? Tokens, string? ErrorCode)
{
    /// <summary>The failure of a sign-in.</summary>
    public static ServiceAuthResult Failure(string code)
    {
        return new ServiceAuthResult(false, null, null, code);
    }
}
