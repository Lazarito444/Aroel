using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;

namespace Aroel.Api.Tests;

/// <summary>
/// The app wired the way a test environment wires it: the in-memory store, a fixed
/// signing key and rate limits that never bite.
/// </summary>
public sealed class ApiFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureAppConfiguration(configuration => configuration.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["Storage:Provider"] = "inmemory",
            ["Jwt:IssuingKey"] = "aroel-test-signing-key-0123456789abcdef",
            ["RateLimits:AuthPerMinute"] = "1000",
            ["RateLimits:SyncPerMinute"] = "1000",
            ["RateLimits:InsightsPerMinute"] = "1000"
        }));
    }
}
