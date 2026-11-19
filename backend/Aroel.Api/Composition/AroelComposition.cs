using System.Threading.RateLimiting;
using Aroel.Api.Auth;
using Aroel.Api.Jwt;
using Aroel.Application.Accounts;
using Aroel.Application.Auth;
using Aroel.Application.Email;
using Aroel.Application.Identity;
using Aroel.Data;
using Aroel.Data.Identity;
using Aroel.Data.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Api.Composition;

/// <summary>
/// What the server is made of: the database, the identity store, the ports the use
/// cases need, the tokens it seals and the limits it keeps.
/// </summary>
/// <remarks>
/// The wiring lives here rather than in <c>Program.cs</c> so that the composition root
/// reads as a list of decisions instead of a list of framework calls.
/// </remarks>
internal static class AroelComposition
{
    extension(IServiceCollection services)
    {
        /// <summary>
        /// Registers everything the server needs to answer a request.
        /// </summary>
        /// <param name="configuration">The configuration of the host.</param>
        /// <returns>The same services, so calls can be chained.</returns>
        public IServiceCollection AddAroelServices(IConfiguration configuration)
        {
            ArgumentNullException.ThrowIfNull(configuration);

            services.AddDbContext<AroelDbContext>(options =>
            {
                string provider = configuration["Storage:Provider"] ?? "npgsql";
                if (string.Equals(provider, "inmemory", StringComparison.OrdinalIgnoreCase))
                {
                    options.UseInMemoryDatabase($"aroel-{Guid.NewGuid():N}");
                    return;
                }

                string connectionString = configuration.GetConnectionString("Aroel")
                    ?? throw new InvalidOperationException("The 'Aroel' connection string is not configured.");
                options.UseNpgsql(connectionString);
            });

            services.AddDataProtection();
            services.AddIdentityCore<InfrastructureUser>(IdentitySetup.Configure)
                .AddEntityFrameworkStores<AroelDbContext>()
                .AddDefaultTokenProviders();
            services.AddSingleton(TimeProvider.System);

            services.AddSingleton(sp => new JwtTokenService(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<TimeProvider>()));
            services.AddSingleton<IAccessTokenService>(sp => sp.GetRequiredService<JwtTokenService>());
            services.AddAuthentication(JwtTokenService.AuthenticationSchemes.Bearer)
                .AddScheme<AuthenticationSchemeOptions, AroelJwtAuthenticationHandler>(
                    JwtTokenService.AuthenticationSchemes.Bearer,
                    null);
            services.AddAuthorization();
            services.AddHttpClient("oidc");

            services.AddSingleton<IEmailSender, LogEmailSender>();
            services.AddSingleton<IProviderTokenValidator, OidcProviderTokenValidator>();
            services.AddScoped<IAccountProvisioner, IdentityAccountProvisioner>();
            services.AddScoped<AuthService>();
            services.AddScoped<SyncService>();
            services.AddScoped<DayReadService>();

            int authPerMinute = configuration.GetValue("RateLimits:AuthPerMinute", 5);
            int syncPerMinute = configuration.GetValue("RateLimits:SyncPerMinute", 60);
            int insightsPerMinute = configuration.GetValue("RateLimits:InsightsPerMinute", 30);

            services.AddRateLimiter(options =>
            {
                options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
                options.AddPolicy("auth", httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = authPerMinute,
                            Window = TimeSpan.FromMinutes(1),
                            QueueLimit = 0
                        }));
                options.AddPolicy("sync", httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = syncPerMinute,
                            Window = TimeSpan.FromMinutes(1),
                            QueueLimit = 0
                        }));
                options.AddPolicy("insights", httpContext =>
                    RateLimitPartition.GetFixedWindowLimiter(
                        httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                        _ => new FixedWindowRateLimiterOptions
                        {
                            PermitLimit = insightsPerMinute,
                            Window = TimeSpan.FromMinutes(1),
                            QueueLimit = 0
                        }));
            });

            return services;
        }
    }
}
