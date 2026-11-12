using Aroel.Core.Domain.Users;
using Microsoft.AspNetCore.Identity;

namespace Aroel.Data.Identity;

/// <summary>
/// The identity row of an account: the email address, the credential and everything
/// ASP.NET Core Identity needs to keep.
/// </summary>
/// <remarks>
/// The account is optional and the journal is not: a client that never signs up still
/// owns a user, but it owns no identity row. The two are separate on purpose, so that
/// deleting an account or rotating a credential never touches the journal, and so that
/// the domain model stays free of authentication state.
/// <para>
/// The identifier is the one the client generated for itself, which is what lets a
/// local-only journal be adopted by an account without re-keying a single row.
/// </para>
/// </remarks>
public sealed class InfrastructureUser : IdentityUser<Guid>
{
    /// <summary>
    /// Gets or sets the journal profile of the account.
    /// </summary>
    /// <remarks>
    /// The profile shares the primary key of this row, so an account always has exactly
    /// one profile and a profile always belongs to exactly one account.
    /// </remarks>
    public CoreUser? CoreUser { get; set; }
}
