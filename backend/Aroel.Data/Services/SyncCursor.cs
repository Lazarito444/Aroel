using Microsoft.EntityFrameworkCore;
using Npgsql;

namespace Aroel.Data.Services;

/// <summary>
/// Assigns the cursor that drives delta sync (§7.3).
/// </summary>
/// <remarks>
/// The sequence lives in the database; an in-memory provider has none, so the tests get a
/// counter of their own. Either way the value is monotonic and never comes from a clock.
/// </remarks>
internal static class SyncCursor
{
    private static long _fallbackCursor = 1_000_000;

    /// <summary>
    /// Takes the next cursor value.
    /// </summary>
    /// <param name="db">The database of the host.</param>
    /// <param name="cancellationToken">The token that cancels the operation.</param>
    /// <returns>The next cursor.</returns>
    public static async Task<long> NextAsync(AroelDbContext db, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(db);

        if (string.Equals(db.Database.ProviderName, "Npgsql.EntityFrameworkCore.PostgreSQL", StringComparison.Ordinal))
        {
            NpgsqlConnection connection = (NpgsqlConnection)db.Database.GetDbConnection();
            bool wasOpen = connection.State == System.Data.ConnectionState.Open;
            if (!wasOpen)
            {
                await connection.OpenAsync(cancellationToken).ConfigureAwait(false);
            }

            await using NpgsqlCommand command = new("SELECT nextval('sync_seq'::regclass)", connection);
            object? result = await command.ExecuteScalarAsync(cancellationToken).ConfigureAwait(false);

            if (!wasOpen)
            {
                await connection.CloseAsync().ConfigureAwait(false);
            }

            return result is not null && long.TryParse(result.ToString(), System.Globalization.CultureInfo.InvariantCulture, out long next)
                ? next
                : Interlocked.Increment(ref _fallbackCursor);
        }

        return Interlocked.Increment(ref _fallbackCursor);
    }
}
