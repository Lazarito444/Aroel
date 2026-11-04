namespace Aroel.Core.Paging;

/// <summary>
/// One bounded page of results plus paging metadata.
/// </summary>
/// <typeparam name="T">The type of the items in the page.</typeparam>
public sealed class DataPage<T>
{
    /// <summary>
    /// Creates the page number <paramref name="page"/> of pages of <paramref name="pageSize"/> items,
    /// within a result set of <paramref name="totalCount"/> items.
    /// </summary>
    /// <param name="items">The items of this page; may be empty.</param>
    /// <param name="totalCount">The number of items available across all pages, before slicing.</param>
    /// <param name="page">The 1-based page number of this page.</param>
    /// <param name="pageSize">The number of items each page carries; the last page may be shorter.</param>
    public DataPage(IReadOnlyList<T> items, int totalCount, int page, int pageSize)
    {
        ArgumentNullException.ThrowIfNull(items);

        if (totalCount < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(totalCount), totalCount, "Total count cannot be negative.");
        }

        if (page < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(page), page, "Page number must be positive.");
        }

        if (pageSize < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(pageSize), pageSize, "Page size must be positive.");
        }

        Items = items;
        TotalCount = totalCount;
        Page = page;
        PageSize = pageSize;
    }

    /// <summary>
    /// Gets the items of this page; empty when nothing matched the query.
    /// </summary>
    public IReadOnlyList<T> Items { get; }

    /// <summary>
    /// Gets the number of items available across all pages, before slicing.
    /// </summary>
    public int TotalCount { get; }

    /// <summary>
    /// Gets the 1-based page number of this page.
    /// </summary>
    public int Page { get; }

    /// <summary>
    /// Gets the number of items each page carries.
    /// </summary>
    public int PageSize { get; }

    /// <summary>
    /// Gets the number of pages the result set spans at the current page size.
    /// </summary>
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);

    /// <summary>
    /// Gets a value indicating whether a later page exists.
    /// </summary>
    public bool HasNextPage => Page < TotalPages;

    /// <summary>
    /// Gets a value indicating whether an earlier page exists.
    /// </summary>
    public bool HasPreviousPage => Page > 1;
}
