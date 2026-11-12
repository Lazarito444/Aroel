using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Text;
using Aroel.Core.EntityContracts;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// A piece of writing that belongs to a day.
/// </summary>
/// <remarks>
/// The entry attaches to the day it was written on: an entry started at 23:57 belongs to
/// that evening. Deleting one is soft for thirty days, so that a mistaken tap is
/// recoverable, and the row carries a tombstone so the deletion travels to the other
/// devices of the account.
/// </remarks>
public sealed class CoreEntry : SyncableEntity, ISoftDeletable
{
    /// <summary>
    /// The longest title the domain accepts.
    /// </summary>
    public const int MaxTitleLength = 200;

    private CoreEntry()
    {
    }

    private CoreEntry(Guid id, Guid userId, Guid dayId, EntryKind kind, string? title, string bodyMarkdown, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        DayId = dayId;
        Kind = kind;
        Title = title;
        BodyMarkdown = bodyMarkdown;
        WordCount = WordCounter.Count(bodyMarkdown);
    }

    /// <summary>
    /// Gets the user the entry belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the day the entry belongs to.
    /// </summary>
    public Guid DayId { get; private set; }

    /// <summary>
    /// Gets what kind of writing the entry holds.
    /// </summary>
    public EntryKind Kind { get; private set; }

    /// <summary>
    /// Gets the title of the entry, when it has one.
    /// </summary>
    public string? Title { get; private set; }

    /// <summary>
    /// Gets the body of the entry, in markdown-lite.
    /// </summary>
    public string BodyMarkdown { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the number of words in the body.
    /// </summary>
    public int WordCount { get; private set; }

    /// <summary>
    /// Gets how many times the entry was opened.
    /// </summary>
    public int OpenedCount { get; private set; }

    /// <summary>
    /// Gets the moment the entry was last opened, in UTC, when it was opened.
    /// </summary>
    public DateTimeOffset? LastOpenedAt { get; private set; }

    /// <summary>
    /// Gets a value indicating whether the entry is pinned to the top.
    /// </summary>
    public bool Pinned { get; private set; }

    /// <summary>
    /// Gets the moment the entry was deleted, in UTC; <see langword="null"/> while it stands.
    /// </summary>
    public DateTimeOffset? DeletedAt { get; private set; }

    /// <summary>
    /// Creates an entry.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the entry belongs to.</param>
    /// <param name="dayId">The day the entry belongs to.</param>
    /// <param name="kind">What kind of writing the entry holds.</param>
    /// <param name="title">The title of the entry, when it has one.</param>
    /// <param name="bodyMarkdown">The body of the entry, in markdown-lite.</param>
    /// <param name="now">The moment the entry was created, in UTC.</param>
    /// <returns>The entry, or a failure when a field does not hold up.</returns>
    public static Result<CoreEntry> Create(Guid id, Guid userId, Guid dayId, EntryKind kind, string? title, string bodyMarkdown, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(bodyMarkdown);

        return id == Guid.Empty
            ? Result.Failure<CoreEntry>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateKind(kind).Bind(validKind =>
                ValidateTitle(title).Map(validTitle =>
                    new CoreEntry(id, userId, dayId, validKind, validTitle, bodyMarkdown, now)));
    }

    /// <summary>
    /// Changes the title and the body of the entry.
    /// </summary>
    /// <param name="title">The new title, when it has one.</param>
    /// <param name="bodyMarkdown">The new body, in markdown-lite.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The entry, or a failure when the title does not hold up.</returns>
    public Result<CoreEntry> Edit(string? title, string bodyMarkdown, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(bodyMarkdown);

        return ValidateTitle(title).Map(validTitle =>
        {
            Title = validTitle;
            BodyMarkdown = bodyMarkdown;
            WordCount = WordCounter.Count(bodyMarkdown);
            Touch(now);
            return this;
        });
    }

    /// <summary>
    /// Pins the entry to the top.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The entry.</returns>
    public Result<CoreEntry> Pin(DateTimeOffset now)
    {
        Pinned = true;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Takes the entry off the top.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The entry.</returns>
    public Result<CoreEntry> Unpin(DateTimeOffset now)
    {
        Pinned = false;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Records that the entry was opened.
    /// </summary>
    /// <param name="now">The moment of the opening, in UTC.</param>
    /// <returns>The entry.</returns>
    public Result<CoreEntry> MarkOpened(DateTimeOffset now)
    {
        OpenedCount++;
        LastOpenedAt = now;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Deletes the entry softly, so that it can be recovered for thirty days.
    /// </summary>
    /// <param name="now">The moment of the deletion, in UTC.</param>
    /// <returns>The entry.</returns>
    public Result<CoreEntry> SoftDelete(DateTimeOffset now)
    {
        if (DeletedAt is null)
        {
            DeletedAt = now;
            Touch(now);
        }

        return Result.Success(this);
    }

    /// <summary>
    /// Brings a softly deleted entry back.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The entry.</returns>
    public Result<CoreEntry> Restore(DateTimeOffset now)
    {
        if (DeletedAt is not null)
        {
            DeletedAt = null;
            Touch(now);
        }

        return Result.Success(this);
    }

    private static Result<EntryKind> ValidateKind(EntryKind kind)
    {
        return Enum.IsDefined(kind)
            ? Result.Success(kind)
            : Result.Failure<EntryKind>(new AppError(ErrorCodes.EntryKindInvalid, kind));
    }

    private static Result<string?> ValidateTitle(string? title)
    {
        if (string.IsNullOrWhiteSpace(title))
        {
            return Result.Success<string?>(null);
        }

        string trimmed = title.Trim();

        return trimmed.Length > MaxTitleLength
            ? Result.Failure<string?>(new AppError(ErrorCodes.EntryTitleTooLong, MaxTitleLength))
            : Result.Success<string?>(trimmed);
    }
}
