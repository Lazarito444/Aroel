using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Aroel.Api.Jwt;
using Aroel.Application.Identity;

namespace Aroel.Api.Auth;

/// <summary>
/// Validates the identity tokens of Apple and Google against their published keys.
/// </summary>
/// <remarks>
/// The device never decides who the reader is; this validator either proves the token or
/// it refuses it. Keys are fetched from the provider's well-known endpoint, cached for
/// ten minutes, and a missing configuration, an unreachable provider and an unknown token
/// are all the same answer: <see langword="null"/>.
/// </remarks>
internal sealed class OidcProviderTokenValidator : IProviderTokenValidator
{
    private static readonly TimeSpan _cacheLifetime = TimeSpan.FromMinutes(10);
    private static readonly Lock _cacheGate = new();
    private static readonly Dictionary<string, CachedKeys> _keyCache = [];

    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly TimeProvider _timeProvider;

    /// <summary>
    /// Initialises the validator.
    /// </summary>
    /// <param name="httpClientFactory">The factory for the well-known endpoints.</param>
    /// <param name="configuration">The configuration of the host, read for `Apple:ClientId` and `Google:ClientId`.</param>
    /// <param name="timeProvider">The source of the current moment.</param>
    public OidcProviderTokenValidator(IHttpClientFactory httpClientFactory, IConfiguration configuration, TimeProvider timeProvider)
    {
        ArgumentNullException.ThrowIfNull(httpClientFactory);
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentNullException.ThrowIfNull(timeProvider);

        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
        _timeProvider = timeProvider;
    }

    /// <inheritdoc />
    public async Task<ProviderIdentity?> ValidateAsync(string provider, string idToken, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(provider);
        ArgumentNullException.ThrowIfNull(idToken);

        if (!TryGetProviderSettings(provider, out ProviderSettings? settings))
        {
            return null;
        }

        // TryGetProviderSettings only returns true with a configured provider.
        ProviderSettings configured = settings!;

        string[] parts = idToken.Split('.');
        if (parts.Length != 3)
        {
            return null;
        }

        string signingInput = $"{parts[0]}.{parts[1]}";
        JsonDocument header;
        JsonDocument payload;
        try
        {
            header = JsonDocument.Parse(Base64Url.DecodeToString(parts[0]));
            payload = JsonDocument.Parse(Base64Url.DecodeToString(parts[1]));
        }
        catch (JsonException)
        {
            return null;
        }

        using (header)
        using (payload)
        {
            JsonElement root = payload.RootElement;

            if (!root.TryGetProperty("iss", out JsonElement iss) || iss.GetString() != configured.Issuer)
            {
                return null;
            }

            if (!root.TryGetProperty("aud", out JsonElement aud) || aud.GetString() != configured.ClientId)
            {
                return null;
            }

            if (!root.TryGetProperty("exp", out JsonElement exp) || exp.GetInt64() < _timeProvider.GetUtcNow().ToUnixTimeSeconds())
            {
                return null;
            }

            if (!root.TryGetProperty("sub", out JsonElement sub) || string.IsNullOrWhiteSpace(sub.GetString()))
            {
                return null;
            }

            JsonElement headerRoot = header.RootElement;
            if (!headerRoot.TryGetProperty("kid", out JsonElement kid))
            {
                return null;
            }

            if (!await VerifySignatureAsync(configured.JwksUrl, kid.GetString() ?? string.Empty, signingInput, parts[2], cancellationToken).ConfigureAwait(false))
            {
                return null;
            }

            string email = root.TryGetProperty("email", out JsonElement emailElement)
                ? emailElement.GetString() ?? string.Empty
                : string.Empty;

            return new ProviderIdentity(provider, sub.GetString()!, email);
        }
    }

    private async Task<bool> VerifySignatureAsync(string jwksUrl, string keyId, string signingInput, string encodedSignature, CancellationToken cancellationToken)
    {
        IReadOnlyList<ProviderKey> keys = await GetKeysAsync(jwksUrl, cancellationToken).ConfigureAwait(false);
        ProviderKey? key = keys.FirstOrDefault(item => string.Equals(item.KeyId, keyId, StringComparison.Ordinal));
        if (key is null)
        {
            return false;
        }

        using RSA rsa = RSA.Create();
        rsa.ImportParameters(new RSAParameters
        {
            Modulus = Base64Url.DecodeFromString(key.Modulus),
            Exponent = Base64Url.DecodeFromString(key.Exponent)
        });

        byte[] signature;
        try
        {
            signature = Base64Url.DecodeFromString(encodedSignature);
        }
        catch (FormatException)
        {
            return false;
        }

        return rsa.VerifyData(
            Encoding.UTF8.GetBytes(signingInput),
            signature,
            HashAlgorithmName.SHA256,
            RSASignaturePadding.Pkcs1);
    }

    private async Task<IReadOnlyList<ProviderKey>> GetKeysAsync(string jwksUrl, CancellationToken cancellationToken)
    {
        DateTimeOffset now = _timeProvider.GetUtcNow();

        lock (_cacheGate)
        {
            if (_keyCache.TryGetValue(jwksUrl, out CachedKeys? cached) && cached.ExpiresAt > now)
            {
                return cached.Keys;
            }
        }

        using HttpClient client = _httpClientFactory.CreateClient("oidc");
        string response = await client.GetStringAsync(jwksUrl, cancellationToken).ConfigureAwait(false);
        JsonDocument document = JsonDocument.Parse(response);
        using (document)
        {
            List<ProviderKey> keys = [];
            foreach (JsonElement key in document.RootElement.GetProperty("keys").EnumerateArray())
            {
                if (key.GetProperty("kty").GetString() != "RSA")
                {
                    continue;
                }

                keys.Add(new ProviderKey(
                    KeyId: key.GetProperty("kid").GetString() ?? string.Empty,
                    Modulus: key.GetProperty("n").GetString() ?? string.Empty,
                    Exponent: key.GetProperty("e").GetString() ?? string.Empty));
            }

            lock (_cacheGate)
            {
                _keyCache[jwksUrl] = new CachedKeys(keys, now.Add(_cacheLifetime));
            }

            return keys;
        }
    }

    private bool TryGetProviderSettings(string provider, out ProviderSettings? settings)
    {
        settings = provider.Trim().ToLowerInvariant() switch
        {
            "apple" => new ProviderSettings(
                JwksUrl: "https://appleid.apple.com/auth/keys",
                Issuer: "https://appleid.apple.com",
                ClientId: _configuration["Apple:ClientId"] ?? string.Empty),
            "google" => new ProviderSettings(
                JwksUrl: "https://www.googleapis.com/oauth2/v3/certs",
                Issuer: "https://accounts.google.com",
                ClientId: _configuration["Google:ClientId"] ?? string.Empty),
            _ => null
        };

        return settings is not null && !string.IsNullOrWhiteSpace(settings.ClientId);
    }

    private sealed record ProviderSettings(string JwksUrl, string Issuer, string ClientId);

    private sealed record CachedKeys(IReadOnlyList<ProviderKey> Keys, DateTimeOffset ExpiresAt);

    private sealed record ProviderKey(string KeyId, string Modulus, string Exponent);
}
