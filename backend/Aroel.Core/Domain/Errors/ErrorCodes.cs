namespace Aroel.Core.Domain.Errors;

/// <summary>
/// The stable error codes the domain reports.
/// </summary>
/// <remarks>
/// A code is the resource key the API localizer resolves into a message, so the domain
/// never carries user-facing text. Codes are part of the contract: renaming one breaks
/// every translation and every client that switches on it.
/// </remarks>
public static class ErrorCodes
{
    /// <summary>An identifier was missing.</summary>
    public const string IdentifierEmpty = "identifier.empty";

    /// <summary>A rating fell outside the 0..10 half point scale.</summary>
    public const string RatingOutOfRange = "rating.out_of_range";

    /// <summary>A rating did not land on a half step.</summary>
    public const string RatingNotHalfStep = "rating.not_half_step";

    /// <summary>An email address was empty.</summary>
    public const string EmailEmpty = "email.empty";

    /// <summary>An email address was not usable.</summary>
    public const string EmailInvalid = "email.invalid";

    /// <summary>An email address was longer than the domain accepts.</summary>
    public const string EmailTooLong = "email.too_long";

    /// <summary>A display name was empty.</summary>
    public const string DisplayNameEmpty = "user.display_name_empty";

    /// <summary>A display name was longer than the domain accepts.</summary>
    public const string DisplayNameTooLong = "user.display_name_too_long";

    /// <summary>A timezone was not a known timezone identifier.</summary>
    public const string TimeZoneInvalid = "user.timezone_invalid";

    /// <summary>A locale was not a known culture name.</summary>
    public const string LocaleInvalid = "user.locale_invalid";

    /// <summary>The one-line note of a day was longer than the domain accepts.</summary>
    public const string DayNoteTooLong = "day.note_too_long";

    /// <summary>A gratitude position fell outside the one to three range.</summary>
    public const string GratitudePositionOutOfRange = "gratitude.position_out_of_range";

    /// <summary>A gratitude line was empty.</summary>
    public const string GratitudeTextEmpty = "gratitude.text_empty";

    /// <summary>A gratitude line was longer than the domain accepts.</summary>
    public const string GratitudeTextTooLong = "gratitude.text_too_long";

    /// <summary>A day already carried the maximum number of tags.</summary>
    public const string DayTagLimitExceeded = "day.tag_limit_exceeded";

    /// <summary>A day already carried the same tag.</summary>
    public const string DayTagDuplicate = "day.tag_duplicate";

    /// <summary>A tone was offered to a day it does not belong to.</summary>
    public const string DaySentimentMismatch = "day.sentiment_mismatch";

    /// <summary>A tag label was empty.</summary>
    public const string TagLabelEmpty = "tag.label_empty";

    /// <summary>A tag label was longer than the domain accepts.</summary>
    public const string TagLabelTooLong = "tag.label_too_long";

    /// <summary>A tag colour was not a hex colour.</summary>
    public const string TagColorInvalid = "tag.color_invalid";

    /// <summary>An emotion slug was empty.</summary>
    public const string EmotionSlugEmpty = "emotion.slug_empty";

    /// <summary>An emotion slug was longer than the domain accepts.</summary>
    public const string EmotionSlugTooLong = "emotion.slug_too_long";

    /// <summary>An emotion label was empty.</summary>
    public const string EmotionLabelEmpty = "emotion.label_empty";

    /// <summary>An emotion label was longer than the domain accepts.</summary>
    public const string EmotionLabelTooLong = "emotion.label_too_long";

    /// <summary>An emotion valence bias fell outside the minus one to one range.</summary>
    public const string EmotionValenceOutOfRange = "emotion.valence_out_of_range";

    /// <summary>An emotion family was not one the taxonomy knows.</summary>
    public const string EmotionFamilyInvalid = "emotion.family_invalid";

    /// <summary>A sentiment source was not one the domain knows.</summary>
    public const string SentimentSourceInvalid = "sentiment.source_invalid";

    /// <summary>An entry title was longer than the domain accepts.</summary>
    public const string EntryTitleTooLong = "entry.title_too_long";

    /// <summary>An entry kind was not one the domain knows.</summary>
    public const string EntryKindInvalid = "entry.kind_invalid";

    /// <summary>A device platform was not one the domain knows.</summary>
    public const string DevicePlatformInvalid = "device.platform_invalid";

    /// <summary>An app version was empty.</summary>
    public const string AppVersionEmpty = "device.app_version_empty";

    /// <summary>A refresh token hash was empty.</summary>
    public const string RefreshTokenHashEmpty = "refresh_token.hash_empty";

    /// <summary>A refresh token had already expired.</summary>
    public const string RefreshTokenExpired = "refresh_token.expired";

    /// <summary>A refresh token had already been rotated, which means it was replayed.</summary>
    public const string RefreshTokenReused = "refresh_token.reused";

    /// <summary>The account could not be created.</summary>
    public const string AccountCreationFailed = "account.creation_failed";
}
