using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Aroel.Core.Results;

namespace Aroel.Core.Tests.Domain;

public class CoreUserAndWritingTests
{
    [Fact]
    public void Create_TrimsTheDisplayNameAndKeepsTheTimezoneAndLocale()
    {
        Result<CoreUser> result = CoreUser.Create(Guid.CreateVersion7(), "  Ada  ", "Europe/Madrid", "es-ES", TestMoment.Now);

        Assert.True(result.IsSuccess);
        Assert.Equal("Ada", result.Value.DisplayName);
        Assert.Equal("Europe/Madrid", result.Value.TimeZone);
        Assert.Equal("es-ES", result.Value.Locale);
    }

    [Fact]
    public void Create_RejectsATimezoneThatIsNotKnown()
    {
        Result<CoreUser> result = CoreUser.Create(Guid.CreateVersion7(), "Ada", "Mars/Olympus_Mons", "en", TestMoment.Now);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.TimeZoneInvalid, result.Error!.Code);
    }

    [Fact]
    public void Create_RejectsAnEmptyDisplayName()
    {
        Result<CoreUser> result = CoreUser.Create(Guid.CreateVersion7(), "   ", "UTC", "en", TestMoment.Now);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.DisplayNameEmpty, result.Error!.Code);
    }

    [Fact]
    public void Entry_CountsItsWordsAndSoftDeletes()
    {
        CoreEntry entry = CoreEntry.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), Guid.CreateVersion7(), EntryKind.Free, "A day", "one two three", TestMoment.Now).Value;

        Assert.Equal(3, entry.WordCount);

        entry.SoftDelete(TestMoment.Now);
        Assert.NotNull(entry.DeletedAt);

        entry.Restore(TestMoment.Now);
        Assert.Null(entry.DeletedAt);
    }

    [Fact]
    public void Note_IsNotAttachedToADay()
    {
        CoreNote note = CoreNote.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), null, "a thought", TestMoment.Now).Value;

        Assert.Equal(2, note.WordCount);
        Assert.False(note.Pinned);
        Assert.Null(note.DeletedAt);
    }

    [Fact]
    public void RefreshToken_ReportsAReplayAndAnExpiry()
    {
        CoreRefreshToken token = CoreRefreshToken.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), "hash", null, TestMoment.Now.AddDays(60), TestMoment.Now).Value;

        Assert.True(token.EnsureUsable(TestMoment.Now).IsSuccess);

        token.Rotate(Guid.CreateVersion7(), TestMoment.Now);
        Result replay = token.EnsureUsable(TestMoment.Now);
        Assert.True(replay.IsFailure);
        Assert.Equal(ErrorCodes.RefreshTokenReused, replay.Error!.Code);

        CoreRefreshToken expired = CoreRefreshToken.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), "hash", null, TestMoment.Now.AddDays(-1), TestMoment.Now).Value;
        Assert.Equal(ErrorCodes.RefreshTokenExpired, expired.EnsureUsable(TestMoment.Now).Error!.Code);
    }
}
