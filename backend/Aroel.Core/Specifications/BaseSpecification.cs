using System.Linq.Expressions;

namespace Aroel.Core.Specifications;

/// <summary>
/// Base builder for <see cref="ISpecification{T}"/>: protected methods accumulate the criteria,
/// the sort chain and the page while the specification object exposes the resulting state.
/// </summary>
/// <typeparam name="T">The type of the items the specification queries.</typeparam>
public abstract class BaseSpecification<T> : ISpecification<T>
{
    private readonly List<OrderClause<T>> _orders = [];

    /// <summary>
    /// Gets the combined filter expression, or <see langword="null"/> when no criteria was added.
    /// </summary>
    public Expression<Func<T, bool>>? Criteria { get; private set; }

    /// <summary>
    /// Gets the sort keys in application order: the first clause is the primary key, each
    /// subsequent clause breaks ties with it.
    /// </summary>
    public IReadOnlyList<OrderClause<T>> Orders => _orders;

    /// <summary>
    /// Gets the number of items to skip before this page, or <see langword="null"/> when not paged.
    /// </summary>
    public int? Skip { get; private set; }

    /// <summary>
    /// Gets the number of items this page carries, or <see langword="null"/> when not paged.
    /// </summary>
    public int? Take { get; private set; }

    /// <summary>
    /// Adds a filter: the query must satisfy both every criterion added before and <paramref name="criteria"/>.
    /// </summary>
    protected void AddCriteria(Expression<Func<T, bool>> criteria)
    {
        ArgumentNullException.ThrowIfNull(criteria);

        Criteria = Criteria is null ? criteria : AndAlso(Criteria, criteria);
    }

    /// <summary>
    /// Starts the sort chain with an ascending key. Any previous chain is replaced, since a second
    /// primary key leaves earlier keys meaningless.
    /// </summary>
    protected void OrderBy<TKey>(Expression<Func<T, TKey>> keySelector)
    {
        ArgumentNullException.ThrowIfNull(keySelector);

        _orders.Clear();
        _orders.Add(new OrderClause<T>(keySelector, false));
    }

    /// <summary>
    /// Starts the sort chain with a descending key. Any previous chain is replaced, since a second
    /// primary key leaves earlier keys meaningless.
    /// </summary>
    protected void OrderByDescending<TKey>(Expression<Func<T, TKey>> keySelector)
    {
        ArgumentNullException.ThrowIfNull(keySelector);

        _orders.Clear();
        _orders.Add(new OrderClause<T>(keySelector, true));
    }

    /// <summary>
    /// Appends an ascending tie-breaker key after the existing chain.
    /// </summary>
    protected void ThenBy<TKey>(Expression<Func<T, TKey>> keySelector)
    {
        ThenWithOrder(keySelector, false, nameof(ThenBy));
    }

    /// <summary>
    /// Appends a descending tie-breaker key after the existing chain.
    /// </summary>
    protected void ThenByDescending<TKey>(Expression<Func<T, TKey>> keySelector)
    {
        ThenWithOrder(keySelector, true, nameof(ThenByDescending));
    }

    /// <summary>
    /// Restricts the query to one page: page 1 skips nothing, each later page skips one page of items.
    /// </summary>
    /// <param name="page">The 1-based page number.</param>
    /// <param name="pageSize">The number of items each page carries.</param>
    protected void Page(int page, int pageSize)
    {
        ArgumentOutOfRangeException.ThrowIfLessThan(page, 1);
        ArgumentOutOfRangeException.ThrowIfLessThan(pageSize, 1);

        long skip = (long)(page - 1) * pageSize;
        Skip = skip > int.MaxValue
            ? throw new ArgumentOutOfRangeException(nameof(page), page, "The computed offset exceeds the maximum supported item count.")
            : (int)skip;
        Take = pageSize;
    }

    private void ThenWithOrder<TKey>(Expression<Func<T, TKey>> keySelector, bool descending, string methodName)
    {
        ArgumentNullException.ThrowIfNull(keySelector);

        _ = _orders.Count == 0
            ? throw new InvalidOperationException($"{methodName} requires a preceding call to OrderBy or OrderByDescending.")
            : true;

        _orders.Add(new OrderClause<T>(keySelector, descending));
    }

    /// <summary>
    /// Combines both expressions under parameters of a single lambda, so criteria built with
    /// independent parameters compose into one predicate the query provider can translate.
    /// </summary>
    private static Expression<Func<T, bool>> AndAlso(Expression<Func<T, bool>> left, Expression<Func<T, bool>> right)
    {
        ParameterExpression parameter = Expression.Parameter(typeof(T));
        ParameterExpression leftParameter = left.Parameters[0];
        ParameterExpression rightParameter = right.Parameters[0];
        Expression leftBody = new ParameterReplacer(leftParameter, parameter).Visit(left.Body);
        Expression rightBody = new ParameterReplacer(rightParameter, parameter).Visit(right.Body);
        return Expression.Lambda<Func<T, bool>>(Expression.AndAlso(leftBody, rightBody), parameter);
    }

    private sealed class ParameterReplacer : ExpressionVisitor
    {
        private readonly ParameterExpression _from;
        private readonly ParameterExpression _to;

        public ParameterReplacer(ParameterExpression from, ParameterExpression to)
        {
            _from = from;
            _to = to;
        }

        protected override Expression VisitParameter(ParameterExpression node)
        {
            return node == _from ? _to : base.VisitParameter(node);
        }
    }
}

/// <summary>
/// Base builder for <see cref="ISpecification{T, TResult}"/>: all <see cref="BaseSpecification{T}"/>
/// capabilities plus the projection every matched item passes through.
/// </summary>
/// <typeparam name="T">The type of the items the specification queries.</typeparam>
/// <typeparam name="TResult">The type the selector produces.</typeparam>
public abstract class BaseSpecification<T, TResult> : BaseSpecification<T>, ISpecification<T, TResult>
{
    /// <summary>
    /// Creates a specification whose results are the projection of each matched item.
    /// </summary>
    /// <param name="selector">The expression applied after filtering, ordering and paging.</param>
    protected BaseSpecification(Expression<Func<T, TResult>> selector)
    {
        ArgumentNullException.ThrowIfNull(selector);

        Selector = selector;
    }

    /// <summary>
    /// Gets the selector applied after filtering, ordering and paging.
    /// </summary>
    public Expression<Func<T, TResult>> Selector { get; }
}
