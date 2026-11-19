using System.Net;
using System.Text.Json;
using Aroel.Data.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;

namespace Aroel.Api.Tests;

/// <summary>
/// The account loop, end to end: sign up, sign in, refresh, rotate, reuse detection,
/// the verified-email gate on sync and the journal following a day over the wire.
/// </summary>
public sealed class AccountFlowTests : IClassFixture<ApiFactory>
{
    private static readonly JsonSerializerOptions _json = new(JsonSerializerDefaults.Web);

    private readonly ApiFactory _factory;

    public AccountFlowTests(ApiFactory factory)
    {
        _factory = factory;
    }

    private static object RegisterBody(Guid userId, string email)
    {
        return new
        {
            userId,
            email,
            password = "12345678",
            displayName = "Ada",
            timeZone = "Europe/Madrid",
            locale = "en-GB"
        };
    }

    private static string UniqueEmail()
    {
        return $"ada-{Guid.CreateVersion7():N}@example.com";
    }

    private static async Task<HttpResponseMessage> RegisterAsync(HttpClient client, Guid userId, string email)
    {
        return await client.PostAsJsonAsync("/v1/auth/register", RegisterBody(userId, email), _json);
    }

    private async Task ConfirmEmailAsync(Guid userId)
    {
        using IServiceScope scope = _factory.Services.CreateScope();
        UserManager<InfrastructureUser> users = scope.ServiceProvider.GetRequiredService<UserManager<InfrastructureUser>>();
        InfrastructureUser user = (await users.FindByIdAsync(userId.ToString()))!;
        string token = await users.GenerateEmailConfirmationTokenAsync(user);

        using HttpClient client = _factory.CreateClient();
        HttpResponseMessage response = await client.GetAsync($"/v1/auth/confirm-email?userId={userId}&token={Uri.EscapeDataString(token)}");
        response.EnsureSuccessStatusCode();
    }

    private async Task<HttpResponseMessage> AuthenticatedAsync(HttpMethod method, string path, string accessToken, object? body = null)
    {
        using HttpRequestMessage request = new(method, path);
        request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);
        if (body is not null)
        {
            request.Content = JsonContent.Create(body, options: _json);
        }

        using HttpClient client = _factory.CreateClient();
        return await client.SendAsync(request);
    }

    [Fact]
    public async Task RegisterIssuesASessionAndTheMeEndpointAnswersIt()
    {
        using HttpClient client = _factory.CreateClient();

        string email = UniqueEmail();
        HttpResponseMessage register = await RegisterAsync(client, Guid.CreateVersion7(), email);
        register.EnsureSuccessStatusCode();

        using JsonDocument auth = JsonDocument.Parse(await register.Content.ReadAsStringAsync());
        string accessToken = auth.RootElement.GetProperty("tokens").GetProperty("accessToken").GetString()!;

        HttpResponseMessage me = await AuthenticatedAsync(HttpMethod.Get, "/v1/me", accessToken);
        me.EnsureSuccessStatusCode();

        using JsonDocument profile = JsonDocument.Parse(await me.Content.ReadAsStringAsync());
        Assert.Equal(email, profile.RootElement.GetProperty("email").GetString());
        Assert.False(profile.RootElement.GetProperty("emailVerified").GetBoolean());
    }

    [Fact]
    public async Task SyncIsRefusedUntilTheAddressIsConfirmed()
    {
        using HttpClient client = _factory.CreateClient();

        Guid userId = Guid.CreateVersion7();
        string email = UniqueEmail();
        HttpResponseMessage register = await RegisterAsync(client, userId, email);
        using JsonDocument auth = JsonDocument.Parse(await register.Content.ReadAsStringAsync());
        string accessToken = auth.RootElement.GetProperty("tokens").GetProperty("accessToken").GetString()!;

        HttpResponseMessage before = await AuthenticatedAsync(HttpMethod.Get, "/v1/sync", accessToken);
        Assert.Equal(HttpStatusCode.Forbidden, before.StatusCode);

        await ConfirmEmailAsync(userId);

        // The old access token still says the address was not confirmed; a refresh carries it forward.
        string refreshToken = auth.RootElement.GetProperty("tokens").GetProperty("refreshToken").GetString()!;
        HttpResponseMessage refreshed = await client.PostAsJsonAsync("/v1/auth/refresh", new { refreshToken }, _json);
        using JsonDocument refreshedBody = JsonDocument.Parse(await refreshed.Content.ReadAsStringAsync());
        string verifiedToken = refreshedBody.RootElement.GetProperty("accessToken").GetString()!;

        HttpResponseMessage after = await AuthenticatedAsync(HttpMethod.Get, "/v1/sync", verifiedToken);
        after.EnsureSuccessStatusCode();
    }

    [Fact]
    public async Task ARefreshTokenRotatesAndAReplayedOneRevealsItself()
    {
        using HttpClient client = _factory.CreateClient();

        string email = UniqueEmail();
        HttpResponseMessage register = await RegisterAsync(client, Guid.CreateVersion7(), email);
        using JsonDocument auth = JsonDocument.Parse(await register.Content.ReadAsStringAsync());
        string refreshToken = auth.RootElement.GetProperty("tokens").GetProperty("refreshToken").GetString()!;

        HttpResponseMessage rotated = await client.PostAsJsonAsync("/v1/auth/refresh", new { refreshToken }, _json);
        rotated.EnsureSuccessStatusCode();

        // Replaying the old token must revoke the family, not hand out a new session.
        HttpResponseMessage replayed = await client.PostAsJsonAsync("/v1/auth/refresh", new { refreshToken }, _json);
        Assert.Equal(HttpStatusCode.Unauthorized, replayed.StatusCode);

        using JsonDocument body = JsonDocument.Parse(await replayed.Content.ReadAsStringAsync());
        Assert.Equal("refresh_token.reused", body.RootElement.GetProperty("code").GetString());

        // And the token that replaced it dies with the family.
        using JsonDocument rotatedBody = JsonDocument.Parse(await rotated.Content.ReadAsStringAsync());
        string replacement = rotatedBody.RootElement.GetProperty("refreshToken").GetString()!;
        HttpResponseMessage afterReuse = await client.PostAsJsonAsync("/v1/auth/refresh", new { refreshToken = replacement }, _json);
        Assert.Equal(HttpStatusCode.Unauthorized, afterReuse.StatusCode);
    }

    [Fact]
    public async Task APushedDaySurvivesTheRoundTrip()
    {
        using HttpClient client = _factory.CreateClient();

        Guid userId = Guid.CreateVersion7();
        string email = UniqueEmail();
        HttpResponseMessage register = await RegisterAsync(client, userId, email);
        using JsonDocument auth = JsonDocument.Parse(await register.Content.ReadAsStringAsync());
        string refreshToken = auth.RootElement.GetProperty("tokens").GetProperty("refreshToken").GetString()!;

        await ConfirmEmailAsync(userId);

        HttpResponseMessage refreshed = await client.PostAsJsonAsync("/v1/auth/refresh", new { refreshToken }, _json);
        using JsonDocument refreshedBody = JsonDocument.Parse(await refreshed.Content.ReadAsStringAsync());
        string accessToken = refreshedBody.RootElement.GetProperty("accessToken").GetString()!;

        Guid dayId = Guid.CreateVersion7();
        object batch = new
        {
            operations = new object[]
            {
                new
                {
                    table = "days",
                    op = "upsert",
                    id = dayId,
                    updatedAt = DateTimeOffset.UtcNow,
                    data = new
                    {
                        localDate = "2026-11-18",
                        ratingHalf = 7,
                        note = "a good day",
                        createdAt = DateTimeOffset.UtcNow,
                        updatedAt = DateTimeOffset.UtcNow
                    }
                }
            }
        };

        HttpResponseMessage push = await AuthenticatedAsync(HttpMethod.Post, "/v1/sync/batch", accessToken, batch);
        push.EnsureSuccessStatusCode();

        HttpResponseMessage pull = await AuthenticatedAsync(HttpMethod.Get, "/v1/sync?since=0", accessToken);
        pull.EnsureSuccessStatusCode();

        string content = await pull.Content.ReadAsStringAsync();
        Assert.Contains("2026-11-18", content);
        Assert.Contains(dayId.ToString(), content);
    }
}
