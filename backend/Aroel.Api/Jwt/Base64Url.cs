using System.Text;

namespace Aroel.Api.Jwt;

/// <summary>
/// Base64url without padding, as JSON web tokens carry it.
/// </summary>
internal static class Base64Url
{
    /// <summary>Encodes bytes as base64url without padding.</summary>
    public static string EncodeToString(byte[] bytes)
    {
        ArgumentNullException.ThrowIfNull(bytes);
        return Convert.ToBase64String(bytes).Replace('+', '-').Replace('/', '_').TrimEnd('=');
    }

    /// <summary>Decodes base64url, with or without padding.</summary>
    public static byte[] DecodeFromString(string value)
    {
        ArgumentNullException.ThrowIfNull(value);

        string base64 = value.Replace('-', '+').Replace('_', '/');
        int padding = base64.Length % 4;
        if (padding != 0)
        {
            base64 = base64.PadRight(base64.Length + (4 - padding), '=');
        }

        return Convert.FromBase64String(base64);
    }

    /// <summary>Decodes base64url to a string, with or without padding.</summary>
    public static string DecodeToString(string value)
    {
        ArgumentNullException.ThrowIfNull(value);
        return Encoding.UTF8.GetString(DecodeFromString(value));
    }
}
