using Aroel.Core.Domain.ValueObjects;
using Aroel.Data.Converters;
using Aroel.Data.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Data;

/// <summary>
/// The database the journal lives in: the domain entities, plus the identity tables of
/// ASP.NET Core Identity.
/// </summary>
/// <remarks>
/// The domain entities are mapped as they are, without a parallel set of persistence
/// classes, so there is one representation of a day in the code and one in the database.
/// The identity tables are the exception: they belong to ASP.NET Core Identity and own
/// the credentials, while the journal keeps its own rows.
/// </remarks>
public sealed class AroelDbContext : IdentityDbContext<InfrastructureUser, IdentityRole<Guid>, Guid>
{
    /// <summary>
    /// Initialises the context with its options.
    /// </summary>
    /// <param name="options">The options the context is built from.</param>
    public AroelDbContext(DbContextOptions<AroelDbContext> options)
        : base(options)
    {
    }

    /// <summary>
    /// Applies the conversions every entity shares.
    /// </summary>
    /// <param name="configurationBuilder">The conventions to extend.</param>
    /// <remarks>
    /// A version 7 UUID is a <c>uuid</c> column, a local date is a <c>date</c> column and a
    /// rating is a <c>smallint</c> column. The domain keeps the strong types; the database
    /// keeps the plain ones.
    /// </remarks>
    protected override void ConfigureConventions(ModelConfigurationBuilder configurationBuilder)
    {
        ArgumentNullException.ThrowIfNull(configurationBuilder);

        configurationBuilder.Properties<LocalDate>()
            .HaveConversion<LocalDateToDateOnlyConverter>();

        configurationBuilder.Properties<RatingHalf>()
            .HaveConversion<RatingHalfToShortConverter>();

        configurationBuilder.Properties<RatingHalf?>()
            .HaveConversion<NullableRatingHalfToShortConverter>();
    }

    /// <summary>
    /// Builds the model out of the entity configurations.
    /// </summary>
    /// <param name="builder">The model builder.</param>
    protected override void OnModelCreating(ModelBuilder builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(AroelDbContext).Assembly);
        IdentitySchema.UseSnakeCase(builder);

        // The cursor that drives delta sync: one sequence for the whole database, so the
        // order of writes is the same for every device of every account.
        builder.HasSequence<long>("sync_seq").StartsAt(1).IncrementsBy(1);
    }
}
