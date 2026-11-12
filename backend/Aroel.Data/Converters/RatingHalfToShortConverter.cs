using Aroel.Core.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Aroel.Data.Converters;

/// <summary>
/// Converts a <see cref="RatingHalf"/> to and from the <c>smallint</c> column it lives in.
/// </summary>
public sealed class RatingHalfToShortConverter : ValueConverter<RatingHalf, short>
{
    /// <summary>
    /// Initialises the converter.
    /// </summary>
    public RatingHalfToShortConverter()
        : base(rating => (short)rating.HalfPoints, value => RatingHalf.Restore(value))
    {
    }
}
