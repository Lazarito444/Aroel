using Aroel.Core.Domain.Errors;
using Aroel.Core.Results;

namespace Aroel.Core.Domain.ValueObjects;

/// <summary>
/// A validated, normalized email address.
/// </summary>
/// <remarks>
/// The address is stored lowercased and trimmed, so that lookups and uniqueness checks
/// treat <c>Ada@Example.com</c> and <c>ada@example.com</c> as the same address.
/// </remarks>
public readonly record struct EmailAddress
{
    /// <summary>
    /// The longest address the domain accepts, per RFC 5321.
    /// </summary>
    public const int MaxLength = 254;

    private EmailAddress(string value)
    {
        Value = value;
    }

    /// <summary>
    /// Gets the normalized address.
    /// </summary>
    public string Value { get; }

    /// <summary>
    /// Creates an address from text, normalizing it in the process.
    /// </summary>
    /// <param name="value">The address to validate.</param>
    /// <returns>The address, or a failure when the text is not a usable address.</returns>
    public static Result<EmailAddress> Create(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return Result.Failure<EmailAddress>(new AppError(ErrorCodes.EmailEmpty));
        }

        string normalized = value.Trim().ToLowerInvariant();
        int separator = normalized.IndexOf('@', StringComparison.Ordinal);
        bool singleSeparator = separator > 0 && separator == normalized.LastIndexOf('@');

        if (normalized.Length > MaxLength)
        {
            return Result.Failure<EmailAddress>(new AppError(ErrorCodes.EmailTooLong, MaxLength));
        }

        if (!singleSeparator || separator == normalized.Length - 1)
        {
            return Result.Failure<EmailAddress>(new AppError(ErrorCodes.EmailInvalid, value));
        }

        string local = normalized[..separator];
        string domain = normalized[(separator + 1)..];
        bool shaped = !local.Contains(' ', StringComparison.Ordinal)
            && !domain.Contains(' ', StringComparison.Ordinal)
            && domain.Contains('.', StringComparison.Ordinal)
            && !domain.StartsWith('.')
            && !domain.EndsWith('.');

        return shaped
            ? Result.Success(new EmailAddress(normalized))
            : Result.Failure<EmailAddress>(new AppError(ErrorCodes.EmailInvalid, value));
    }

    /// <summary>
    /// Wraps an address without validating it, for hydration from storage.
    /// </summary>
    /// <param name="value">The stored address.</param>
    public static EmailAddress Restore(string value)
    {
        return new EmailAddress(value);
    }

    /// <summary>
    /// Returns the normalized address.
    /// </summary>
    public override string ToString()
    {
        return Value;
    }
}
