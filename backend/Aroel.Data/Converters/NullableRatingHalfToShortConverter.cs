using Aroel.Core.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Aroel.Data.Converters;

/// <summary>
/// Converts a nullable <see cref="RatingHalf"/> to and from the <c>smallint</c> column it
/// lives in, where an absent rating is an absent column and not a zero.
/// </summary>
public sealed class NullableRatingHalfToShortConverter : ValueConverter<RatingHalf?, short?>
{
    /// <summary>
    /// Initialises the converter.
    /// </summary>
    public NullableRatingHalfToShortConverter()
        : base(
            rating => rating.HasValue ? (short)rating.Value.HalfPoints : null,
            value => value.HasValue ? RatingHalf.Restore(value.Value) : null)
    {
    }
}
