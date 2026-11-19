using System.Security.Cryptography;
using System.Text;
using Aroel.Application.Accounts;
using Aroel.Application.Auth;
using Aroel.Application.Email;
using Aroel.Application.Identity;
using Aroel.Core.Domain.Journal;
using Aroel.Core.Domain.Sync;
using Aroel.Core.Domain.Users;
using Aroel.Data.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;

namespace Aroel.Data.Services;

/// <summary>
/// The account, as the server sees it (§5.9).
/// </summary>
/// <remarks>
/// <para>
/// Registration finds or creates the profile and issues the first pair of tokens. Sign-in
/// checks the address and the password with the same lockout the identity store gives
/// every account: ten failed attempts pause it for five minutes. Provider sign-in
/// validates the provider's token and never trusts the device; a returning reader on a
/// fresh phone keeps the identifier of the account the provider already knows.
/// </para>
/// <para>
/// Refresh tokens are opaque and stored hashed; each use rotates them. A token presented
/// twice was rotated already, so the whole family is compromised and every token of the
/// user is revoked (§7.2). A deleted account takes its journal with it.
/// </para>
/// </remarks>
public sealed class AuthService
{
    private static readonly TimeSpan _refreshTokenLifetime = TimeSpan.FromDays(60);

    private readonly AroelDbContext _db;
    private readonly UserManager<InfrastructureUser> _userManager;
    private readonly IAccountProvisioner _provisioner;
    private readonly IAccessTokenService _tokens;
    private readonly IEmailSender _emailSender;
    private readonly IProviderTokenValidator _providerValidator;
    private readonly TimeProvider _timeProvider;
    private readonly string _confirmationBaseUrl;

    /// <summary>
    /// Initialises the service.
    /// </summary>
    /// <param name="db">The database of the host.</param>
    /// <param name="userManager">The identity store.</param>
    /// <param name="provisioner">The profile provisioner.</param>
    /// <param name="tokens">The access token service.</param>
    /// <param name="emailSender">The confirmation mail sender.</param>
    /// <param name="providerValidator">The provider token validator.</param>
    /// <param name="timeProvider">The source of the current moment.</param>
    /// <param name="configuration">The configuration of the host, read for `Email:ConfirmationBaseUrl`.</param>
    public AuthService(
        AroelDbContext db,
        UserManager<InfrastructureUser> userManager,
        IAccountProvisioner provisioner,
        IAccessTokenService tokens,
        IEmailSender emailSender,
        IProviderTokenValidator providerValidator,
        TimeProvider timeProvider,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(db);
        ArgumentNullException.ThrowIfNull(userManager);
        ArgumentNullException.ThrowIfNull(provisioner);
        ArgumentNullException.ThrowIfNull(tokens);
        ArgumentNullException.ThrowIfNull(emailSender);
        ArgumentNullException.ThrowIfNull(providerValidator);
        ArgumentNullException.ThrowIfNull(timeProvider);
        ArgumentNullException.ThrowIfNull(configuration);

        _db = db;
        _userManager = userManager;
        _provisioner = provisioner;
        _tokens = tokens;
        _emailSender = emailSender;
        _providerValidator = providerValidator;
        _timeProvider = timeProvider;
        _confirmationBaseUrl = configuration["Email:ConfirmationBaseUrl"] ?? "https://aroel.invalid/confirm-email";
    }

    /// <summary>
    /// Creates the account that adopts a local journal.
    /// </summary>
    public async Task<ServiceAuthResult> RegisterAsync(
        Guid userId,
        string email,
        string password,
        string displayName,
        string timeZone,
        string locale,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(email);
        ArgumentNullException.ThrowIfNull(displayName);

        if (await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false) is not null)
        {
            return ServiceAuthResult.Failure("auth.user_id_taken");
        }

        string normalizedEmail = email.Trim().ToLowerInvariant();
        if (await _userManager.FindByEmailAsync(normalizedEmail).ConfigureAwait(false) is not null)
        {
            return ServiceAuthResult.Failure("auth.email_taken");
        }

        Core.Results.Result<CoreUser> profile = await _provisioner.ProvisionAsync(
            userId,
            normalizedEmail,
            password,
            displayName.Trim(),
            timeZone,
            locale,
            cancellationToken).ConfigureAwait(false);

        if (profile.IsFailure)
        {
            string detail = profile.Error is null ? "unknown" : string.Join(';', profile.Error.Args.Select(arg => arg?.ToString() ?? string.Empty));
            string code = detail.Contains("DuplicateEmail", StringComparison.OrdinalIgnoreCase) ||
                detail.Contains("DuplicateUserName", StringComparison.OrdinalIgnoreCase)
                ? "auth.email_taken"
                : detail.Contains("PasswordTooShort", StringComparison.OrdinalIgnoreCase) ||
                  detail.Contains("Password", StringComparison.OrdinalIgnoreCase)
                    ? "auth.weak_password"
                    : "account.creation_failed";
            return ServiceAuthResult.Failure(code);
        }

        InfrastructureUser? identity = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (identity is null)
        {
            return ServiceAuthResult.Failure("account.creation_failed");
        }
        await SendConfirmationAsync(identity, cancellationToken).ConfigureAwait(false);

        return await IssueSessionAsync(identity, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Signs in with an address and a password.
    /// </summary>
    public async Task<ServiceAuthResult> LoginAsync(string email, string password, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(email);
        ArgumentNullException.ThrowIfNull(password);

        string normalizedEmail = email.Trim().ToLowerInvariant();
        InfrastructureUser? user = await _userManager.FindByEmailAsync(normalizedEmail).ConfigureAwait(false);
        if (user is null)
        {
            return ServiceAuthResult.Failure("auth.invalid_credentials");
        }

        if (await _userManager.IsLockedOutAsync(user).ConfigureAwait(false))
        {
            return ServiceAuthResult.Failure("auth.account_locked");
        }

        bool valid = await _userManager.CheckPasswordAsync(user, password).ConfigureAwait(false);
        if (!valid)
        {
            await _userManager.AccessFailedAsync(user).ConfigureAwait(false);
            return await _userManager.IsLockedOutAsync(user).ConfigureAwait(false)
                ? ServiceAuthResult.Failure("auth.account_locked")
                : ServiceAuthResult.Failure("auth.invalid_credentials");
        }

        await _userManager.ResetAccessFailedCountAsync(user).ConfigureAwait(false);
        return await IssueSessionAsync(user, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Signs in with a provider token. The device never decides who the reader is.
    /// </summary>
    public async Task<ServiceAuthResult> OAuthAsync(
        string provider,
        string idToken,
        Guid userId,
        string timeZone,
        string locale,
        string? displayName,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(provider);
        ArgumentNullException.ThrowIfNull(idToken);
        ArgumentNullException.ThrowIfNull(timeZone);
        ArgumentNullException.ThrowIfNull(locale);

        string name = provider.Trim().ToLowerInvariant();
        ProviderIdentity? identity = await _providerValidator.ValidateAsync(name, idToken, cancellationToken).ConfigureAwait(false);
        if (identity is null)
        {
            return ServiceAuthResult.Failure("provider.unavailable");
        }

        InfrastructureUser? existing = await _userManager.FindByLoginAsync(name, identity.Subject).ConfigureAwait(false);
        if (existing is not null)
        {
            await _userManager.ResetAccessFailedCountAsync(existing).ConfigureAwait(false);
            return await IssueSessionAsync(existing, cancellationToken).ConfigureAwait(false);
        }

        string normalizedEmail = identity.Email.Trim().ToLowerInvariant();
        InfrastructureUser? byEmail = string.IsNullOrWhiteSpace(normalizedEmail)
            ? null
            : await _userManager.FindByEmailAsync(normalizedEmail).ConfigureAwait(false);

        if (byEmail is not null)
        {
            // The address is already an account: the device signs in to it, and the
            // client adopts the identifier it was never shown.
            await _userManager.AddLoginAsync(byEmail, new UserLoginInfo(name, identity.Subject, name)).ConfigureAwait(false);
            return await IssueSessionAsync(byEmail, cancellationToken).ConfigureAwait(false);
        }

        string chosenName = string.IsNullOrWhiteSpace(displayName) ? normalizedEmail.Split('@')[0] : displayName.Trim();
        if (await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false) is not null)
        {
            return ServiceAuthResult.Failure("auth.user_id_taken");
        }

        Core.Results.Result<CoreUser> profile = CoreUser.Create(
            userId,
            chosenName,
            timeZone,
            locale,
            _timeProvider.GetUtcNow());
        if (profile.IsFailure)
        {
            return ServiceAuthResult.Failure("user.display_name_empty");
        }

        InfrastructureUser created = new()
        {
            Id = userId,
            UserName = normalizedEmail.Length == 0 ? $"{name}-{identity.Subject}" : normalizedEmail,
            Email = normalizedEmail.Length == 0 ? null : normalizedEmail,
            EmailConfirmed = normalizedEmail.Length > 0,
            CoreUser = profile.Value
        };

        IdentityResult result = await _userManager.CreateAsync(created).ConfigureAwait(false);
        if (!result.Succeeded)
        {
            return ServiceAuthResult.Failure("account.creation_failed");
        }

        await _userManager.AddLoginAsync(created, new UserLoginInfo(name, identity.Subject, name)).ConfigureAwait(false);
        return await IssueSessionAsync(created, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Exchanges a refresh token for a new pair, rotating the token.
    /// </summary>
    public async Task<ServiceAuthResult> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(refreshToken);

        DateTimeOffset now = _timeProvider.GetUtcNow();
        string hash = Hash(refreshToken);
        CoreRefreshToken? token = await _db.Set<CoreRefreshToken>()
            .FirstOrDefaultAsync(candidate => candidate.TokenHash == hash, cancellationToken)
            .ConfigureAwait(false);

        if (token is null)
        {
            return ServiceAuthResult.Failure("refresh_token.reused");
        }

        if (token.IsRevoked)
        {
            // A token presented twice is a leaked token: revoke the whole family.
            List<CoreRefreshToken> family = await _db.Set<CoreRefreshToken>()
                .Where(candidate => candidate.UserId == token.UserId && candidate.RevokedAt == null)
                .ToListAsync(cancellationToken)
                .ConfigureAwait(false);
            foreach (CoreRefreshToken member in family)
            {
                _ = member.Revoke(now);
            }

            await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            return ServiceAuthResult.Failure("refresh_token.reused");
        }

        if (token.ExpiresAt <= now)
        {
            return ServiceAuthResult.Failure("refresh_token.expired");
        }

        InfrastructureUser? user = await _userManager.FindByIdAsync(token.UserId.ToString()).ConfigureAwait(false);
        if (user is null)
        {
            return ServiceAuthResult.Failure("refresh_token.reused");
        }

        (string rawToken, CoreRefreshToken refresh) = await RotateAsync(token, user.Id, now, cancellationToken).ConfigureAwait(false);
        (string accessToken, DateTimeOffset accessExpires) = _tokens.Issue(user.Id, user.Email ?? string.Empty, user.EmailConfirmed);

        return new ServiceAuthResult(
            true,
            Map(user, await LoadProfileAsync(user.Id, cancellationToken).ConfigureAwait(false)),
            new ServiceTokens(accessToken, rawToken, accessExpires, refresh.ExpiresAt),
            null);
    }

    /// <summary>
    /// Revokes a refresh token, if it stands. Idempotent by design.
    /// </summary>
    public async Task LogoutAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(refreshToken);

        string hash = Hash(refreshToken);
        DateTimeOffset now = _timeProvider.GetUtcNow();
        CoreRefreshToken? token = await _db.Set<CoreRefreshToken>()
            .FirstOrDefaultAsync(candidate => candidate.TokenHash == hash, cancellationToken)
            .ConfigureAwait(false);

        if (token is not null)
        {
            _ = token.Revoke(now);
            await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }

    /// <summary>
    /// Changes the password of an account, revoking its other sessions.
    /// </summary>
    public async Task<string?> ChangePasswordAsync(Guid userId, string currentPassword, string newPassword, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(currentPassword);
        ArgumentNullException.ThrowIfNull(newPassword);

        InfrastructureUser? user = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (user is null)
        {
            return "auth.invalid_credentials";
        }

        bool valid = await _userManager.CheckPasswordAsync(user, currentPassword).ConfigureAwait(false);
        if (!valid)
        {
            return "auth.invalid_credentials";
        }

        IdentityResult result = await _userManager.ChangePasswordAsync(user, currentPassword, newPassword).ConfigureAwait(false);
        if (!result.Succeeded)
        {
            return result.Errors.Any(error => error.Code.Contains("Password", StringComparison.OrdinalIgnoreCase))
                ? "auth.weak_password"
                : "account.update_failed";
        }

        await RevokeAllRefreshTokensAsync(user.Id, cancellationToken).ConfigureAwait(false);
        return null;
    }

    /// <summary>
    /// Sends the confirmation of an address again.
    /// </summary>
    public async Task SendVerificationAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        InfrastructureUser? user = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (user is null || user.EmailConfirmed)
        {
            return;
        }

        await SendConfirmationAsync(user, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Confirms an address from the link in the mail.
    /// </summary>
    public async Task<string?> ConfirmEmailAsync(Guid userId, string token)
    {
        ArgumentNullException.ThrowIfNull(token);

        InfrastructureUser? user = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (user is null)
        {
            return "auth.invalid_credentials";
        }

        IdentityResult result = await _userManager.ConfirmEmailAsync(user, token).ConfigureAwait(false);
        return result.Succeeded ? null : "email.confirmation_failed";
    }

    /// <summary>
    /// Reads the profile of the signed-in account.
    /// </summary>
    public async Task<ServiceUser?> GetMeAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        InfrastructureUser? user = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (user is null)
        {
            return null;
        }

        CoreUser? profile = await LoadProfileAsync(userId, cancellationToken).ConfigureAwait(false);
        return Map(user, profile);
    }

    /// <summary>
    /// Changes the display name or the timezone of the signed-in account.
    /// </summary>
    public async Task<(ServiceUser? User, string? ErrorCode)> UpdateMeAsync(Guid userId, string? displayName, string? timeZone, CancellationToken cancellationToken = default)
    {
        CoreUser? profile = await LoadProfileAsync(userId, cancellationToken).ConfigureAwait(false);
        if (profile is null)
        {
            return (null, "user.not_found");
        }

        DateTimeOffset now = _timeProvider.GetUtcNow();

        if (displayName is not null)
        {
            Core.Results.Result<CoreUser> renamed = profile.ChangeDisplayName(displayName, now);
            if (renamed.IsFailure)
            {
                return (null, renamed.Error?.Code ?? "account.update_failed");
            }
        }

        if (timeZone is not null)
        {
            Core.Results.Result<CoreUser> zoned = profile.ChangeTimeZone(timeZone, now);
            if (zoned.IsFailure)
            {
                return (null, zoned.Error?.Code ?? "account.update_failed");
            }
        }

        await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        InfrastructureUser? user = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        return user is null ? (null, "user.not_found") : (Map(user, profile), null);
    }

    /// <summary>
    /// Deletes the account and everything the server holds for it (§5.9).
    /// </summary>
    public async Task DeleteMeAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        List<Guid> dayIds = await _db.Set<CoreDay>()
            .Where(day => day.UserId == userId)
            .Select(day => day.Id)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);

        if (dayIds.Count > 0)
        {
            await _db.Set<CoreGratitudeItem>().Where(item => dayIds.Contains(item.DayId)).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
            await _db.Set<CoreDayTag>().Where(link => dayIds.Contains(link.DayId)).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
            await _db.Set<CoreDaySentiment>().Where(sentiment => dayIds.Contains(sentiment.DayId)).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        }

        await _db.Set<CoreDay>().Where(day => day.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreTag>().Where(tag => tag.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreEntry>().Where(entry => entry.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreNote>().Where(note => note.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreRefreshToken>().Where(token => token.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreDevice>().Where(device => device.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<Core.Domain.Streak.CoreStreakState>().Where(state => state.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<Core.Domain.Streak.CoreStreakRestoration>().Where(restoration => restoration.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);
        await _db.Set<CoreSyncTombstone>().Where(tombstone => tombstone.UserId == userId).ExecuteDeleteAsync(cancellationToken).ConfigureAwait(false);

        CoreUser? profile = await LoadProfileAsync(userId, cancellationToken).ConfigureAwait(false);
        if (profile is not null)
        {
            _db.Set<CoreUser>().Remove(profile);
            await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }

        InfrastructureUser? identity = await _userManager.FindByIdAsync(userId.ToString()).ConfigureAwait(false);
        if (identity is not null)
        {
            await _userManager.DeleteAsync(identity).ConfigureAwait(false);
        }
    }

    private async Task<ServiceAuthResult> IssueSessionAsync(InfrastructureUser user, CancellationToken cancellationToken)
    {
        DateTimeOffset now = _timeProvider.GetUtcNow();
        (string rawToken, CoreRefreshToken refresh) = await CreateRefreshTokenAsync(user.Id, now, cancellationToken).ConfigureAwait(false);
        (string accessToken, DateTimeOffset accessExpires) = _tokens.Issue(user.Id, user.Email ?? string.Empty, user.EmailConfirmed);

        CoreUser? profile = await LoadProfileAsync(user.Id, cancellationToken).ConfigureAwait(false);
        return new ServiceAuthResult(
            true,
            Map(user, profile),
            new ServiceTokens(accessToken, rawToken, accessExpires, refresh.ExpiresAt),
            null);
    }

    private async Task<(string RawToken, CoreRefreshToken Token)> RotateAsync(CoreRefreshToken current, Guid userId, DateTimeOffset now, CancellationToken cancellationToken)
    {
        string raw = NewRefreshToken();
        CoreRefreshToken next = CoreRefreshToken.Create(
            Guid.CreateVersion7(),
            userId,
            Hash(raw),
            current.DeviceId,
            now.Add(_refreshTokenLifetime),
            now).Value;

        _ = current.Rotate(next.Id, now);
        _db.Set<CoreRefreshToken>().Add(next);
        await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return (raw, next);
    }

    private async Task<(string RawToken, CoreRefreshToken Token)> CreateRefreshTokenAsync(Guid userId, DateTimeOffset now, CancellationToken cancellationToken)
    {
        string raw = NewRefreshToken();
        CoreRefreshToken token = CoreRefreshToken.Create(
            Guid.CreateVersion7(),
            userId,
            Hash(raw),
            null,
            now.Add(_refreshTokenLifetime),
            now).Value;

        _db.Set<CoreRefreshToken>().Add(token);
        await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return (raw, token);
    }

    private static string NewRefreshToken()
    {
        Span<byte> bytes = stackalloc byte[48];
        RandomNumberGenerator.Fill(bytes);
        return Convert.ToBase64String(bytes).Replace('+', '-').Replace('/', '_').TrimEnd('=');
    }

    private static string Hash(string raw)
    {
        byte[] hash = SHA256.HashData(Encoding.UTF8.GetBytes(raw));
        return Convert.ToBase64String(hash).Replace('+', '-').Replace('/', '_').TrimEnd('=');
    }

    private async Task RevokeAllRefreshTokensAsync(Guid userId, CancellationToken cancellationToken)
    {
        DateTimeOffset now = _timeProvider.GetUtcNow();
        List<CoreRefreshToken> tokens = await _db.Set<CoreRefreshToken>()
            .Where(token => token.UserId == userId && token.RevokedAt == null)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (CoreRefreshToken token in tokens)
        {
            _ = token.Revoke(now);
        }

        await _db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private async Task<CoreUser?> LoadProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        return await _db.Set<CoreUser>().FirstOrDefaultAsync(user => user.Id == userId, cancellationToken).ConfigureAwait(false);
    }

    private ServiceUser Map(InfrastructureUser user, CoreUser? profile)
    {
        DateTimeOffset fallback = _timeProvider.GetUtcNow();
        return new ServiceUser(
            user.Id,
            user.Email ?? string.Empty,
            profile?.DisplayName ?? string.Empty,
            profile?.TimeZone ?? "UTC",
            profile?.Locale ?? "en",
            user.EmailConfirmed,
            profile?.CreatedAt ?? fallback,
            profile?.UpdatedAt ?? fallback);
    }

    private async Task SendConfirmationAsync(InfrastructureUser user, CancellationToken cancellationToken)
    {
        string token = await _userManager.GenerateEmailConfirmationTokenAsync(user).ConfigureAwait(false);
        string confirmationUrl = $"{_confirmationBaseUrl}?userId={user.Id}&token={Uri.EscapeDataString(token)}";
        await _emailSender.SendConfirmationAsync(user.Email ?? string.Empty, confirmationUrl, cancellationToken).ConfigureAwait(false);
    }
}
