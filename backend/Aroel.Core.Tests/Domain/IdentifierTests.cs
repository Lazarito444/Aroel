using Aroel.Core.Domain.Errors;
using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.ValueObjects;
using Aroel.Core.Results;

namespace Aroel.Core.Tests.Domain;

public class IdentifierTests
{
    [Fact]
    public void CreateVersion7_ProducesAVersionSevenIdentifier()
    {
        Guid id = Guid.CreateVersion7();

        Assert.Equal(7, VersionOf(id));
        Assert.NotEqual(Guid.Empty, id);
    }

    [Fact]
    public void CreateVersion7_ProducesIdentifiersThatSortByCreationTime()
    {
        Guid earlier = Guid.CreateVersion7(DateTimeOffset.Parse("2026-11-12T09:00:00Z", null, System.Globalization.DateTimeStyles.AdjustToUniversal));
        Guid later = Guid.CreateVersion7(DateTimeOffset.Parse("2026-11-12T10:00:00Z", null, System.Globalization.DateTimeStyles.AdjustToUniversal));

        Assert.True(earlier.CompareTo(later) < 0);
    }

    [Fact]
    public void AnEntityRefusesAnEmptyIdentifier()
    {
        Result<CoreDay> result = CoreDay.Create(Guid.Empty, Guid.CreateVersion7(), LocalDate.From(2026, 11, 12), TestMoment.Now);

        Assert.True(result.IsFailure);
        Assert.Equal(ErrorCodes.IdentifierEmpty, result.Error!.Code);
    }

    private static int VersionOf(Guid value)
    {
        string hex = value.ToString("N", System.Globalization.CultureInfo.InvariantCulture);
        return Convert.ToInt32(hex.Substring(12, 2), 16) >> 4;
    }
}
