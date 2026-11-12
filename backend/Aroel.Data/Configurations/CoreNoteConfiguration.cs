using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps a note onto the <c>notes</c> table.
/// </summary>
public sealed class CoreNoteConfiguration : IEntityTypeConfiguration<CoreNote>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreNote> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("notes");
        builder.HasKey(note => note.Id);
        builder.Property(note => note.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(note => note.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(note => note.Title).HasColumnName("title").HasMaxLength(CoreNote.MaxTitleLength);
        builder.Property(note => note.BodyMarkdown).HasColumnName("body_md").IsRequired();
        builder.Property(note => note.WordCount).HasColumnName("word_count").IsRequired();
        builder.Property(note => note.Pinned).HasColumnName("pinned").IsRequired();
        builder.Property(note => note.DeletedAt).HasColumnName("deleted_at");
        builder.Property(note => note.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(note => note.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(note => note.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(note => new { note.UserId, note.CreatedAt });
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(note => note.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
