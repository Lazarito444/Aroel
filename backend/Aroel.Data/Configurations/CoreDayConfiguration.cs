using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the record of a day onto the <c>days</c> table, together with the gratitude
/// lines and the tags that hang off it.
/// </summary>
public sealed class CoreDayConfiguration : IEntityTypeConfiguration<CoreDay>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreDay> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("days");
        builder.HasKey(day => day.Id);
        builder.Property(day => day.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(day => day.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(day => day.LocalDate).HasColumnName("local_date").IsRequired();
        builder.Property(day => day.Rating).HasColumnName("rating_half");
        builder.Property(day => day.Note).HasColumnName("note").HasMaxLength(CoreDay.MaxNoteLength);
        builder.Property(day => day.RatedAt).HasColumnName("rated_at");
        builder.Property(day => day.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(day => day.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(day => day.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(day => new { day.UserId, day.LocalDate }).IsUnique();
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(day => day.UserId).OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(day => day.GratitudeItems)
            .WithOne()
            .HasForeignKey(item => item.DayId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(day => day.GratitudeItems).HasField("_gratitudeItems").UsePropertyAccessMode(PropertyAccessMode.Field);

        builder.HasMany(day => day.Tags)
            .WithOne()
            .HasForeignKey(tag => tag.DayId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.Navigation(day => day.Tags).HasField("_tags").UsePropertyAccessMode(PropertyAccessMode.Field);

        builder.HasOne(day => day.Sentiment)
            .WithOne()
            .HasForeignKey<CoreDaySentiment>(sentiment => sentiment.DayId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
