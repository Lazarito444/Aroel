using Aroel.Core.Domain.Sync;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the tombstones of deleted rows onto the <c>sync_tombstones</c> table.
/// </summary>
public sealed class CoreSyncTombstoneConfiguration : IEntityTypeConfiguration<CoreSyncTombstone>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreSyncTombstone> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("sync_tombstones");
        builder.HasKey(tombstone => tombstone.Id);
        builder.Property(tombstone => tombstone.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(tombstone => tombstone.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(tombstone => tombstone.TableName).HasColumnName("table_name").HasMaxLength(64).IsRequired();
        builder.Property(tombstone => tombstone.RowId).HasColumnName("row_id").IsRequired();
        builder.Property(tombstone => tombstone.DeletedAt).HasColumnName("deleted_at").IsRequired();
        builder.Property(tombstone => tombstone.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(tombstone => tombstone.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(tombstone => tombstone.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(tombstone => new { tombstone.UserId, tombstone.SyncSequence });
        builder.HasIndex(tombstone => tombstone.RowId);
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(tombstone => tombstone.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
