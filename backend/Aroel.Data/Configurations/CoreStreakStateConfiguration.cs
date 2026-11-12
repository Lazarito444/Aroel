using Aroel.Core.Domain.Streak;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the streak onto the <c>streak_states</c> table, together with the days the user
/// recovered by hand.
/// </summary>
public sealed class CoreStreakStateConfiguration : IEntityTypeConfiguration<CoreStreakState>
{
    /// <summary>
    /// The name of the shadow foreign key that points at the streak a recovery belongs to.
    /// </summary>
    public const string RestorationForeignKey = "StreakStateId";

    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreStreakState> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("streak_states");
        builder.HasKey(streak => streak.Id);
        builder.Property(streak => streak.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(streak => streak.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(streak => streak.CurrentStreak).HasColumnName("current_streak").IsRequired();
        builder.Property(streak => streak.LongestStreak).HasColumnName("longest_streak").IsRequired();
        builder.Property(streak => streak.GraceRemaining).HasColumnName("grace_remaining").IsRequired();
        builder.Property(streak => streak.LastKeptDate).HasColumnName("last_kept_date");
        builder.Property(streak => streak.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(streak => streak.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.HasIndex(streak => streak.UserId).IsUnique();
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(streak => streak.UserId).OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(streak => streak.Restorations)
            .WithOne()
            .HasForeignKey(RestorationForeignKey)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(streak => streak.Restorations).HasField("_restorations").UsePropertyAccessMode(PropertyAccessMode.Field);
    }
}
