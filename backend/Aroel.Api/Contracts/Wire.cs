using System.Text.Json.Nodes;

namespace Aroel.Api.Contracts;

/// <summary>What registration asks for.</summary>
internal sealed record RegisterRequest(Guid UserId, string Email, string Password, string DisplayName, string TimeZone, string Locale);

/// <summary>What sign-in asks for.</summary>
internal sealed record LoginRequest(string Email, string Password);

/// <summary>What a provider sign-in asks for.</summary>
internal sealed record OAuthRequest(string Provider, string IdToken, Guid UserId, string TimeZone, string Locale, string? DisplayName);

/// <summary>What the token exchange asks for.</summary>
internal sealed record RefreshRequest(string RefreshToken);

/// <summary>What a password change asks for.</summary>
internal sealed record PasswordChangeRequest(string CurrentPassword, string NewPassword);

/// <summary>What a profile change asks for.</summary>
internal sealed record UpdateMeRequest(string? DisplayName, string? TimeZone);

/// <summary>The journal profile as the app sends and receives it.</summary>
internal sealed record UserResponse(
    string Id,
    string Email,
    string DisplayName,
    string TimeZone,
    string Locale,
    bool EmailVerified,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);

/// <summary>The tokens of a session.</summary>
internal sealed record TokenResponse(
    string AccessToken,
    string RefreshToken,
    DateTimeOffset AccessTokenExpiresAt,
    DateTimeOffset RefreshTokenExpiresAt);

/// <summary>What registration, sign-in and provider sign-in answer with.</summary>
internal sealed record AuthResponse(UserResponse User, TokenResponse Tokens);

/// <summary>An error answer: a code, never prose.</summary>
internal sealed record ErrorResponse(string Code, string? Detail = null);

/// <summary>One sync operation, as the device sends it.</summary>
internal sealed record SyncOperation(string Table, string Op, Guid Id, DateTimeOffset UpdatedAt, JsonObject? Data);

/// <summary>What a sync batch carries.</summary>
internal sealed record SyncBatchRequest(IReadOnlyList<SyncOperation> Operations);

/// <summary>One row, as the server answers with it.</summary>
internal sealed record SyncRow(string Table, string Op, Guid Id, DateTimeOffset UpdatedAt, long SyncSeq, JsonObject? Data);

/// <summary>One operation the server could not apply.</summary>
internal sealed record SyncOperationError(string Table, string Op, Guid Id, string Code);

/// <summary>What a sync batch answers with.</summary>
internal sealed record SyncBatchResponse(long Cursor, IReadOnlyList<SyncRow> Rows, IReadOnlyList<SyncOperationError> Errors);

/// <summary>What a delta pull answers with.</summary>
internal sealed record SyncPullResponse(long Cursor, bool HasMore, IReadOnlyList<SyncRow> Rows);
