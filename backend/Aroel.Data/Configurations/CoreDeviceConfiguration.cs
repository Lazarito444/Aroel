using Aroel.Core.Domain.Users;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aroel.Data.Configurations;

/// <summary>
/// Maps a device onto the <c>devices</c> table.
/// </summary>
public sealed class CoreDeviceConfiguration : IEntityTypeConfiguration<CoreDevice>
{
    /// <summary>
    /// Maps the entity.
    /// </summary>
    /// <param name="builder">The builder of the entity type.</param>
    public void Configure(EntityTypeBuilder<CoreDevice> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("devices");
        builder.HasKey(device => device.Id);
        builder.Property(device => device.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(device => device.UserId).HasColumnName("user_id").IsRequired();
        builder.Property(device => device.Platform).HasColumnName("platform").HasConversion<string>().HasMaxLength(16).IsRequired();
        builder.Property(device => device.PushToken).HasColumnName("push_token").HasMaxLength(512);
        builder.Property(device => device.AppVersion).HasColumnName("app_version").HasMaxLength(CoreDevice.MaxAppVersionLength).IsRequired();
        builder.Property(device => device.LastSeenAt).HasColumnName("last_seen_at").IsRequired();
        builder.Property(device => device.CreatedAt).HasColumnName("created_at").IsRequired();
        builder.Property(device => device.UpdatedAt).HasColumnName("updated_at").IsRequired();
        builder.HasIndex(device => device.UserId);
        builder.HasOne<CoreUser>().WithMany().HasForeignKey(device => device.UserId).OnDelete(DeleteBehavior.Cascade);
    }
}
