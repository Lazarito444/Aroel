namespace Aroel.Data.Identity;

/// <summary>
/// The identity rules the product asks for.
/// </summary>
/// <remarks>
/// The rules live here rather than in the composition root so that they can be asserted
/// by a test: a password policy that drifts is a password policy nobody chose.
/// </remarks>
public static class IdentitySetup
{
    /// <summary>
    /// The shortest password the app accepts.
    /// </summary>
    public const int MinimumPasswordLength = 8;

    /// <summary>
    /// The number of failed attempts after which an account is locked out.
    /// </summary>
    public const int MaxFailedAccessAttempts = 10;

    /// <summary>
    /// How long an account stays locked out.
    /// </summary>
    public static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(5);

    /// <summary>
    /// Applies the rules to the identity options.
    /// </summary>
    /// <param name="options">The options to change.</param>
    public static void Configure(Microsoft.AspNetCore.Identity.IdentityOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);

        options.Password.RequiredLength = MinimumPasswordLength;
        options.Password.RequireNonAlphanumeric = false;
        options.Password.RequireUppercase = false;
        options.Password.RequireLowercase = false;
        options.Password.RequireDigit = false;
        options.User.RequireUniqueEmail = true;
        options.Lockout.MaxFailedAccessAttempts = MaxFailedAccessAttempts;
        options.Lockout.DefaultLockoutTimeSpan = LockoutDuration;
        options.Lockout.AllowedForNewUsers = true;
    }
}
