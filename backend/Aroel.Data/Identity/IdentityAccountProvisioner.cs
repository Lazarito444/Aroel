using Aroel.Application.Accounts;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Users;
using Aroel.Core.Results;
using Microsoft.AspNetCore.Identity;

namespace Aroel.Data.Identity;

/// <summary>
/// Creates accounts with ASP.NET Core Identity, and the journal profile that goes with
/// them.
/// </summary>
/// <remarks>
/// The two rows are written together and share a key: the account holds the credential
/// and the email, the profile holds the name, the timezone and the locale. Splitting them
/// is what lets an account be deleted without touching the journal, and lets the journal
/// exist before there is an account at all.
/// </remarks>
public sealed class IdentityAccountProvisioner : IAccountProvisioner
{
    private readonly UserManager<InfrastructureUser> _userManager;
    private readonly TimeProvider _timeProvider;

    /// <summary>
    /// Initialises the provisioner with the identity manager it writes through.
    /// </summary>
    /// <param name="userManager">The manager that owns the identity rows.</param>
    /// <param name="timeProvider">The source of the current moment.</param>
    public IdentityAccountProvisioner(UserManager<InfrastructureUser> userManager, TimeProvider timeProvider)
    {
        ArgumentNullException.ThrowIfNull(userManager);
        ArgumentNullException.ThrowIfNull(timeProvider);

        _userManager = userManager;
        _timeProvider = timeProvider;
    }

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
    public async Task<Result<CoreUser>> ProvisionAsync(
        Guid userId,
        string email,
        string password,
        string displayName,
        string timeZone,
        string locale,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(email);
        ArgumentNullException.ThrowIfNull(password);
        ArgumentNullException.ThrowIfNull(displayName);
        ArgumentNullException.ThrowIfNull(timeZone);
        ArgumentNullException.ThrowIfNull(locale);

        Result<CoreUser> profile = CoreUser.Create(userId, displayName, timeZone, locale, _timeProvider.GetUtcNow());
        if (profile.IsFailure)
        {
            return Result.Failure<CoreUser>(profile.Error!);
        }

        InfrastructureUser identity = new()
        {
            Id = userId,
            UserName = email,
            Email = email,
            CoreUser = profile.Value
        };

        IdentityResult created = await _userManager.CreateAsync(identity, password).ConfigureAwait(false);

        return created.Succeeded
            ? Result.Success(profile.Value)
            : Result.Failure<CoreUser>(new AppError(ErrorCodes.AccountCreationFailed, string.Join("; ", created.Errors.Select(error => error.Code))));
    }
}
