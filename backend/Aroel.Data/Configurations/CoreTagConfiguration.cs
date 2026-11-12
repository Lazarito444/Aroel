using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps a tag of the user's vocabulary onto the <c>tags</c> table.
/// </summary>
public sealed class CoreTagConfiguration : IEntityTypeConfiguration<CoreTag>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreTag> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("tags");
        builder.HasKey(tag => tag.Id);
        builder.Property(tag => tag.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(tag => tag.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(tag => tag.Label).HasColumnName("label").HasMaxLength(CoreTag.MaxLabelLength).IsRequired();
        builder.Property(tag => tag.Color).HasColumnName("color").HasMaxLength(7);
        builder.Property(tag => tag.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(tag => tag.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(tag => tag.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(tag => new { tag.UserId, tag.Label }).IsUnique();
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(tag => tag.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
