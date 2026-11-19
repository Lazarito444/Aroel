namespace Aroel.Application.Email;

/// <summary>
/// Sends the mail a person needs to confirm they own an address.
/// </summary>
/// <remarks>
/// The development host logs the message instead of sending it; a deployment wires its
/// own sender. Verification is required before the first sync, and never before writing.
/// </remarks>
public interface IEmailSender
{
    /// <summary>
    /// Sends the confirmation of an address to an account.
    /// </summary>
    /// <param name="email">The address of the account.</param>
    /// <param name="confirmationUrl">The link that confirms the address.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    Task SendConfirmationAsync(string email, string confirmationUrl, CancellationToken cancellationToken = default);
}
