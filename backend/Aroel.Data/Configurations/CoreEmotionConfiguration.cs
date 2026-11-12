using Aroel.Core.Domain.Journal;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps an emotion of the taxonomy onto the <c>emotions</c> table.
/// </summary>
public sealed class CoreEmotionConfiguration : IEntityTypeConfiguration<CoreEmotion>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreEmotion> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("emotions");
        builder.HasKey(emotion => emotion.Id);
        builder.Property(emotion => emotion.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(emotion => emotion.Slug).HasColumnName("slug").HasMaxLength(CoreEmotion.MaxSlugLength).IsRequired();
        builder.Property(emotion => emotion.Label).HasColumnName("label").HasMaxLength(CoreEmotion.MaxLabelLength).IsRequired();
        builder.Property(emotion => emotion.Family).HasColumnName("family").HasConversion<string>().HasMaxLength(16).IsRequired();
        builder.Property(emotion => emotion.ValenceBias).HasColumnName("valence_bias").HasPrecision(3, 2).IsRequired();
        builder.Property(emotion => emotion.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(emotion => emotion.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.HasIndex(emotion => emotion.Slug).IsUnique();
    }
}
