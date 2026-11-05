namespace Aroel.Core.EntityContracts;

/// <summary>
/// Marks an aggregate whose rows are soft-deleted: writes <see cref="DeletedAt"/> with the
/// time of deletion instead of removing the row. Queries must treat an item with a value in
/// <see cref="DeletedAt"/> as absent, so repositories and specifications over soft-deletable
/// aggregates filter on it by default.
/// </summary>
public interface ISoftDeletable
{
    /// <summary>
    /// Gets or sets the time of deletion, <see langword="null"/> while the item is alive.
    /// In UTC, like every timestamp in the schema; tombstones carry it through sync instead of
    /// a bare delete so devices converge via last-write-wins.
    /// </summary>
    DateTime? DeletedAt { get; set; }
}
