using Aroel.Core.Domain.Users;
using Aroel.Core.Results;

namespace Aroel.Application.Accounts;

/// <summary>
/// Creates the account that a local-only journal is adopted by.
/// </summary>
/// <remarks>
/// The account is optional, so this is the moment the journal stops being local-only.
/// The user brings the identifier it already uses, and the server adopts it: no row is
/// re-keyed, and a phone that has been journalling for a month signs up without a
/// migration.
/// </remarks>
public interface IAccountProvisioner
{
    /// <summary>
    /// Creates the account and the journal profile that goes with it.
    /// </summary>
    /// <param name="userId">The identifier the client already uses for its journal.</param>
    /// <param name="email">The address of the account.</param>
    /// <param name="password">The password of the account.</param>
    /// <param name="displayName">The name shown in the app.</param>
    /// <param name="timeZone">The timezone identifier the days are counted in.</param>
    /// <param name="locale">The culture name the interface is rendered in.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The journal profile of the new account, or a failure naming the reason there is none.</returns>
    Task<Result<CoreUser>> ProvisionAsync(
        Guid userId,
        string email,
        string password,
        string displayName,
        string timeZone,
        string locale,
        CancellationToken cancellationToken = default);
}
