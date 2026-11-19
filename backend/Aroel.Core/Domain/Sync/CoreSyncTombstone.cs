using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Sync;

/// <summary>
/// The tombstone of a row the server deleted, kept so a device can be told about the
/// deletion (§7.3).
/// </summary>
/// <remarks>
/// Hard deletes travel as tombstones, not as silence: a row that vanished from a device's
/// copy without one would be resurrected by the next push. The tombstone carries the
/// cursor of its own write, so delta pulls see it like any other change.
/// </remarks>
public sealed class CoreSyncTombstone : SyncableEntity
{
    private CoreSyncTombstone()
    {
    }

    private CoreSyncTombstone(Guid id, Guid userId, string tableName, Guid rowId, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        TableName = tableName;
        RowId = rowId;
        DeletedAt = now;
    }

    /// <summary>Gets the user the tombstone belongs to.</summary>
    public Guid UserId { get; private set; }

    /// <summary>Gets the table the row was deleted from, e.g. `day_tags`.</summary>
    public string TableName { get; private set; } = string.Empty;

    /// <summary>Gets the identifier of the row that was deleted.</summary>
    public Guid RowId { get; private set; }

    /// <summary>Gets the moment the row disappeared, in UTC.</summary>
    public DateTimeOffset DeletedAt { get; private set; }

    /// <summary>
    /// Creates a tombstone.
    /// </summary>
    /// <param name="id">The identifier of the tombstone.</param>
    /// <param name="userId">The user the tombstone belongs to.</param>
    /// <param name="tableName">The table the row was deleted from.</param>
    /// <param name="rowId">The identifier of the row.</param>
    /// <param name="now">The moment of the deletion, in UTC.</param>
    /// <returns>The tombstone, or a failure when a field does not hold up.</returns>
    public static Result<CoreSyncTombstone> Create(Guid id, Guid userId, string tableName, Guid rowId, DateTimeOffset now)
    {
        return id == Guid.Empty
            ? Result.Failure<CoreSyncTombstone>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : tableName == string.Empty || rowId == Guid.Empty
                ? Result.Failure<CoreSyncTombstone>(new AppError(ErrorCodes.IdentifierEmpty, rowId.ToString()))
                : Result.Success(new CoreSyncTombstone(id, userId, tableName, rowId, now));
    }
}
