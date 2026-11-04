using System.Linq.Expressions;

namespace Aroel.Core.Specifications;

/// <summary>
/// A single sort step of an <see cref="ISpecification{T}"/>: a key selector plus its direction.
/// </summary>
/// <typeparam name="T">The type of the items being ordered.</typeparam>
/// <param name="KeySelector">The sort key selector.</param>
/// <param name="Descending"><see langword="true"/> when the key orders descending.</param>
public sealed record OrderClause<T>(LambdaExpression KeySelector, bool Descending);
