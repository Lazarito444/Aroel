using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps the tone of a day onto the <c>day_sentiment</c> table.
/// </summary>
public sealed class CoreDaySentimentConfiguration : IEntityTypeConfiguration<CoreDaySentiment>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreDaySentiment> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("day_sentiment");
        builder.HasKey(sentiment => sentiment.Id);
        builder.Property(sentiment => sentiment.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(sentiment => sentiment.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(sentiment => sentiment.DayId).HasColumnName("day_id").IsRequired();
        builder.Property(sentiment => sentiment.Rating).HasColumnName("rating_half");
        builder.Property(sentiment => sentiment.EmotionId).HasColumnName("emotion_id");
        builder.Property(sentiment => sentiment.Source).HasColumnName("source").HasConversion<string>().HasMaxLength(16).IsRequired();
        builder.Property(sentiment => sentiment.RecordedAt).HasColumnName("recorded_at").IsRequired();
        builder.Property(sentiment => sentiment.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(sentiment => sentiment.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.Property(sentiment => sentiment.SyncSequence).HasColumnName("sync_seq").HasDefaultValueSql("nextval('sync_seq'::regclass)").ValueGeneratedOnAdd();
        builder.HasIndex(sentiment => new { sentiment.UserId, sentiment.DayId }).IsUnique();
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(sentiment => sentiment.UserId).OnDelete(DeleteBehavior.Cascade);
        builder.HasOne<CoreEmotion>().WithMany().HasForeignKey(sentiment => sentiment.EmotionId).OnDelete(DeleteBehavior.SetNull);
    }
}
