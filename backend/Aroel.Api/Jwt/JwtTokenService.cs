using System.Security.Claims;
using System.Security.Cryptography;
using Aroel.Application.Auth;
using System.Text;
using System.Text.Json;

namespace Aroel.Api.Jwt;

/// <summary>
/// Issues and validates the server's own HS256 access tokens (§7.2).
/// </summary>
/// <remarks>
/// The access token lives fifteen minutes; it is a claim about identity and expiry, not
/// about permission. Refresh tokens are opaque and stored hashed; they rotate on every
/// use with reuse detection (§7.2). Claims are validated without external packages so the
/// signing secret never leaves this process in a token of the wrong shape.
/// </remarks>
internal sealed class JwtTokenService : IAccessTokenService
{
    private const string Algorithm = "HS256";
    private readonly TimeProvider _timeProvider;
    private readonly byte[] _signingKey;
    private readonly string _issuer;
    private readonly string _audience;

    /// <summary>
    /// Initialises the service with the key that signs the tokens.
    /// </summary>
    /// <param name="configuration">The configuration of the host, read for the `Jwt` section.</param>
    /// <param name="timeProvider">The source of the current moment.</param>
    public JwtTokenService(IConfiguration configuration, TimeProvider timeProvider)
    {
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentNullException.ThrowIfNull(timeProvider);

        _timeProvider = timeProvider;

        string? key = configuration["Jwt:IssuingKey"];
        if (string.IsNullOrWhiteSpace(key))
        {
            if (string.Equals(configuration["ASPNETCORE_ENVIRONMENT"], "Development", StringComparison.OrdinalIgnoreCase))
            {
                // A device signing key per run: sessions die on restart, which is the
                // correct trade for a development host with no secret to hold.
                _signingKey = RandomNumberGenerator.GetBytes(32);
            }
            else
            {
                throw new InvalidOperationException(
                    "The 'Jwt:IssuingKey' is not configured. Set the AROEL_JWT_KEY environment variable.");
            }
        }
        else
        {
            _signingKey = Encoding.UTF8.GetBytes(key);
        }
        _issuer = configuration["Jwt:Issuer"] ?? "aroel";
        _audience = configuration["Jwt:Audience"] ?? "aroel-app";
    }

    /// <summary>How long an access token lives.</summary>
    public static TimeSpan Lifetime { get; } = TimeSpan.FromMinutes(15);

    /// <summary>
    /// Mints an access token for a user.
    /// </summary>
    /// <param name="userId">The subject of the token.</param>
    /// <param name="email">The email claim.</param>
    /// <param name="emailVerified">Whether the address is confirmed; sync waits for it.</param>
    /// <returns>The token and the moment it stops being accepted.</returns>
    public (string Token, DateTimeOffset ExpiresAt) Issue(Guid userId, string email, bool emailVerified)
    {
        DateTimeOffset now = _timeProvider.GetUtcNow();
        DateTimeOffset expires = now.Add(Lifetime);

        Dictionary<string, object?> header = new()
        {
            ["alg"] = Algorithm,
            ["typ"] = "JWT"
        };
        Dictionary<string, object?> payload = new()
        {
            ["iss"] = _issuer,
            ["aud"] = _audience,
            ["sub"] = userId.ToString(),
            ["email"] = email,
            ["email_verified"] = emailVerified,
            ["jti"] = Guid.CreateVersion7().ToString(),
            ["iat"] = now.ToUnixTimeSeconds(),
            ["exp"] = expires.ToUnixTimeSeconds()
        };

        string encoded = $"{EncodeJson(header)}.{EncodeJson(payload)}";
        string signature = Sign(encoded);

        return ($"{encoded}.{signature}", expires);
    }

    /// <summary>
    /// Validates an access token, when it holds up.
    /// </summary>
    /// <param name="token">The token as presented in the Authorization header.</param>
    /// <returns>The security principal of the token, or <see langword="null"/> when it does not hold up.</returns>
    public ClaimsPrincipal? Validate(string token)
    {
        ArgumentNullException.ThrowIfNull(token);

        string[] parts = token.Split('.');
        if (parts.Length != 3)
        {
            return null;
        }

        string signingInput = $"{parts[0]}.{parts[1]}";
        string expected = Sign(signingInput);

        if (!CryptographicOperations.FixedTimeEquals(
            Base64Url.DecodeFromString(expected),
            Base64Url.DecodeFromString(parts[2])))
        {
            return null;
        }

        JsonDocument document;
        try
        {
            document = JsonDocument.Parse(Base64Url.DecodeToString(parts[1]));
        }
        catch (JsonException)
        {
            return null;
        }

        using (document)
        {
            JsonElement root = document.RootElement;

            if (!root.TryGetProperty("iss", out JsonElement iss) || iss.GetString() != _issuer)
            {
                return null;
            }

            if (!root.TryGetProperty("aud", out JsonElement aud) || aud.GetString() != _audience)
            {
                return null;
            }

            if (!root.TryGetProperty("exp", out JsonElement exp) || exp.GetInt64() < _timeProvider.GetUtcNow().ToUnixTimeSeconds())
            {
                return null;
            }

            if (!root.TryGetProperty("sub", out JsonElement sub) || !Guid.TryParse(sub.GetString(), out Guid userId))
            {
                return null;
            }

            string email = root.TryGetProperty("email", out JsonElement emailElement)
                ? emailElement.GetString() ?? string.Empty
                : string.Empty;
            bool verified = root.TryGetProperty("email_verified", out JsonElement verifiedElement) &&
                verifiedElement.ValueKind == JsonValueKind.True;

            List<Claim> claims =
            [
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim(ClaimTypes.Email, email),
                new Claim("email_verified", verified ? "true" : "false")
            ];

            return new ClaimsPrincipal(new ClaimsIdentity(claims, AuthenticationSchemes.Bearer, ClaimTypes.NameIdentifier, ClaimTypes.Email));
        }
    }

    /// <summary>The scheme this service signs and the handler validates.</summary>
    internal static class AuthenticationSchemes
    {
        /// <summary>The bearer scheme.</summary>
        public const string Bearer = "AroelBearer";
    }

    private string Sign(string input)
    {
        using HMACSHA256 algorithm = new(_signingKey);
        byte[] hash = algorithm.ComputeHash(Encoding.UTF8.GetBytes(input));
        return Base64Url.EncodeToString(hash);
    }

    private static string EncodeJson(IReadOnlyDictionary<string, object?> value)
    {
        return Base64Url.EncodeToString(JsonSerializer.SerializeToUtf8Bytes(value));
    }
}
