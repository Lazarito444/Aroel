using Aroel.Data.Identity;
using Microsoft.AspNetCore.Identity;

namespace Aroel.Data.Tests.Identity;

public class IdentityOptionsTests
{
    [Fact]
    public void ThePasswordPolicyIsEightCharactersAndNothingElse()
    {
        IdentityOptions options = Resolve();

        Assert.Equal(8, options.Password.RequiredLength);
        Assert.False(options.Password.RequireNonAlphanumeric);
        Assert.False(options.Password.RequireUppercase);
        Assert.False(options.Password.RequireDigit);
        Assert.False(options.Password.RequireLowercase);
    }

    [Fact]
    public void AnEmailAddressBelongsToOneAccount()
    {
        IdentityOptions options = Resolve();

        Assert.True(options.User.RequireUniqueEmail);
    }

    [Fact]
    public void TenFailedAttemptsLockTheAccountForFiveMinutes()
    {
        IdentityOptions options = Resolve();

        Assert.Equal(10, options.Lockout.MaxFailedAccessAttempts);
        Assert.Equal(TimeSpan.FromMinutes(5), options.Lockout.DefaultLockoutTimeSpan);
        Assert.True(options.Lockout.AllowedForNewUsers);
    }

    private static IdentityOptions Resolve()
    {
        IdentityOptions options = new();
        IdentitySetup.Configure(options);

        return options;
    }
}
