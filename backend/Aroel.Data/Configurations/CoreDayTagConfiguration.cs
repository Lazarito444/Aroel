using Aroel.Core.Domain.Journal;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the link between a day and a tag onto the <c>day_tags</c> table.
/// </summary>
public sealed class CoreDayTagConfiguration : IEntityTypeConfiguration<CoreDayTag>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreDayTag> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("day_tags");
        builder.HasKey(tag => tag.Id);
        builder.Property(tag => tag.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(tag => tag.DayId).HasColumnName("day_id").IsRequired();
        builder.Property(tag => tag.TagId).HasColumnName("tag_id").IsRequired();
        builder.Property(tag => tag.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(tag => tag.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(tag => tag.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(tag => new { tag.DayId, tag.TagId }).IsUnique();
        builder.HasOne<CoreTag>().WithMany().HasForeignKey(tag => tag.TagId).OnDelete(DeleteBehavior.Cascade);
    }
}
