using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Tests.Domain;

public class CoreDayTests
{
    [Fact]
    public void Create_KeepsTheDayUnratedUntilItIsRated()
    {
        CoreDay day = CreateDay();

        Assert.Null(day.Rating);
        Assert.Null(day.RatedAt);
    }

    [Fact]
    public void SetRating_StoresTheRatingAndTheMomentItWasGiven()
    {
        CoreDay day = CreateDay();
        RatingHalf rating = RatingHalf.From(8).Value;

        Result<CoreDay> result = day.SetRating(rating, TestMoment.Now);

        Assert.True(result.IsSuccess);
        Assert.Equal(rating, day.Rating);
        Assert.Equal(TestMoment.Now, day.RatedAt);
    }

    [Fact]
    public void ClearRating_LeavesTheDayUnratedRatherThanRatedZero()
    {
        CoreDay day = CreateDay();
        day.SetRating(RatingHalf.From(0).Value, TestMoment.Now);

        day.ClearRating(TestMoment.Now);

        Assert.Null(day.Rating);
        Assert.Null(day.RatedAt);
    }

    [Fact]
    public void SetNote_TrimsTheNoteAndRejectsOneThatIsTooLong()
    {
        CoreDay day = CreateDay();

        day.SetNote("  a good day  ", TestMoment.Now);
        Assert.Equal("a good day", day.Note);

        Result<CoreDay> tooLong = day.SetNote(new string('x', CoreDay.MaxNoteLength + 1), TestMoment.Now);
        Assert.True(tooLong.IsFailure);
        Assert.Equal(ErrorCodes.DayNoteTooLong, tooLong.Error!.Code);
    }

    [Fact]
    public void SetGratitudeItem_KeepsOneLinePerPosition()
    {
        CoreDay day = CreateDay();

        day.SetGratitudeItem(Guid.CreateVersion7(), 1, "the coffee", TestMoment.Now);
        day.SetGratitudeItem(Guid.CreateVersion7(), 2, "the light", TestMoment.Now);
        day.SetGratitudeItem(Guid.CreateVersion7(), 3, "the walk", TestMoment.Now);

        Assert.Equal(3, day.GratitudeItems.Count);
        Assert.Equal("the coffee", day.GratitudeItems.Single(item => item.Position == 1).Text);
    }

    [Fact]
    public void SetGratitudeItem_ReplacesTheLineThatAlreadySitsAtAPosition()
    {
        CoreDay day = CreateDay();
        Guid first = Guid.CreateVersion7();
        day.SetGratitudeItem(first, 1, "the coffee", TestMoment.Now);

        day.SetGratitudeItem(Guid.CreateVersion7(), 1, "the rain", TestMoment.Now);

        Assert.Single(day.GratitudeItems);
        Assert.Equal("the rain", day.GratitudeItems[0].Text);
        Assert.Equal(first, day.GratitudeItems[0].Id);
    }

    [Fact]
    public void SetGratitudeItem_RejectsAPositionOutsideTheThreeLines()
    {
        CoreDay day = CreateDay();

        Result<CoreDay> result = day.SetGratitudeItem(Guid.CreateVersion7(), 4, "too many", TestMoment.Now);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.GratitudePositionOutOfRange, result.Error!.Code);
    }

    [Fact]
    public void AddTag_StopsAtFiveTags()
    {
        CoreDay day = CreateDay();

        for (int index = 0; index < CoreDay.MaxTags; index++)
        {
            Assert.True(day.AddTag(Guid.CreateVersion7(), Guid.CreateVersion7(), TestMoment.Now).IsSuccess);
        }

        Result<CoreDay> sixth = day.AddTag(Guid.CreateVersion7(), Guid.CreateVersion7(), TestMoment.Now);

        Assert.True(sixth.IsFailure);
        Assert.Equal(ErrorCodes.DayTagLimitExceeded, sixth.Error!.Code);
    }

    [Fact]
    public void AddTag_RejectsATagTheDayAlreadyCarries()
    {
        CoreDay day = CreateDay();
        Guid tag = Guid.CreateVersion7();
        day.AddTag(Guid.CreateVersion7(), tag, TestMoment.Now);

        Result<CoreDay> again = day.AddTag(Guid.CreateVersion7(), tag, TestMoment.Now);

        Assert.True(again.IsFailure);
        Assert.Equal(ErrorCodes.DayTagDuplicate, again.Error!.Code);
    }

    [Fact]
    public void SetSentiment_RejectsAToneThatBelongsToAnotherDay()
    {
        CoreDay day = CreateDay();
        CoreDaySentiment sentiment = CoreDaySentiment.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), Guid.CreateVersion7(), SentimentSource.Manual, TestMoment.Now).Value;

        Result<CoreDay> result = day.SetSentiment(sentiment, TestMoment.Now);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.DaySentimentMismatch, result.Error!.Code);
    }

    private static CoreDay CreateDay()
    {
        return CoreDay.Create(Guid.CreateVersion7(), Guid.CreateVersion7(), LocalDate.From(2026, 11, 12), TestMoment.Now).Value;
    }
}
