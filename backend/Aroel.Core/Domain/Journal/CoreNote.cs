using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Text;
using Aroel.Core.EntityContracts;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Journal;

/// <summary>
/// A note with no date.
/// </summary>
/// <remarks>
/// A note is for the things that have no date, so it sits outside the spine of days: it
/// never touches the streak and never appears in the analytics of a day. It is the shelf,
/// not the record.
/// </remarks>
public sealed class CoreNote : SyncableEntity, ISoftDeletable
{
    /// <summary>
    /// The longest title the domain accepts.
    /// </summary>
    public const int MaxTitleLength = 200;

    private CoreNote()
    {
    }

    private CoreNote(Guid id, Guid userId, string? title, string bodyMarkdown, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        Title = title;
        BodyMarkdown = bodyMarkdown;
        WordCount = WordCounter.Count(bodyMarkdown);
    }

    /// <summary>
    /// Gets the user the note belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the title of the note, when it has one.
    /// </summary>
    public string? Title { get; private set; }

    /// <summary>
    /// Gets the body of the note, in markdown-lite.
    /// </summary>
    public string BodyMarkdown { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the number of words in the body.
    /// </summary>
    public int WordCount { get; private set; }

    /// <summary>
    /// Gets a value indicating whether the note is pinned to the top.
    /// </summary>
    public bool Pinned { get; private set; }

    /// <summary>
    /// Gets the moment the note was deleted, in UTC; <see langword="null"/> while it stands.
    /// </summary>
    public DateTimeOffset? DeletedAt { get; private set; }

    /// <summary>
    /// Creates a note.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the note belongs to.</param>
    /// <param name="title">The title of the note, when it has one.</param>
    /// <param name="bodyMarkdown">The body of the note, in markdown-lite.</param>
    /// <param name="now">The moment the note was created, in UTC.</param>
    /// <returns>The note, or a failure when a field does not hold up.</returns>
    public static Result<CoreNote> Create(Guid id, Guid userId, string? title, string bodyMarkdown, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(bodyMarkdown);

        return id == Guid.Empty
            ? Result.Failure<CoreNote>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateTitle(title).Map(validTitle =>
                new CoreNote(id, userId, validTitle, bodyMarkdown, now));
    }

    /// <summary>
    /// Changes the title and the body of the note.
    /// </summary>
    /// <param name="title">The new title, when it has one.</param>
    /// <param name="bodyMarkdown">The new body, in markdown-lite.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The note, or a failure when the title does not hold up.</returns>
    public Result<CoreNote> Edit(string? title, string bodyMarkdown, DateTimeOffset now)
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
    /// Pins the note to the top.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The note.</returns>
    public Result<CoreNote> Pin(DateTimeOffset now)
    {
        Pinned = true;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Takes the note off the top.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The note.</returns>
    public Result<CoreNote> Unpin(DateTimeOffset now)
    {
        Pinned = false;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Deletes the note softly, so that it can be recovered for thirty days.
    /// </summary>
    /// <param name="now">The moment of the deletion, in UTC.</param>
    /// <returns>The note.</returns>
    public Result<CoreNote> SoftDelete(DateTimeOffset now)
    {
        if (DeletedAt is null)
        {
            DeletedAt = now;
            Touch(now);
        }

        return Result.Success(this);
    }

    /// <summary>
    /// Brings a softly deleted note back.
    /// </summary>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The note.</returns>
    public Result<CoreNote> Restore(DateTimeOffset now)
    {
        if (DeletedAt is not null)
        {
            DeletedAt = null;
            Touch(now);
        }

        return Result.Success(this);
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
