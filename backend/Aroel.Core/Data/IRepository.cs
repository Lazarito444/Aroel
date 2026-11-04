using Aroel.Core.Paging;
using Aroel.Core.Specifications;

namespace Aroel.Core.Data;

/// <summary>
/// A repository over one aggregate: reads specifications into items or pages and stages writes;
/// staged writes persist only when <see cref="IUnitOfWork.SaveChangesAsync"/> runs on the owning
/// unit of work. Offline-first: every interaction goes through this in-process surface, the
/// network is a separate sync process.
/// </summary>
/// <typeparam name="T">The aggregate type the repository manages.</typeparam>
public interface IRepository<T> where T : class
{
    /// <summary>
    /// Reads the first item matching <paramref name="specification"/>, or <see langword="null"/>
    /// when none matches.
    /// </summary>
    Task<T?> FirstOrDefaultAsync(ISpecification<T> specification, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads every item matching <paramref name="specification"/>; the specification should page
    /// itself when the caller cannot bound the result.
    /// </summary>
    Task<List<T>> ListAsync(ISpecification<T> specification, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads every item matching <paramref name="specification"/>, projected through its selector.
    /// </summary>
    /// <typeparam name="TResult">The type the specification's selector produces.</typeparam>
    Task<List<TResult>> ListAsync<TResult>(ISpecification<T, TResult> specification, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads the items of the page in <paramref name="specification"/> plus the total count of
    /// matching items. The specification must be paged; paged specs always read from
    /// <see cref="ISpecification{T}.Skip"/> and <see cref="ISpecification{T}.Take"/>.
    /// </summary>
    Task<DataPage<T>> ListPagedAsync(ISpecification<T> specification, CancellationToken cancellationToken = default);

    /// <summary>
    /// Reads the items of the page in <paramref name="specification"/>, projected through its
    /// selector, plus the total count of matching items. The specification must be paged.
    /// </summary>
    /// <typeparam name="TResult">The type the specification's selector produces.</typeparam>
    Task<DataPage<TResult>> ListPagedAsync<TResult>(ISpecification<T, TResult> specification, CancellationToken cancellationToken = default);

    /// <summary>
    /// Counts the items matching <paramref name="specification"/>, ignoring its sort chain and
    /// page; without a specification, every item.
    /// </summary>
    Task<int> CountAsync(ISpecification<T>? specification = null, CancellationToken cancellationToken = default);

    /// <summary>
    /// Stages <paramref name="entity"/> for insertion on the next <see cref="IUnitOfWork.SaveChangesAsync"/>.
    /// The entity id is client-generated and must not conflict with staged or stored ids.
    /// </summary>
    void Add(T entity);

    /// <summary>
    /// Stages <paramref name="entity"/> for its tracked updates to persist on the next
    /// <see cref="IUnitOfWork.SaveChangesAsync"/>; the entity must already be tracked.
    /// </summary>
    void Update(T entity);

    /// <summary>
    /// Stages <paramref name="entity"/> for deletion on the next <see cref="IUnitOfWork.SaveChangesAsync"/>.
    /// </summary>
    void Remove(T entity);

    /// <summary>
    /// Stages every item of <paramref name="entities"/> for insertion on the next
    /// <see cref="IUnitOfWork.SaveChangesAsync"/>. None of the ids may conflict with staged or
    /// stored ids: client-generated ids are individually generated, never renumbered.
    /// </summary>
    void AddRange(IEnumerable<T> entities);

    /// <summary>
    /// Stages every item of <paramref name="entities"/> for its tracked updates to persist on the
    /// next <see cref="IUnitOfWork.SaveChangesAsync"/>; each item must already be tracked.
    /// </summary>
    void UpdateRange(IEnumerable<T> entities);

    /// <summary>
    /// Stages every item of <paramref name="entities"/> for deletion on the next
    /// <see cref="IUnitOfWork.SaveChangesAsync"/>.
    /// </summary>
    void RemoveRange(IEnumerable<T> entities);
}
