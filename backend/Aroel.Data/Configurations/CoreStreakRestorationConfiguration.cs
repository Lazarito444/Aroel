using Aroel.Core.Domain.Streak;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps a day recovered by hand onto the <c>streak_restorations</c> table.
/// </summary>
public sealed class CoreStreakRestorationConfiguration : IEntityTypeConfiguration<CoreStreakRestoration>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreStreakRestoration> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("streak_restorations");
        builder.HasKey(restoration => restoration.Id);
        builder.Property(restoration => restoration.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(restoration => restoration.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(restoration => restoration.LocalDate).HasColumnName("local_date").IsRequired();
        builder.Property(restoration => restoration.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(restoration => restoration.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.HasIndex(restoration => new { restoration.UserId, restoration.LocalDate }).IsUnique();
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(restoration => restoration.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.Property<Guid>(CoreStreakStateConfiguration.RestorationForeignKey).HasColumnName("streak_state_id");
    }
}
