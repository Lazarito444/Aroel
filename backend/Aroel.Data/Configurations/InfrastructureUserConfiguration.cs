using Aroel.Data.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the identity row of an account onto the <c>aspnet_users</c> table, and ties it to
/// the journal profile that shares its key.
/// </summary>
/// <remarks>
/// The two halves of an account share a primary key: the account's identifier is the
/// profile's identifier, so an account always has exactly one profile, a profile always
/// belongs to exactly one account, and the client that generated the identifier for its
/// local-only journal keeps the same one when it signs up.
/// </remarks>
public sealed class InfrastructureUserConfiguration : IEntityTypeConfiguration<InfrastructureUser>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<InfrastructureUser> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("aspnet_users");
        builder.HasOne(user => user.CoreUser)
            .WithOne()
            .HasForeignKey<InfrastructureUser>(user => user.Id)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
