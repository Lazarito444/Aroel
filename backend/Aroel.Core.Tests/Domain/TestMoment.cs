using System.Globalization;

namespace Aroel.Core.Tests.Domain;

/// <summary>
/// The moment every test pretends to happen at.
/// </summary>
internal static class TestMoment
{
    /// <summary>
    /// The fixed moment the tests use, so that nothing depends on the wall clock.
    /// </summary>
    public static readonly DateTimeOffset Now = DateTimeOffset.Parse("2026-11-12T20:00:00Z", CultureInfo.InvariantCulture, DateTimeStyles.AdjustToUniversal);
}
