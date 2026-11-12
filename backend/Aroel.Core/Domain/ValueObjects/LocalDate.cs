using System.Globalization;

namespace Aroel.Core.Domain.ValueObjects;

/// <summary>
/// The calendar day a record belongs to, in the user's own timezone.
/// </summary>
/// <remarks>
/// A day is a diary concept, not a UTC one: an entry written at 00:30 belongs to the
/// previous evening in the user's head, and therefore to its local date and not to its UTC
/// timestamp. Every query over history and analytics reads this date, which is what keeps
/// timezone drift out of the numbers.
/// </remarks>
public readonly record struct LocalDate
{
    private LocalDate(DateOnly value)
    {
        Value = value;
    }

    /// <summary>
    /// Gets the underlying date.
    /// </summary>
    public DateOnly Value { get; }

    /// <summary>
    /// Wraps a date.
    /// </summary>
    /// <param name="value">The date to wrap.</param>
    public static LocalDate From(DateOnly value)
    {
        return new LocalDate(value);
    }

    /// <summary>
    /// Builds a date from its parts.
    /// </summary>
    /// <param name="year">The year.</param>
    /// <param name="month">The month.</param>
    /// <param name="day">The day of the month.</param>
    public static LocalDate From(int year, int month, int day)
    {
        return new LocalDate(new DateOnly(year, month, day));
    }

    /// <summary>
    /// Gets the date that falls the given number of days after this one.
    /// </summary>
    /// <param name="days">The number of days to add; may be negative.</param>
    public LocalDate AddDays(int days)
    {
        return new LocalDate(Value.AddDays(days));
    }

    /// <summary>
    /// Gets the number of days from this date to another.
    /// </summary>
    /// <param name="other">The date to measure to.</param>
    /// <returns>The number of days; negative when the other date is in the past.</returns>
    public int DaysUntil(LocalDate other)
    {
        return other.Value.DayNumber - Value.DayNumber;
    }

    /// <summary>
    /// Gets the number of days from another date to this one.
    /// </summary>
    /// <param name="other">The date to measure from.</param>
    /// <returns>The number of days; negative when the other date is in the future.</returns>
    public int DaysSince(LocalDate other)
    {
        return Value.DayNumber - other.Value.DayNumber;
    }

    /// <summary>
    /// Returns the canonical ISO date string.
    /// </summary>
    public override string ToString()
    {
        return Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    }
}
