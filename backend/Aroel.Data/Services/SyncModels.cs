using System.Text.Json.Nodes;

namespace Aroel.Data.Services;

/// <summary>One sync operation, as a device sends it (§7.3).</summary>
/// <param name="Table">The table the operation applies to.</param>
/// <param name="Op">`upsert` or `delete`.</param>
/// <param name="Id">The client-generated identifier of the row.</param>
/// <param name="UpdatedAt">The moment the change was made on the device, in UTC.</param>
/// <param name="Data">The fields of the row, when the operation carries them.</param>
public sealed record SyncOperationDto(string Table, string Op, Guid Id, DateTimeOffset UpdatedAt, JsonObject? Data);

/// <summary>One row as the server answers with it.</summary>
/// <param name="Table">The table the row belongs to.</param>
/// <param name="Op">`upsert` for a live row, `delete` for a tombstone.</param>
/// <param name="Id">The identifier of the row.</param>
/// <param name="UpdatedAt">The moment the row last changed, in UTC.</param>
/// <param name="SyncSeq">The cursor of the row's write.</param>
/// <param name="Data">The fields of the row, when it is alive.</param>
public sealed record SyncRowDto(string Table, string Op, Guid Id, DateTimeOffset UpdatedAt, long SyncSeq, JsonObject? Data);

/// <summary>One operation the server could not apply.</summary>
/// <param name="Table">The table of the operation.</param>
/// <param name="Op">The operation.</param>
/// <param name="Id">The row's identifier.</param>
/// <param name="Code">The code the device can count or report.</param>
public sealed record SyncOperationErrorDto(string Table, string Op, Guid Id, string Code);

/// <summary>What one batch of sync answers with.</summary>
/// <param name="Cursor">The newest cursor the server has written, for the batch's rows.</param>
/// <param name="Rows">The final state of every operation the server understood.</param>
/// <param name="Errors">The operations the server refused, with reasons.</param>
public sealed record SyncBatchResult(long Cursor, IReadOnlyList<SyncRowDto> Rows, IReadOnlyList<SyncOperationErrorDto> Errors);

/// <summary>What one page of a delta pull answers with.</summary>
/// <param name="Cursor">The cursor to ask again from next time.</param>
/// <param name="HasMore">Whether another page is waiting.</param>
/// <param name="Rows">The rows changed since the cursor, oldest first.</param>
public sealed record SyncPullPage(long Cursor, bool HasMore, IReadOnlyList<SyncRowDto> Rows);
