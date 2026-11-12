
namespace Aroel.Core.Domain.Common;

/// <summary>
/// An entity the client owns and the server syncs back, carrying the monotonic cursor
/// that drives delta sync.
/// </summary>
/// <remarks>
/// The cursor is assigned by the server, never by the client: it must advance in one
/// order for every device of one account, which a client clock cannot promise.
/// </remarks>
public abstract class SyncableEntity : Entity
{
    /// <summary>
    /// Initialises an empty entity for the persistence layer to materialise.
    /// </summary>
    private protected SyncableEntity()
    {
    }

    /// <summary>
    /// Initialises an entity with its identifier and the moment it came into being.
    /// </summary>
    /// <param name="id">The client-generated identifier.</param>
    /// <param name="now">The moment the entity was created, in UTC.</param>
    private protected SyncableEntity(Guid id, DateTimeOffset now)
        : base(id, now)
    {
    }

    /// <summary>
    /// Gets the server-assigned cursor this row was written at.
    /// </summary>
    public long SyncSequence { get; private set; }
}
