using Aroel.Application.Email;

namespace Aroel.Api.Auth;

/// <summary>
/// Sends the confirmation mail to the log of the host.
/// </summary>
/// <remarks>
/// The development host has no mail server; the link lands in the log, where a person can
/// pick it up. A deployment wires its own sender, and the link lands in an inbox instead.
/// </remarks>
internal sealed class LogEmailSender : IEmailSender
{
    private static readonly Action<ILogger, string, string, Exception?> _confirmationLog =
        LoggerMessage.Define<string, string>(
            LogLevel.Information,
            new EventId(1, "Confirmation"),
            "Confirmation for {Email}: {ConfirmationUrl}");

    private readonly ILogger<LogEmailSender> _logger;

    /// <summary>
    /// Initialises the sender.
    /// </summary>
    /// <param name="logger">The log of the host.</param>
    public LogEmailSender(ILogger<LogEmailSender> logger)
    {
        ArgumentNullException.ThrowIfNull(logger);
        _logger = logger;
    }

    /// <inheritdoc />
    public Task SendConfirmationAsync(string email, string confirmationUrl, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(email);
        ArgumentNullException.ThrowIfNull(confirmationUrl);

        _confirmationLog(_logger, email, confirmationUrl, null);
        return Task.CompletedTask;
    }
}
