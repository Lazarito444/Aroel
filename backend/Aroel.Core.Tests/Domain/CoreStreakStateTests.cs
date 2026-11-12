using Aroel.Core.Domain.Streak;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Tests.Domain;

public class CoreStreakStateTests
{
    [Fact]
    public void TheFirstKeptDayStartsTheStreak()
    {
        CoreStreakState streak = CreateStreak();

        streak.RecordActivity(Day(12), TestMoment.Now);

        Assert.Equal(1, streak.CurrentStreak);
        Assert.Equal(Day(12), streak.LastKeptDate);
    }

    [Fact]
    public void ConsecutiveDaysExtendTheStreak()
    {
        CoreStreakState streak = CreateStreak();

        streak.RecordActivity(Day(12), TestMoment.Now);
        streak.RecordActivity(Day(13), TestMoment.Now);
        streak.RecordActivity(Day(14), TestMoment.Now);

        Assert.Equal(3, streak.CurrentStreak);
        Assert.Equal(3, streak.LongestStreak);
    }

    [Fact]
    public void OneMissedDayIsForgivenByTheGraceToken()
    {
        CoreStreakState streak = CreateStreak();

        streak.RecordActivity(Day(12), TestMoment.Now);
        streak.RecordActivity(Day(13), TestMoment.Now);
        streak.RecordActivity(Day(15), TestMoment.Now);

        Assert.Equal(3, streak.CurrentStreak);
        Assert.Equal(0, streak.GraceRemaining);
    }

    [Fact]
    public void TwoMissedDaysInARowBreakTheStreak()
    {
        CoreStreakState streak = CreateStreak();

        streak.RecordActivity(Day(12), TestMoment.Now);
        streak.RecordActivity(Day(13), TestMoment.Now);
        streak.RecordActivity(Day(16), TestMoment.Now);

        Assert.Equal(1, streak.CurrentStreak);
        Assert.Equal(2, streak.LongestStreak);
        Assert.Equal(CoreStreakState.MaxGrace, streak.GraceRemaining);
    }

    [Fact]
    public void ARecoveredDayIsRecordedAndCountsAsKept()
    {
        CoreStreakState streak = CreateStreak();
        streak.RecordActivity(Day(12), TestMoment.Now);

        Result<CoreStreakState> result = streak.Restore(Guid.CreateVersion7(), Day(13), TestMoment.Now);

        Assert.True(result.IsSuccess);
        Assert.Single(streak.Restorations);
        Assert.Equal(Day(13), streak.Restorations[0].LocalDate);
        Assert.Equal(2, streak.CurrentStreak);
    }

    [Fact]
    public void TheSameDayCountedTwiceChangesNothing()
    {
        CoreStreakState streak = CreateStreak();

        streak.RecordActivity(Day(12), TestMoment.Now);
        streak.RecordActivity(Day(12), TestMoment.Now);

        Assert.Equal(1, streak.CurrentStreak);
    }

    private static CoreStreakState CreateStreak()
    {
        return CoreStreakState.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), TestMoment.Now).Value;
    }

    private static LocalDate Day(int dayOfMonth)
    {
        return LocalDate.From(2026, 11, dayOfMonth);
    }
}
