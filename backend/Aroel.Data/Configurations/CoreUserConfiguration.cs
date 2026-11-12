using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the journal profile of a user onto the <c>users</c> table.
/// </summary>
public sealed class CoreUserConfiguration : IEntityTypeConfiguration<CoreUser>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreUser> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("users");
        builder.HasKey(user => user.Id);
        builder.Property(user => user.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(user => user.DisplayName).HasColumnName("display_name").HasMaxLength(CoreUser.MaxDisplayNameLength).IsRequired();
        builder.Property(user => user.TimeZone).HasColumnName("timezone").HasMaxLength(64).IsRequired();
        builder.Property(user => user.Locale).HasColumnName("locale").HasMaxLength(CoreUser.MaxLocaleLength).IsRequired();
        builder.Property(user => user.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(user => user.UpdatedAt).HasColumnName("updated_at").IsRequired();
    }
}
