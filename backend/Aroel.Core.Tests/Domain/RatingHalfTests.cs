using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Tests.Domain;

public class RatingHalfTests
{
    [Theory]
    [InlineData(0)]
    [InlineData(5)]
    [InlineData(10)]
    public void From_AcceptsEveryHalfPointOfTheScale(int halfPoints)
    {
        Result<RatingHalf> result = RatingHalf.From(halfPoints);

        Assert.True(result.IsSuccess);
        Assert.Equal(halfPoints, result.Value.HalfPoints);
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(11)]
    public void From_RejectsARatingOutsideTheScale(int halfPoints)
    {
        Result<RatingHalf> result = RatingHalf.From(halfPoints);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.RatingOutOfRange, result.Error!.Code);
    }

    [Fact]
    public void FromScore_ReadsThreeAndAHalfAsSevenHalfPoints()
    {
        Result<RatingHalf> result = RatingHalf.FromScore(3.5m);

        Assert.True(result.IsSuccess);
        Assert.Equal(7, result.Value.HalfPoints);
        Assert.Equal(3.5m, result.Value.Score);
    }

    [Fact]
    public void FromScore_RejectsAScoreThatIsOffAStep()
    {
        Result<RatingHalf> result = RatingHalf.FromScore(3.3m);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.RatingNotHalfStep, result.Error!.Code);
    }

    [Fact]
    public void FromScore_RejectsAScoreOutsideTheScale()
    {
        Result<RatingHalf> result = RatingHalf.FromScore(5.5m);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.RatingOutOfRange, result.Error!.Code);
    }

    [Fact]
    public void ZeroIsAScoreAndNotTheAbsenceOfOne()
    {
        Result<RatingHalf> result = RatingHalf.From(0);

        Assert.True(result.IsSuccess);
        Assert.Equal(0m, result.Value.Score);
    }
}
