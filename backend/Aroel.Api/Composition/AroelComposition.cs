using Aroel.Application.Accounts;
using Aroel.Data;
using Aroel.Data.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Api.Composition;

/// <summary>
/// What the server is made of: the database, the identity store and the ports the use
/// cases need.
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
        /// <param name="connectionString">The Postgres connection string of the journal.</param>
        /// <returns>The same services, so calls can be chained.</returns>
        public IServiceCollection AddAroelServices(string connectionString)
        {
            ArgumentNullException.ThrowIfNull(connectionString);

            services.AddDbContext<AroelDbContext>(options => options.UseNpgsql(connectionString));
            services.AddDataProtection();
            services.AddIdentityCore<InfrastructureUser>(IdentitySetup.Configure)
                .AddEntityFrameworkStores<AroelDbContext>()
                .AddDefaultTokenProviders();
            services.AddSingleton(TimeProvider.System);
            services.AddScoped<IAccountProvisioner, IdentityAccountProvisioner>();

            return services;
        }
    }
}
