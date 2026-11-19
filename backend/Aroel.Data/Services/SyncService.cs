using System.Text.Json.Nodes;
using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Sync;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Data.Services;

/// <summary>
/// The sync of devices (§7.3).
/// </summary>
/// <remarks>
/// <para>
/// Last-write-wins per row by <c>updated_at</c>: a row is written only when the device's
/// timestamp is newer than the server's; an older change is refused and the device is
/// handed the server's row so both converge. Hard deletes travel as tombstones, so a
/// deleted row never comes back through a stale push.
/// </para>
/// <para>
/// The client's <c>updated_at</c> is the whole truth of the ordering, so it is stored as
/// sent, never re-stamped by the server: re-stamping would let a fat-fingered device
/// silence a legitimately newer edit from another device. The monotonic cursor comes
/// from <c>sync_seq</c>, assigned here, never from a clock.
/// </para>
/// </remarks>
public sealed class SyncService
{
    private const int PullPageSize = 500;


    private readonly AroelDbContext _db;


    /// <summary>
    /// Initialises the service.
    /// </summary>
    /// <param name="db">The database of the host.</param>

    public SyncService(AroelDbContext db)
    {
        ArgumentNullException.ThrowIfNull(db);
        _db = db;
    }

    /// <summary>
    /// Applies a batch of operations from a device.
    /// </summary>
    /// <param name="userId">The user the device belongs to.</param>
    /// <param name="operations">The operations, in any order; parents are applied before their children.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The final state of every operation the server understood.</returns>
    public async Task<SyncBatchResult> PushAsync(Guid userId, IReadOnlyList<SyncOperationDto> operations, CancellationToken cancellationToken = default)
    {

        ArgumentNullException.ThrowIfNull(operations);

        // Parents first: a child row whose day is not on the server yet is refused, not dropped.
        IReadOnlyList<SyncOperationDto> ordered = [.. operations.OrderBy(operation => TableOrder(operation.Table))];

        List<SyncRowDto> rows = [];
        List<SyncOperationErrorDto> errors = [];

        // The in-memory provider does not support transactions; a database does.
        bool transactional = !string.Equals(_db.Database.ProviderName, "Microsoft.EntityFrameworkCore.InMemory", StringComparison.Ordinal);

        if (transactional)
        {
            await _db.Database.BeginTransactionAsync(cancellationToken).ConfigureAwait(false);
        }

        foreach (SyncOperationDto operation in ordered)
        {
            try
            {
                SyncRowDto? row = await ApplyAsync(_db, userId, operation, cancellationToken).ConfigureAwait(false);
                if (row is not null)
                {
                    rows.Add(row);
                }
            }
            catch (SyncOperationException exception)
            {
                errors.Add(new SyncOperationErrorDto(exception.Table, exception.Op, exception.Id, exception.Code));
            }
        }

        await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        if (transactional)
        {
            await _db.Database.CommitTransactionAsync(cancellationToken).ConfigureAwait(false);
        }

        long cursor = rows.Count == 0 ? 0 : rows.Max(row => row.SyncSeq);
        return new SyncBatchResult(cursor, rows, errors);
    }

    /// <summary>
    /// Reads the rows of a user changed since a cursor, oldest first.
    /// </summary>
    /// <param name="userId">The user the device belongs to.</param>
    /// <param name="since">The cursor the device last reached.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The page of changes and the cursor to ask from next time.</returns>
    public async Task<SyncPullPage> PullAsync(Guid userId, long since, CancellationToken cancellationToken = default)
    {


        List<SyncRowDto> rows = [];

        List<CoreDay> days = await _db.Set<CoreDay>()
            .Include(day => day.GratitudeItems)
            .Include(day => day.Tags)
            .Include(day => day.Sentiment)
            .Where(day => day.UserId == userId && day.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        foreach (CoreDay day in days)
        {
            rows.Add(RowOf("days", "upsert", day.Id, day.UpdatedAt, day.SyncSequence, DataOfDay(day)));
            foreach (CoreGratitudeItem item in day.GratitudeItems)
            {
                if (item.SyncSequence > since)
                {
                    rows.Add(RowOf("gratitude_items", "upsert", item.Id, item.UpdatedAt, item.SyncSequence, DataOfGratitudeItem(item)));
                }
            }

            foreach (CoreDayTag tag in day.Tags)
            {
                if (tag.SyncSequence > since)
                {
                    rows.Add(RowOf("day_tags", "upsert", tag.Id, tag.UpdatedAt, tag.SyncSequence, DataOfDayTag(tag)));
                }
            }
        }

        List<CoreTag> tags = await _db.Set<CoreTag>()
            .Where(tag => tag.UserId == userId && tag.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreTag tag in tags)
        {
            rows.Add(RowOf("tags", "upsert", tag.Id, tag.UpdatedAt, tag.SyncSequence, DataOfTag(tag)));
        }

        List<CoreEntry> entries = await _db.Set<CoreEntry>()
            .Where(entry => entry.UserId == userId && entry.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreEntry entry in entries)
        {
            rows.Add(RowOf("entries", "upsert", entry.Id, entry.UpdatedAt, entry.SyncSequence, DataOfEntry(entry)));
        }

        List<CoreNote> notes = await _db.Set<CoreNote>()
            .Where(note => note.UserId == userId && note.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreNote note in notes)
        {
            rows.Add(RowOf("notes", "upsert", note.Id, note.UpdatedAt, note.SyncSequence, DataOfNote(note)));
        }

        List<CoreDaySentiment> sentiments = await _db.Set<CoreDaySentiment>()
            .Where(sentiment => sentiment.UserId == userId && sentiment.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreDaySentiment sentiment in sentiments)
        {
            rows.Add(RowOf("day_sentiment", "upsert", sentiment.Id, sentiment.UpdatedAt, sentiment.SyncSequence, DataOfSentiment(sentiment)));
        }

        List<CoreSyncTombstone> tombstones = await _db.Set<CoreSyncTombstone>()
            .Where(tombstone => tombstone.UserId == userId && tombstone.SyncSequence > since)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreSyncTombstone tombstone in tombstones)
        {
            rows.Add(RowOf(tombstone.TableName, "delete", tombstone.RowId, tombstone.DeletedAt, tombstone.SyncSequence, null));
        }

        rows = [.. rows.OrderBy(row => row.SyncSeq)];
        bool hasMore = rows.Count > PullPageSize;
        if (hasMore)
        {
            rows = [.. rows.Take(PullPageSize)];
        }

        long cursor = rows.Count == 0 ? since : rows.Max(row => row.SyncSeq);
        return new SyncPullPage(cursor, hasMore, rows);
    }

    private static async Task<SyncRowDto?> ApplyAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, CancellationToken cancellationToken)
    {
        return operation.Op.Trim().ToLowerInvariant() switch
        {
            "upsert" => await UpsertAsync(db, userId, operation, cancellationToken).ConfigureAwait(false),
            "delete" => await TombstoneAsync(db, userId, operation, cancellationToken).ConfigureAwait(false),
            _ => throw new SyncOperationException(operation.Table, operation.Op, operation.Id, "sync.unknown_operation")
        };
    }

    private static async Task<SyncRowDto?> UpsertAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, CancellationToken cancellationToken)
    {
        JsonObject data = operation.Data ?? [];

        return operation.Table.Trim().ToLowerInvariant() switch
        {
            "days" => await UpsertDayAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "gratitude_items" => await UpsertGratitudeItemAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "tags" => await UpsertTagAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "day_tags" => await UpsertDayTagAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "entries" => await UpsertEntryAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "notes" => await UpsertNoteAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            "day_sentiment" => await UpsertSentimentAsync(db, userId, operation, data, cancellationToken).ConfigureAwait(false),
            _ => throw new SyncOperationException(operation.Table, operation.Op, operation.Id, "sync.unknown_table"),
        };
    }

    private static int TableOrder(string table)
    {
        return table.Trim().ToLowerInvariant() switch
        {
            "days" => 0,
            "tags" => 0,
            "entries" => 1,
            "notes" => 1,
            "day_sentiment" => 1,
            "gratitude_items" => 2,
            "day_tags" => 2,
            _ => 3
        };
    }

    private static async Task<SyncRowDto> UpsertDayAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreDay? existing = await db.Set<CoreDay>()
            .FirstOrDefaultAsync(day => day.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("days", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfDay(existing));
        }

        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;
        string localDate = GetString(data, "localDate") ?? throw new SyncOperationException("days", operation.Op, operation.Id, "sync.local_date_missing");
        string[] dateParts = localDate.Split('-');
        LocalDate day = LocalDate.From(int.Parse(dateParts[0], System.Globalization.CultureInfo.InvariantCulture), int.Parse(dateParts[1], System.Globalization.CultureInfo.InvariantCulture), int.Parse(dateParts[2], System.Globalization.CultureInfo.InvariantCulture));
        int? ratingHalf = GetInt(data, "ratingHalf");
        string? note = GetNullableString(data, "note");
        DateTimeOffset? ratedAt = GetNullableInstant(data, "ratedAt");

        if (existing is null)
        {
            CoreDay created = CoreDay.Create(operation.Id, userId, day, createdAt).Value ??
                throw new SyncOperationException("days", operation.Op, operation.Id, "identifier.empty");
            if (ratingHalf is not null)
            {
                _ = created.SetRating(RatingHalf.From(ratingHalf.Value).Value, operation.UpdatedAt);
            }

            _ = created.SetNote(note, operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreDay>().Add(created);
            return RowOf("days", "upsert", created.Id, createdAt, created.SyncSequence, DataOfDay(created));
        }

        ApplyProperty(db.Entry(existing), "Rating", ratingHalf is null ? (RatingHalf?)null : RatingHalf.From(ratingHalf.Value).Value);
        ApplyProperty(db.Entry(existing), "RatedAt", ratingHalf is null ? null : ratedAt ?? operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "Note", note);
        ApplyProperty(db.Entry(existing), "UpdatedAt", operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("days", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfDay(existing));
    }

    private static async Task<SyncRowDto> UpsertTagAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreTag? existing = await db.Set<CoreTag>()
            .FirstOrDefaultAsync(tag => tag.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("tags", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfTag(existing));
        }

        string label = GetString(data, "label") ?? throw new SyncOperationException("tags", operation.Op, operation.Id, "sync.label_missing");
        string? color = GetNullableString(data, "color");
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;

        if (existing is null)
        {
            CoreTag created = CoreTag.Create(operation.Id, userId, label, color, createdAt).Value ??
                throw new SyncOperationException("tags", operation.Op, operation.Id, "identifier.empty");
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreTag>().Add(created);
            return RowOf("tags", "upsert", created.Id, createdAt, created.SyncSequence, DataOfTag(created));
        }

        _ = existing.Rename(label, operation.UpdatedAt);
        _ = existing.Recolor(color, operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("tags", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfTag(existing));
    }

    private static async Task<SyncRowDto> UpsertNoteAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreNote? existing = await db.Set<CoreNote>()
            .FirstOrDefaultAsync(note => note.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("notes", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfNote(existing));
        }

        string body = GetString(data, "bodyMd") ?? string.Empty;
        string? title = GetNullableString(data, "title");
        bool pinned = GetBool(data, "pinned") ?? false;
        DateTimeOffset? deletedAt = GetNullableInstant(data, "deletedAt");
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;

        if (existing is null)
        {
            CoreNote created = CoreNote.Create(operation.Id, userId, title, body, createdAt).Value ??
                throw new SyncOperationException("notes", operation.Op, operation.Id, "identifier.empty");
            if (pinned)
            {
                _ = created.Pin(createdAt);
            }

            if (deletedAt is not null)
            {
                _ = created.SoftDelete(deletedAt.Value);
            }

            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreNote>().Add(created);
            return RowOf("notes", "upsert", created.Id, createdAt, created.SyncSequence, DataOfNote(created));
        }

        _ = existing.Edit(title, body, operation.UpdatedAt);
        if (pinned != existing.Pinned)
        {
            _ = pinned ? existing.Pin(operation.UpdatedAt) : existing.Unpin(operation.UpdatedAt);
        }

        if (deletedAt is not null && existing.DeletedAt is null)
        {
            _ = existing.SoftDelete(deletedAt.Value);
        }
        else if (deletedAt is null && existing.DeletedAt is not null)
        {
            _ = existing.Restore(operation.UpdatedAt);
        }

        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("notes", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfNote(existing));
    }

    private static async Task<SyncRowDto> UpsertEntryAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreEntry? existing = await db.Set<CoreEntry>()
            .FirstOrDefaultAsync(entry => entry.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("entries", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfEntry(existing));
        }

        Guid dayId = GetGuid(data, "dayId") ?? throw new SyncOperationException("entries", operation.Op, operation.Id, "sync.day_missing");
        await RequireOwnDayAsync(db, userId, dayId, cancellationToken).ConfigureAwait(false);

        EntryKind kind = string.Equals(GetNullableString(data, "kind"), "mood_only", StringComparison.OrdinalIgnoreCase)
            ? EntryKind.MoodOnly
            : EntryKind.Free;
        string body = GetString(data, "bodyMd") ?? string.Empty;
        string? title = GetNullableString(data, "title");
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;
        DateTimeOffset? lastOpenedAt = GetNullableInstant(data, "lastOpenedAt");
        bool pinned = GetBool(data, "pinned") ?? false;
        DateTimeOffset? deletedAt = GetNullableInstant(data, "deletedAt");

        if (existing is null)
        {
            CoreEntry created = CoreEntry.Create(operation.Id, userId, dayId, kind, title, body, createdAt).Value ??
                throw new SyncOperationException("entries", operation.Op, operation.Id, "identifier.empty");
            if (pinned)
            {
                _ = created.Pin(createdAt);
            }

            if (deletedAt is not null)
            {
                _ = created.SoftDelete(deletedAt.Value);
            }

            ApplyProperty(db.Entry(created), "LastOpenedAt", lastOpenedAt);
            ApplyProperty(db.Entry(created), "OpenedCount", GetInt(data, "openedCount") ?? 0);
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreEntry>().Add(created);
            return RowOf("entries", "upsert", created.Id, createdAt, created.SyncSequence, DataOfEntry(created));
        }

        _ = existing.Edit(title, body, operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "DayId", dayId);
        ApplyProperty(db.Entry(existing), "Kind", kind);
        ApplyProperty(db.Entry(existing), "WordCount", Core.Domain.Text.WordCounter.Count(body));
        ApplyProperty(db.Entry(existing), "LastOpenedAt", lastOpenedAt);
        ApplyProperty(db.Entry(existing), "OpenedCount", GetInt(data, "openedCount") ?? existing.OpenedCount);
        if (pinned != existing.Pinned)
        {
            _ = pinned ? existing.Pin(operation.UpdatedAt) : existing.Unpin(operation.UpdatedAt);
        }

        if (deletedAt is not null && existing.DeletedAt is null)
        {
            _ = existing.SoftDelete(deletedAt.Value);
        }
        else if (deletedAt is null && existing.DeletedAt is not null)
        {
            _ = existing.Restore(operation.UpdatedAt);
        }

        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("entries", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfEntry(existing));
    }

    private static async Task<SyncRowDto> UpsertGratitudeItemAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreGratitudeItem? existing = await db.Set<CoreGratitudeItem>()
            .FirstOrDefaultAsync(item => item.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("gratitude_items", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfGratitudeItem(existing));
        }

        Guid dayId = GetGuid(data, "dayId") ?? throw new SyncOperationException("gratitude_items", operation.Op, operation.Id, "sync.day_missing");
        await RequireOwnDayAsync(db, userId, dayId, cancellationToken).ConfigureAwait(false);
        int position = GetInt(data, "position") ?? throw new SyncOperationException("gratitude_items", operation.Op, operation.Id, "sync.position_missing");
        string text = GetString(data, "text") ?? string.Empty;
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;

        if (existing is null)
        {
            CoreGratitudeItem created = CoreGratitudeItem.Create(operation.Id, dayId, position, text, createdAt).Value ??
                throw new SyncOperationException("gratitude_items", operation.Op, operation.Id, "identifier.empty");
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreGratitudeItem>().Add(created);
            return RowOf("gratitude_items", "upsert", created.Id, createdAt, created.SyncSequence, DataOfGratitudeItem(created));
        }

        _ = existing.SetText(text, operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "DayId", dayId);
        ApplyProperty(db.Entry(existing), "Position", position);
        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("gratitude_items", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfGratitudeItem(existing));
    }

    private static async Task<SyncRowDto> UpsertDayTagAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreDayTag? existing = await db.Set<CoreDayTag>()
            .FirstOrDefaultAsync(tag => tag.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("day_tags", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfDayTag(existing));
        }

        Guid dayId = GetGuid(data, "dayId") ?? throw new SyncOperationException("day_tags", operation.Op, operation.Id, "sync.day_missing");
        Guid tagId = GetGuid(data, "tagId") ?? throw new SyncOperationException("day_tags", operation.Op, operation.Id, "sync.tag_missing");
        await RequireOwnDayAsync(db, userId, dayId, cancellationToken).ConfigureAwait(false);
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;

        if (existing is null)
        {
            CoreDayTag created = CoreDayTag.Create(operation.Id, dayId, tagId, createdAt).Value ??
                throw new SyncOperationException("day_tags", operation.Op, operation.Id, "identifier.empty");
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreDayTag>().Add(created);
            return RowOf("day_tags", "upsert", created.Id, createdAt, created.SyncSequence, DataOfDayTag(created));
        }

        ApplyProperty(db.Entry(existing), "DayId", dayId);
        ApplyProperty(db.Entry(existing), "TagId", tagId);
        ApplyProperty(db.Entry(existing), "UpdatedAt", operation.UpdatedAt);
        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("day_tags", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfDayTag(existing));
    }

    private static async Task<SyncRowDto> UpsertSentimentAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, JsonObject data, CancellationToken cancellationToken)
    {
        CoreDaySentiment? existing = await db.Set<CoreDaySentiment>()
            .FirstOrDefaultAsync(sentiment => sentiment.Id == operation.Id, cancellationToken)
            .ConfigureAwait(false);

        if (existing is not null && operation.UpdatedAt <= existing.UpdatedAt)
        {
            return RowOf("day_sentiment", "upsert", existing.Id, existing.UpdatedAt, existing.SyncSequence, DataOfSentiment(existing));
        }

        Guid dayId = GetGuid(data, "dayId") ?? throw new SyncOperationException("day_sentiment", operation.Op, operation.Id, "sync.day_missing");
        await RequireOwnDayAsync(db, userId, dayId, cancellationToken).ConfigureAwait(false);
        int? tone = GetInt(data, "ratingHalf");
        Guid? emotionId = GetGuid(data, "emotionId");
        SentimentSource source = string.Equals(GetNullableString(data, "source"), "on_device", StringComparison.OrdinalIgnoreCase)
            ? SentimentSource.OnDevice
            : SentimentSource.Manual;
        DateTimeOffset recordedAt = GetInstant(data, "recordedAt") ?? operation.UpdatedAt;
        DateTimeOffset createdAt = GetInstant(data, "createdAt") ?? operation.UpdatedAt;

        if (existing is null)
        {
            CoreDaySentiment created = CoreDaySentiment.Create(operation.Id, userId, dayId, source, recordedAt).Value ??
                throw new SyncOperationException("day_sentiment", operation.Op, operation.Id, "identifier.empty");
            _ = created.SetTone(tone is null ? null : RatingHalf.From(tone.Value).Value, emotionId, recordedAt);
            ApplyProperty(db.Entry(created), "UpdatedAt", operation.UpdatedAt);
            ApplyProperty(db.Entry(created), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
            db.Set<CoreDaySentiment>().Add(created);
            return RowOf("day_sentiment", "upsert", created.Id, createdAt, created.SyncSequence, DataOfSentiment(created));
        }

        _ = existing.SetTone(tone is null ? null : RatingHalf.From(tone.Value).Value, emotionId, recordedAt);
        ApplyProperty(db.Entry(existing), "RecordedAt", recordedAt);
        ApplyProperty(db.Entry(existing), "Source", source);
        ApplyProperty(db.Entry(existing), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));

        return RowOf("day_sentiment", "upsert", existing.Id, operation.UpdatedAt, existing.SyncSequence, DataOfSentiment(existing));
    }

    private static async Task<SyncRowDto> TombstoneAsync(AroelDbContext db, Guid userId, SyncOperationDto operation, CancellationToken cancellationToken)
    {
        string table = operation.Table.Trim().ToLowerInvariant();

        switch (table)
        {
            case "entries":
                await SoftDeleteAsync(db, operation,
                    (db, id) => db.Set<CoreEntry>().FirstOrDefaultAsync(row => row.Id == id && row.UserId == userId, cancellationToken: cancellationToken),
                    (row, now) => row.SoftDelete(now), cancellationToken).ConfigureAwait(false);
                break;
            case "notes":
                await SoftDeleteAsync(db, operation,
                    (db, id) => db.Set<CoreNote>().FirstOrDefaultAsync(row => row.Id == id && row.UserId == userId, cancellationToken: cancellationToken),
                    (row, now) => row.SoftDelete(now), cancellationToken).ConfigureAwait(false);
                break;
            case "gratitude_items":
                await HardDeleteOwnedAsync<CoreGratitudeItem>(db, userId, operation, cancellationToken).ConfigureAwait(false);
                break;
            case "day_tags":
                await HardDeleteOwnedAsync<CoreDayTag>(db, userId, operation, cancellationToken).ConfigureAwait(false);
                break;
            case "tags":
                await db.Set<CoreTag>().Where(tag => tag.Id == operation.Id && tag.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
                break;
            default:
                throw new SyncOperationException(operation.Table, operation.Op, operation.Id, "sync.delete_unsupported");
        }

        CoreSyncTombstone tombstone = CoreSyncTombstone.Create(Guid.CreateVersion7(), userId, table, operation.Id, operation.UpdatedAt).Value;
        ApplyProperty(db.Entry(tombstone), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
        db.Set<CoreSyncTombstone>().Add(tombstone);

        return RowOf(table, "delete", operation.Id, operation.UpdatedAt, tombstone.SyncSequence, null);
    }

    private static async Task SoftDeleteAsync<T>(
        AroelDbContext db,
        SyncOperationDto operation,
        Func<AroelDbContext, Guid, Task<T?>> find,
        Func<T, DateTimeOffset, Result<T>> softDelete,
        CancellationToken cancellationToken)
        where T : class
    {
        T? row = await find(db, operation.Id).ConfigureAwait(false);
        if (row is null)
        {
            return;
        }

        _ = softDelete(row, operation.UpdatedAt);
        ApplyProperty(db.Entry(row), "SyncSequence", await SyncCursor.NextAsync(db, cancellationToken).ConfigureAwait(false));
    }

    private static async Task HardDeleteOwnedAsync<T>(AroelDbContext db, Guid userId, SyncOperationDto operation, CancellationToken cancellationToken)
        where T : class
    {
        // Ownership comes from the parent day; children carry no user id of their own.
        if (typeof(T) == typeof(CoreGratitudeItem))
        {
            CoreGratitudeItem? item = await db.Set<CoreGratitudeItem>().FirstOrDefaultAsync(row => row.Id == operation.Id, cancellationToken).ConfigureAwait(false);
            if (item is null)
            {
                return;
            }

            await RequireOwnDayAsync(db, userId, item.DayId, cancellationToken).ConfigureAwait(false);
            db.Set<CoreGratitudeItem>().Remove(item);
            return;
        }

        if (typeof(T) == typeof(CoreDayTag))
        {
            CoreDayTag? link = await db.Set<CoreDayTag>().FirstOrDefaultAsync(row => row.Id == operation.Id, cancellationToken).ConfigureAwait(false);
            if (link is null)
            {
                return;
            }

            await RequireOwnDayAsync(db, userId, link.DayId, cancellationToken).ConfigureAwait(false);
            db.Set<CoreDayTag>().Remove(link);
        }
    }

    private static async Task RequireOwnDayAsync(AroelDbContext db, Guid userId, Guid dayId, CancellationToken cancellationToken)
    {
        Guid? owner = await db.Set<CoreDay>()
            .Where(day => day.Id == dayId)
            .Select(day => (Guid?)day.UserId)
            .FirstOrDefaultAsync(cancellationToken)
            .ConfigureAwait(false) ?? throw new SyncOperationException("sync", "upsert", dayId, "sync.day_missing");

        if (owner.Value != userId)
        {
            throw new SyncOperationException("sync", "upsert", dayId, "sync.day_not_yours");
        }
    }


    private static void ApplyProperty(Microsoft.EntityFrameworkCore.ChangeTracking.EntityEntry entry, string name, object? value)
    {
        entry.Property(name).CurrentValue = value;
        entry.Property(name).IsModified = true;

        // EF's own snapshot does not touch the CLR object, and sync rows carry values
        // out of the CLR; write through the private setters as well.
        if (!TrySetClrProperty(entry.Entity.GetType(), entry.Entity, name, value))
        {
            throw new InvalidOperationException($"The entity {entry.Entity.GetType().Name} has no property '{name}' to write.");
        }
    }

    private static bool TrySetClrProperty(Type type, object entity, string name, object? value)
    {
        Type? current = type;
        while (current is not null)
        {
            System.Reflection.PropertyInfo? info = current.GetProperty(
                name,
                System.Reflection.BindingFlags.Instance |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.DeclaredOnly);

            if (info is not null && info.GetSetMethod(nonPublic: true) is not null)
            {
                info.GetSetMethod(nonPublic: true)!.Invoke(entity, [value]);
                return true;
            }

            current = current.BaseType;
        }

        return false;
    }

    private static SyncRowDto RowOf(string table, string op, Guid id, DateTimeOffset updatedAt, long syncSeq, JsonObject? data)
    {
        return new(table, op, id, updatedAt, syncSeq, data);
    }

    private static JsonObject DataOfDay(CoreDay day)
    {
        return new()
        {
            ["localDate"] = day.LocalDate.ToString(),
            ["ratingHalf"] = day.Rating?.HalfPoints,
            ["note"] = day.Note,
            ["ratedAt"] = day.RatedAt?.ToString("o"),
            ["createdAt"] = day.CreatedAt.ToString("o"),
            ["updatedAt"] = day.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfGratitudeItem(CoreGratitudeItem item)
    {
        return new()
        {
            ["dayId"] = item.DayId,
            ["position"] = item.Position,
            ["text"] = item.Text,
            ["createdAt"] = item.CreatedAt.ToString("o"),
            ["updatedAt"] = item.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfTag(CoreTag tag)
    {
        return new()
        {
            ["label"] = tag.Label,
            ["color"] = tag.Color,
            ["createdAt"] = tag.CreatedAt.ToString("o"),
            ["updatedAt"] = tag.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfDayTag(CoreDayTag tag)
    {
        return new()
        {
            ["dayId"] = tag.DayId,
            ["tagId"] = tag.TagId,
            ["createdAt"] = tag.CreatedAt.ToString("o"),
            ["updatedAt"] = tag.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfEntry(CoreEntry entry)
    {
        return new()
        {
            ["dayId"] = entry.DayId,
            ["kind"] = entry.Kind.ToString().ToLowerInvariant(),
            ["title"] = entry.Title,
            ["bodyMd"] = entry.BodyMarkdown,
            ["wordCount"] = entry.WordCount,
            ["openedCount"] = entry.OpenedCount,
            ["lastOpenedAt"] = entry.LastOpenedAt?.ToString("o"),
            ["pinned"] = entry.Pinned,
            ["deletedAt"] = entry.DeletedAt?.ToString("o"),
            ["createdAt"] = entry.CreatedAt.ToString("o"),
            ["updatedAt"] = entry.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfNote(CoreNote note)
    {
        return new()
        {
            ["title"] = note.Title,
            ["bodyMd"] = note.BodyMarkdown,
            ["wordCount"] = note.WordCount,
            ["pinned"] = note.Pinned,
            ["deletedAt"] = note.DeletedAt?.ToString("o"),
            ["createdAt"] = note.CreatedAt.ToString("o"),
            ["updatedAt"] = note.UpdatedAt.ToString("o")
        };
    }

    private static JsonObject DataOfSentiment(CoreDaySentiment sentiment)
    {
        return new()
        {
            ["dayId"] = sentiment.DayId,
            ["ratingHalf"] = sentiment.Rating?.HalfPoints,
            ["emotionId"] = sentiment.EmotionId?.ToString(),
            ["source"] = sentiment.Source == SentimentSource.OnDevice ? "on_device" : "manual",
            ["recordedAt"] = sentiment.RecordedAt.ToString("o"),
            ["updatedAt"] = sentiment.UpdatedAt.ToString("o")
        };
    }

    private static string? GetString(JsonObject data, string name)
    {
        return !data.TryGetPropertyValue(name, out JsonNode? node) || node is null
            ? null
            : node is JsonValue value && value.TryGetValue(out string? text) ? text : node.ToJsonString();
    }

    private static string? GetNullableString(JsonObject data, string name)
    {
        string? value = GetString(data, name);
        return string.IsNullOrWhiteSpace(value) ? null : value;
    }

    private static int? GetInt(JsonObject data, string name)
    {
        if (!data.TryGetPropertyValue(name, out JsonNode? node) || node is null)
        {
            return null;
        }

        if (node is JsonValue value)
        {
            if (value.TryGetValue(out int intValue))
            {
                return intValue;
            }

            if (value.TryGetValue(out long longValue))
            {
                return checked((int)longValue);
            }
        }

        return null;
    }

    private static bool? GetBool(JsonObject data, string name)
    {
        return !data.TryGetPropertyValue(name, out JsonNode? node) || node is null
            ? null
            : node is JsonValue value && value.TryGetValue(out bool boolValue) ? boolValue : null;
    }

    private static Guid? GetGuid(JsonObject data, string name)
    {
        string? text = GetString(data, name);
        return Guid.TryParse(text, out Guid id) ? id : null;
    }

    private static DateTimeOffset? GetInstant(JsonObject data, string name)
    {
        string? text = GetString(data, name);
        return DateTimeOffset.TryParse(text, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.AssumeUniversal, out DateTimeOffset instant)
            ? instant
            : null;
    }

    private static DateTimeOffset? GetNullableInstant(JsonObject data, string name)
    {
        return GetInstant(data, name);
    }

    private sealed class SyncOperationException : Exception
    {
        public SyncOperationException(string table, string op, Guid id, string code)
            : base($"{code} at {table}/{op}/{id}")
        {
            Table = table;
            Op = op;
            Id = id;
            Code = code;
        }

        public string Table { get; }

        public string Op { get; }

        public Guid Id { get; }

        public string Code { get; }
    }
}
