namespace Aroel.Core.Results;

/// <summary>
/// Describes why an operation failed. <see cref="Code"/> is the stable, machine-readable
/// identifier used to resolve the localized message at the API level; <see cref="Args"/>
/// are its format arguments, so failures stay localizable end to end.
/// </summary>
public sealed record AppError
{
    /// <summary>
    /// Creates an error with the given <paramref name="code"/> and <paramref name="args"/>.
    /// </summary>
    /// <param name="code">Stable, machine-readable identifier used by the API localizer as the resource key.</param>
    /// <param name="args">Format arguments for placeholders such as <c>{0}</c> in the localized string.</param>
    public AppError(string code, params object?[] args)
    {
        ArgumentNullException.ThrowIfNull(code);

        Code = code;
        Args = args is null ? [] : args;
    }

    /// <summary>
    /// Gets the stable error code, matching the key of the localized string at the API level.
    /// </summary>
    public string Code { get; }

    /// <summary>
    /// Gets the format arguments for the placeholders in the resource string.
    /// </summary>
    public object?[] Args { get; }
}
