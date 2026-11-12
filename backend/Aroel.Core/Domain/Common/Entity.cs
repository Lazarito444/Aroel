
namespace Aroel.Core.Domain.Common;

/// <summary>
/// The shared shape of every domain entity: a client-generated identifier and the moments
/// it was created and last changed.
/// </summary>
/// <remarks>
/// State changes only through the behaviour the entity exposes, so the invariants the
/// domain cares about cannot be broken from the outside. The parameterless constructor
/// exists for the persistence layer to materialise rows; it is not a way to build a
/// half-initialised entity.
/// </remarks>
public abstract class Entity
{
    /// <summary>
    /// Initialises an empty entity for the persistence layer to materialise.
    /// </summary>
    private protected Entity()
    {
    }

    /// <summary>
    /// Initialises an entity with its identifier and the moment it came into being.
    /// </summary>
    /// <param name="id">The client-generated identifier.</param>
    /// <param name="now">The moment the entity was created, in UTC.</param>
    private protected Entity(Guid id, DateTimeOffset now)
    {
        Id = id;
        CreatedAt = now;
        UpdatedAt = now;
    }

    /// <summary>
    /// Gets the identifier of the entity.
    /// </summary>
    public Guid Id { get; private set; }

    /// <summary>
    /// Gets the moment the entity was created, in UTC.
    /// </summary>
    public DateTimeOffset CreatedAt { get; private set; }

    /// <summary>
    /// Gets the moment the entity last changed, in UTC.
    /// </summary>
    public DateTimeOffset UpdatedAt { get; private set; }

    /// <summary>
    /// Records that the entity changed at the given moment.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    private protected void Touch(DateTimeOffset now)
    {
        UpdatedAt = now;
    }
}
