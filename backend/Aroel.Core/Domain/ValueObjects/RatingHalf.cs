using System.Globalization;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.ValueObjects;

/// <summary>
/// A rating expressed in half points, from 0 to 10, where 0 is "a day I'd rather not
/// repeat" and 10 is "one of the good ones".
/// </summary>
/// <remarks>
/// The scale is stored as an integer count of half points because a float makes
/// <c>where rating = 3.5</c> unreliable and a decimal string invites a round trip through
/// 3.4999. The presentation layer converts to the 0..5 scale, and only there.
/// </remarks>
public readonly record struct RatingHalf
{
    /// <summary>
    /// The lowest rating, in half points: a day worth zero.
    /// </summary>
    public const int MinimumHalfPoints = 0;

    /// <summary>
    /// The highest rating, in half points: five whole points.
    /// </summary>
    public const int MaximumHalfPoints = 10;

    /// <summary>
    /// The number of half points in one whole point.
    /// </summary>
    public const int HalfPointsPerPoint = 2;

    private RatingHalf(int halfPoints)
    {
        HalfPoints = halfPoints;
    }

    /// <summary>
    /// Gets the rating as a count of half points, from 0 to 10.
    /// </summary>
    public int HalfPoints { get; }

    /// <summary>
    /// Gets the rating on the 0..5 scale, for display and for arithmetic against anchors.
    /// </summary>
    public decimal Score => HalfPoints / (decimal)HalfPointsPerPoint;

    /// <summary>
    /// Creates a rating from a count of half points.
    /// </summary>
    /// <param name="halfPoints">The count of half points, from 0 to 10.</param>
    /// <returns>The rating, or a failure when the count falls outside the scale.</returns>
    public static Result<RatingHalf> From(int halfPoints)
    {
        return halfPoints is < MinimumHalfPoints or > MaximumHalfPoints
            ? Result.Failure<RatingHalf>(new AppError(ErrorCodes.RatingOutOfRange, halfPoints, MinimumHalfPoints, MaximumHalfPoints))
            : Result.Success(new RatingHalf(halfPoints));
    }

    /// <summary>
    /// Creates a rating from a score on the 0..5 scale.
    /// </summary>
    /// <param name="score">The score, which must land on a half step.</param>
    /// <returns>The rating, or a failure when the score is out of range or off a step.</returns>
    public static Result<RatingHalf> FromScore(decimal score)
    {
        if (score is < 0m or > 5m)
        {
            return Result.Failure<RatingHalf>(new AppError(ErrorCodes.RatingOutOfRange, score, 0m, 5m));
        }

        decimal doubled = score * HalfPointsPerPoint;

        return doubled != decimal.Truncate(doubled)
            ? Result.Failure<RatingHalf>(new AppError(ErrorCodes.RatingNotHalfStep, score))
            : From((int)doubled);
    }

    /// <summary>
    /// Wraps a count of half points without checking the range, for hydration from storage.
    /// </summary>
    /// <param name="halfPoints">The stored count of half points.</param>
    public static RatingHalf Restore(int halfPoints)
    {
        return new RatingHalf(halfPoints);
    }

    /// <summary>
    /// Returns the rating on the 0..5 scale.
    /// </summary>
    public override string ToString()
    {
        return Score.ToString("0.0", CultureInfo.InvariantCulture);
    }
}
