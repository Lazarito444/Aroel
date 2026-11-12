using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the writing of a day onto the <c>entries</c> table.
/// </summary>
public sealed class CoreEntryConfiguration : IEntityTypeConfiguration<CoreEntry>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreEntry> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("entries");
        builder.HasKey(entry => entry.Id);
        builder.Property(entry => entry.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(entry => entry.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(entry => entry.DayId).HasColumnName("day_id").IsRequired();
        builder.Property(entry => entry.Kind).HasColumnName("kind").HasConversion<string>().HasMaxLength(16).IsRequired();
        builder.Property(entry => entry.Title).HasColumnName("title").HasMaxLength(CoreEntry.MaxTitleLength);
        builder.Property(entry => entry.BodyMarkdown).HasColumnName("body_md").IsRequired();
        builder.Property(entry => entry.WordCount).HasColumnName("word_count").IsRequired();
        builder.Property(entry => entry.OpenedCount).HasColumnName("opened_count").IsRequired();
        builder.Property(entry => entry.LastOpenedAt).HasColumnName("last_opened_at");
        builder.Property(entry => entry.Pinned).HasColumnName("pinned").IsRequired();
        builder.Property(entry => entry.DeletedAt).HasColumnName("deleted_at");
        builder.Property(entry => entry.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(entry => entry.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(entry => entry.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(entry => new { entry.UserId, entry.CreatedAt });
        builder.HasIndex(entry => entry.DayId);
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(entry => entry.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.HasOne<CoreDay>().WithMany().HasForeignKey(entry => entry.DayId).OnDelete(DeleteBehavior.Cascade);
    }
}
