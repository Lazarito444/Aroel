using Aroel.Core.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Aroel.Data.Converters;

/// <summary>
/// Converts a <see cref="LocalDate"/> to and from the <c>date</c> column it lives in.
/// </summary>
public sealed class LocalDateToDateOnlyConverter : ValueConverter<LocalDate, DateOnly>
{
    /// <summary>
    /// Initialises the converter.
    /// </summary>
    public LocalDateToDateOnlyConverter()
        : base(date => date.Value, value => LocalDate.From(value))
    {
    }
}
