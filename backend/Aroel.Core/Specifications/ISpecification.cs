using System.Linq.Expressions;

namespace Aroel.Core.Specifications;

/// <summary>
/// A description of a list query — filter, sort chain and optional page — that a data source
/// reads and translates. Concrete specifications derive from <see cref="BaseSpecification{T}"/>.
/// </summary>
/// <typeparam name="T">The type of the items the specification queries.</typeparam>
public interface ISpecification<T>
{
    /// <summary>
    /// Gets the combined filter expression, or <see langword="null"/> when no criteria was added.
    /// </summary>
    Expression<Func<T, bool>>? Criteria { get; }

    /// <summary>
    /// Gets the sort keys in application order: the first clause is the primary key, each
    /// subsequent clause breaks ties with it.
    /// </summary>
    IReadOnlyList<OrderClause<T>> Orders { get; }

    /// <summary>
    /// Gets the number of items to skip before this page, or <see langword="null"/> when not paged.
    /// </summary>
    int? Skip { get; }

    /// <summary>
    /// Gets the number of items this page carries, or <see langword="null"/> when not paged.
    /// </summary>
    int? Take { get; }
}

/// <summary>
/// An <see cref="ISpecification{T}"/> that also projects each matched item into its final result
/// shape, applied after filtering, ordering and paging so pagination works on the source items.
/// The filter, sort chain and page come from <see cref="BaseSpecification{T, TResult}"/>.
/// </summary>
/// <typeparam name="T">The type of the items the specification queries.</typeparam>
/// <typeparam name="TResult">The type the selector produces.</typeparam>
public interface ISpecification<T, TResult> : ISpecification<T>
{
    /// <summary>
    /// Gets the selector applied after filtering, ordering and paging.
    /// </summary>
    Expression<Func<T, TResult>> Selector { get; }
}
