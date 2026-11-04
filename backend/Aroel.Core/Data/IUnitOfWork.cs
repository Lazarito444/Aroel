namespace Aroel.Core.Data;

/// <summary>
/// The boundary of one transaction: repositories stage reads and writes against it, and
/// <see cref="SaveChangesAsync"/> persists everything staged so far as one unit. Nothing
/// persists without it.
/// </summary>
public interface IUnitOfWork : IAsyncDisposable
{
    /// <summary>
    /// Gets the repository over <typeparamref name="T"/>; repositories inside one unit of work
    /// share its pending changes.
    /// </summary>
    /// <typeparam name="T">The aggregate type to access.</typeparam>
    IRepository<T> Repository<T>() where T : class;

    /// <summary>
    /// Persists everything staged in this unit of work as one transaction and reports the number
    /// of affected items. Nothing persists without it.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
