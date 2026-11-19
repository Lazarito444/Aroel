namespace Aroel.Application.Identity;

/// <summary>
/// What the server believes about a sign-in it brokered with a provider.
/// </summary>
/// <param name="Provider">The provider that issued the token, `apple` or `google`.</param>
/// <param name="Subject">The stable identifier of the person at the provider.</param>
/// <param name="Email">The address the provider vouches for.</param>
public sealed record ProviderIdentity(string Provider, string Subject, string Email);

/// <summary>
/// Validates the identity token a device brings back from a provider.
/// </summary>
/// <remarks>
/// The device never decides who the reader is; the server validates the token against
/// the provider's well-known keys. Implementations are registered per provider and fail
/// closed: an unknown token, an unknown issuer and an unreachable provider all answer
/// with <see langword="null"/>.
/// </remarks>
public interface IProviderTokenValidator
{
    /// <summary>
    /// Validates a provider token.
    /// </summary>
    /// <param name="provider">The provider that issued the token.</param>
    /// <param name="idToken">The token as the device presented it.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The identity, or <see langword="null"/> when the token does not hold up.</returns>
    Task<ProviderIdentity?> ValidateAsync(string provider, string idToken, CancellationToken cancellationToken = default);
}
