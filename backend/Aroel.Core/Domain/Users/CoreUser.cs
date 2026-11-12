using System.Globalization;
using Aroel.Core.Domain.Common;
using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.Users;

/// <summary>
/// The person the journal belongs to.
/// </summary>
/// <remarks>
/// The account is optional. A client that has never signed up still owns a user, because
/// it generates the identifier itself on first launch and writes every row under it. Those
/// rows never leave the device until the user asks for an account, at which point the same
/// identifier is presented to the server and adopted, so no row is ever re-keyed.
/// <para>
/// The email address and the credentials belong to the identity store, not here: they are
/// an authentication concern, and keeping them out of the domain lets the account be
/// created, rotated and deleted without touching the journal.
/// </para>
/// </remarks>
public sealed class CoreUser : Entity
{
    /// <summary>
    /// The longest display name the domain accepts.
    /// </summary>
    public const int MaxDisplayNameLength = 120;

    /// <summary>
    /// The longest culture name the domain accepts.
    /// </summary>
    public const int MaxLocaleLength = 35;

    private CoreUser()
    {
    }

    private CoreUser(Guid id, string displayName, string timeZone, string locale, DateTimeOffset now)
        : base(id, now)
    {
        DisplayName = displayName;
        TimeZone = timeZone;
        Locale = locale;
    }

    /// <summary>
    /// Gets the display name the user sees.
    /// </summary>
    public string DisplayName { get; private set; } = string.Empty;

    /// <summary>
    /// Gets the identifier of the timezone the user's days are counted in.
    /// </summary>
    public string TimeZone { get; private set; } = "UTC";

    /// <summary>
    /// Gets the culture the user's interface and dates are rendered in.
    /// </summary>
    public string Locale { get; private set; } = "en";

    /// <summary>
    /// Creates a user.
    /// </summary>
    /// <param name="id">The client-generated identifier, which must not be empty.</param>
    /// <param name="displayName">The name shown in the app; trimmed before storing.</param>
    /// <param name="timeZone">The timezone identifier, such as <c>Europe/Madrid</c>.</param>
    /// <param name="locale">The culture name, such as <c>en</c> or <c>es-ES</c>.</param>
    /// <param name="now">The moment the user was created, in UTC.</param>
    /// <returns>The user, or a failure when a field does not hold up.</returns>
    public static Result<CoreUser> Create(Guid id, string displayName, string timeZone, string locale, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(displayName);
        ArgumentNullException.ThrowIfNull(timeZone);
        ArgumentNullException.ThrowIfNull(locale);

        return id == Guid.Empty
            ? Result.Failure<CoreUser>(new AppError(ErrorCodes.IdentifierEmpty, id.ToString()))
            : ValidateDisplayName(displayName).Bind(name =>
                ValidateTimeZone(timeZone).Bind(zone =>
                    ValidateLocale(locale).Map(culture =>
                        new CoreUser(id, name, zone, culture, now))));
    }

    /// <summary>
    /// Changes the display name.
    /// </summary>
    /// <param name="displayName">The new name; trimmed before storing.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The user, or a failure when the name does not hold up.</returns>
    public Result<CoreUser> ChangeDisplayName(string displayName, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(displayName);

        return ValidateDisplayName(displayName).Map(name =>
        {
            DisplayName = name;
            Touch(now);
            return this;
        });
    }

    /// <summary>
    /// Changes the timezone the user's days are counted in.
    /// </summary>
    /// <param name="timeZone">The new timezone identifier.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The user, or a failure when the timezone is unknown.</returns>
    public Result<CoreUser> ChangeTimeZone(string timeZone, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(timeZone);

        return ValidateTimeZone(timeZone).Map(zone =>
        {
            TimeZone = zone;
            Touch(now);
            return this;
        });
    }

    /// <summary>
    /// Changes the culture the interface is rendered in.
    /// </summary>
    /// <param name="locale">The new culture name.</param>
    /// <param name="now">The moment of the change, in UTC.</param>
    /// <returns>The user, or a failure when the culture is unknown.</returns>
    public Result<CoreUser> ChangeLocale(string locale, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(locale);

        return ValidateLocale(locale).Map(culture =>
        {
            Locale = culture;
            Touch(now);
            return this;
        });
    }

    private static Result<string> ValidateDisplayName(string displayName)
    {
        string trimmed = displayName.Trim();

        return trimmed.Length == 0
            ? Result.Failure<string>(new AppError(ErrorCodes.DisplayNameEmpty))
            : trimmed.Length > MaxDisplayNameLength
                ? Result.Failure<string>(new AppError(ErrorCodes.DisplayNameTooLong, MaxDisplayNameLength))
                : Result.Success(trimmed);
    }

    private static Result<string> ValidateTimeZone(string timeZone)
    {
        if (string.IsNullOrWhiteSpace(timeZone))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.TimeZoneInvalid, timeZone));
        }

        string trimmed = timeZone.Trim();

        try
        {
            _ = TimeZoneInfo.FindSystemTimeZoneById(trimmed);
        }
        catch (TimeZoneNotFoundException)
        {
            return Result.Failure<string>(new AppError(ErrorCodes.TimeZoneInvalid, trimmed));
        }
        catch (InvalidTimeZoneException)
        {
            return Result.Failure<string>(new AppError(ErrorCodes.TimeZoneInvalid, trimmed));
        }

        return Result.Success(trimmed);
    }

    private static Result<string> ValidateLocale(string locale)
    {
        if (string.IsNullOrWhiteSpace(locale))
        {
            return Result.Failure<string>(new AppError(ErrorCodes.LocaleInvalid, locale));
        }

        string trimmed = locale.Trim();
        bool known;

        try
        {
            _ = CultureInfo.GetCultureInfo(trimmed);
            known = true;
        }
        catch (CultureNotFoundException)
        {
            known = false;
        }

        return known && trimmed.Length <= MaxLocaleLength
            ? Result.Success(trimmed)
            : Result.Failure<string>(new AppError(ErrorCodes.LocaleInvalid, trimmed));
    }
}
