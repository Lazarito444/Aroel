using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Users;

/// <summary>
/// A refresh token, held so that it can be rotated and so that a replay can be detected.
/// </summary>
/// <remarks>
/// Only the hash of the token is stored, so a leaked database cannot be turned into a
/// usable session. Rotation is one-way: the token that was presented is revoked and the
/// token that replaced it points back at it through <see cref="RotatedFromId"/>. That
/// pointer is what makes replay detectable — a token that is presented twice was already
/// rotated, which means it leaked, which means the family is compromised.
/// </remarks>
public sealed class CoreRefreshToken : Entity
{
    private CoreRefreshToken()
    {
    }

    private CoreRefreshToken(Guid id, Guid userId, string tokenHash, Guid? deviceId, DateTimeOffset expiresAt, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        TokenHash = tokenHash;
        DeviceId = deviceId;
        ExpiresAt = expiresAt;
    }

    /// <summary>
    /// Gets the user the token was issued to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the hash of the token; the token itself is never stored.
    /// </summary>
    public string TokenHash { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the device the token was issued to, when it was issued to one.
    /// </summary>
    public Guid? DeviceId { get; private set; }

    /// <summary>
    /// Gets the moment the token stops being accepted, in UTC.
    /// </summary>
    public DateTimeOffset ExpiresAt { get; private set; }

    /// <summary>
    /// Gets the moment the token was revoked, in UTC; <see langword="null"/> while it stands.
    /// </summary>
    public DateTimeOffset? RevokedAt { get; private set; }

    /// <summary>
    /// Gets the token this one replaced, when it replaced one.
    /// </summary>
    public Guid? RotatedFromId { get; private set; }

    /// <summary>
    /// Gets a value indicating whether the token was already rotated or revoked.
    /// </summary>
    public bool IsRevoked => RevokedAt is not null;

    /// <summary>
    /// Creates a refresh token.
    /// </summary>
    /// <param name="id">The identifier of the token, which must not be empty.</param>
    /// <param name="userId">The user the token is issued to.</param>
    /// <param name="tokenHash">The hash of the token.</param>
    /// <param name="deviceId">The device the token is issued to, when it was issued to one.</param>
    /// <param name="expiresAt">The moment the token stops being accepted.</param>
    /// <param name="now">The moment the token was issued, in UTC.</param>
    /// <returns>The token, or a failure when the hash is missing.</returns>
    public static Result<CoreRefreshToken> Create(Guid id, Guid userId, string tokenHash, Guid? deviceId, DateTimeOffset expiresAt, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(tokenHash);

        return id == Guid.Empty
            ? Result.Failure<CoreRefreshToken>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateTokenHash(tokenHash).Map(hash =>
                new CoreRefreshToken(id, userId, hash, deviceId, expiresAt, now));
    }

    /// <summary>
    /// Records that the token was replaced by another one.
    /// </summary>
    /// <param name="replacedById">The identifier of the token that replaced this one.</param>
    /// <param name="now">The moment of the rotation, in UTC.</param>
    /// <returns>The token, or a failure when it was already revoked.</returns>
    public Result<CoreRefreshToken> Rotate(Guid replacedById, DateTimeOffset now)
    {
        if (IsRevoked)
        {
            return Result.Failure<CoreRefreshToken>(new AppError(ErrorCodes.RefreshTokenReused));
        }

        RotatedFromId = replacedById;
        RevokedAt = now;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Revokes the token without replacing it.
    /// </summary>
    /// <param name="now">The moment of the revocation, in UTC.</param>
    /// <returns>The token.</returns>
    public Result<CoreRefreshToken> Revoke(DateTimeOffset now)
    {
        if (IsRevoked)
        {
            return Result.Success(this);
        }

        RevokedAt = now;
        Touch(now);
        return Result.Success(this);
    }

    /// <summary>
    /// Checks that the token may still be exchanged.
    /// </summary>
    /// <param name="now">The moment of the check, in UTC.</param>
    /// <returns>Success when the token stands, or a failure naming the reason it does not.</returns>
    public Result EnsureUsable(DateTimeOffset now)
    {
        if (IsRevoked)
        {
            return Result.Failure(new AppError(ErrorCodes.RefreshTokenReused));
        }

        bool expired = ExpiresAt <= now;

        return expired
            ? Result.Failure(new AppError(ErrorCodes.RefreshTokenExpired))
            : Result.Success();
    }

    private static Result<string> ValidateTokenHash(string tokenHash)
    {
        if (string.IsNullOrWhiteSpace(tokenHash))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.RefreshTokenHashEmpty));
        }

        string trimmed = tokenHash.Trim();

        return Result.Success(trimmed);
    }
}
