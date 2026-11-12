using Aroel.Core.Domain.Journal;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps a gratitude line onto the <c>gratitude_items</c> table.
/// </summary>
public sealed class CoreGratitudeItemConfiguration : IEntityTypeConfiguration<CoreGratitudeItem>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreGratitudeItem> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("gratitude_items");
        builder.HasKey(item => item.Id);
        builder.Property(item => item.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(item => item.DayId).HasColumnName("day_id").IsRequired();
        builder.Property(item => item.Position).HasColumnName("position").IsRequired();
        builder.Property(item => item.Text).HasColumnName("text").HasMaxLength(CoreGratitudeItem.MaxTextLength).IsRequired();
        builder.Property(item => item.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(item => item.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(item => item.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(item => new { item.DayId, item.Position }).IsUnique();
    }
}
