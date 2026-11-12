using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Enums;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Users;

/// <summary>
/// A device the user signs in from.
/// </summary>
/// <remarks>
/// A device is how the server tells one installation from another: it binds a refresh
/// token to the phone it was issued to, and it is what a user signs out of.
/// </remarks>
public sealed class CoreDevice : Entity
{
    /// <summary>
    /// The longest app version string the domain accepts.
    /// </summary>
    public const int MaxAppVersionLength = 40;

    private CoreDevice()
    {
    }

    private CoreDevice(Guid id, Guid userId, DevicePlatform platform, string appVersion, DateTimeOffset now)
        : base(id, now)
    {
        UserId = userId;
        Platform = platform;
        AppVersion = appVersion;
        LastSeenAt = now;
    }

    /// <summary>
    /// Gets the user the device belongs to.
    /// </summary>
    public Guid UserId { get; private set; }

    /// <summary>
    /// Gets the platform the app runs on.
    /// </summary>
    public DevicePlatform Platform { get; private set; }

    /// <summary>
    /// Gets the push token of the device, when it has one.
    /// </summary>
    public string? PushToken { get; private set; }

    /// <summary>
    /// Gets the version of the app the device last ran.
    /// </summary>
    public string AppVersion { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the moment the device was last seen, in UTC.
    /// </summary>
    public DateTimeOffset LastSeenAt { get; private set; }

    /// <summary>
    /// Creates a device.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="userId">The user the device belongs to.</param>
    /// <param name="platform">The platform the app runs on.</param>
    /// <param name="appVersion">The version of the app the device runs.</param>
    /// <param name="now">The moment the device was registered, in UTC.</param>
    /// <returns>The device, or a failure when a field does not hold up.</returns>
    public static Result<CoreDevice> Create(Guid id, Guid userId, DevicePlatform platform, string appVersion, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(appVersion);

        return id == Guid.Empty
            ? Result.Failure<CoreDevice>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateAppVersion(appVersion).Bind(version =>
                Enum.IsDefined(platform)
                    ? Result.Success(new CoreDevice(id, userId, platform, version, now))
                    : Result.Failure<CoreDevice>(new AppError(ErrorCodes.DevicePlatformInvalid, platform)));
    }

    /// <summary>
    /// Records that the device was seen, and refreshes what the server knows about it.
    /// </summary>
    /// <param name="pushToken">The push token of the device, when it has one.</param>
    /// <param name="appVersion">The version of the app the device now runs.</param>
    /// <param name="now">The moment the device was seen, in UTC.</param>
    /// <returns>The device, or a failure when the app version does not hold up.</returns>
    public Result<CoreDevice> RecordSeen(string? pushToken, string appVersion, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(appVersion);

        return ValidateAppVersion(appVersion).Map(version =>
        {
            PushToken = string.IsNullOrWhiteSpace(pushToken) ? null : pushToken.Trim();
            AppVersion = version;
            LastSeenAt = now;
            Touch(now);
            return this;
        });
    }

    private static Result<string> ValidateAppVersion(string appVersion)
    {
        if (string.IsNullOrWhiteSpace(appVersion))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.AppVersionEmpty));
        }

        string trimmed = appVersion.Trim();

        return trimmed.Length > MaxAppVersionLength
            ? Result.Failure<string>(new AppError(ErrorCodes.AppVersionEmpty, MaxAppVersionLength))
            : Result.Success(trimmed);
    }
}
