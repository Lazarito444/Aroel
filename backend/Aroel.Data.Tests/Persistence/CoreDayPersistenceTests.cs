using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Users;
using Aroel.Core.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Data.Tests.Persistence;

public class CoreDayPersistenceTests
{
    [Fact]
    public async Task ADayComesBackWithItsRatingGratitudeAndTags()
    {
        await using AroelDbContext context = CreateContext();

        Guid userId = Guid.CreateVersion7();
        CoreUser user = CoreUser.Create(userId, "Ada", "UTC", "en", DateTimeOffset.UtcNow).Value;
        context.Set<CoreUser>().Add(user);
        await context.SaveChangesAsync();

        Guid dayId = Guid.CreateVersion7();
        CoreDay day = CoreDay.Create(dayId, userId, LocalDate.From(2026, 11, 12), DateTimeOffset.UtcNow).Value;
        day.SetRating(RatingHalf.From(7).Value, DateTimeOffset.UtcNow);
        day.SetGratitudeItem(Guid.CreateVersion7(), 1, "the coffee", DateTimeOffset.UtcNow);
        day.AddTag(Guid.CreateVersion7(), Guid.CreateVersion7(), DateTimeOffset.UtcNow);
        context.Set<CoreDay>().Add(day);
        await context.SaveChangesAsync();

        context.ChangeTracker.Clear();

        CoreDay loaded = await context.Set<CoreDay>()
            .Include(day => day.GratitudeItems)
            .Include(day => day.Tags)
            .SingleAsync(candidate => candidate.Id == dayId);

        Assert.Equal(dayId, loaded.Id);
        Assert.Equal(RatingHalf.From(7).Value, loaded.Rating);
        Assert.Equal(userId, loaded.UserId);
        Assert.Equal(LocalDate.From(2026, 11, 12), loaded.LocalDate);
        Assert.Single(loaded.GratitudeItems);
        Assert.Equal("the coffee", loaded.GratitudeItems[0].Text);
        Assert.Single(loaded.Tags);
    }

    [Fact]
    public async Task AnUnratedDayComesBackWithoutARating()
    {
        await using AroelDbContext context = CreateContext();

        Guid userId = Guid.CreateVersion7();
        context.Set<CoreUser>().Add(CoreUser.Create(userId, "Ada", "UTC", "en", DateTimeOffset.UtcNow).Value);
        await context.SaveChangesAsync();

        Guid dayId = Guid.CreateVersion7();
        context.Set<CoreDay>().Add(CoreDay.Create(dayId, userId, LocalDate.From(2026, 11, 12), DateTimeOffset.UtcNow).Value);
        await context.SaveChangesAsync();

        context.ChangeTracker.Clear();

        CoreDay loaded = await context.Set<CoreDay>().SingleAsync(candidate => candidate.Id == dayId);

        Assert.Null(loaded.Rating);
        Assert.Null(loaded.RatedAt);
    }

    private static AroelDbContext CreateContext()
    {
        DbContextOptions<AroelDbContext> options = new DbContextOptionsBuilder<AroelDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        return new AroelDbContext(options);
    }
}
