namespace Aroel.Core.Results;

/// <summary>
/// Outcome of an operation that either succeeds with a value of <typeparamref name="T"/>
/// or fails with an <see cref="AppError"/>.
/// </summary>
/// <typeparam name="T">The value produced on success.</typeparam>
public class Result<T> : Result
{
    /// <summary>
    /// The produced value when the result succeeded; <see langword="default"/> when it failed.
    /// </summary>
    public T? ValueOrDefault { get; }

    internal Result(T? value, bool isSuccess, AppError? error)
        : base(isSuccess, error)
    {
        ValueOrDefault = value;
    }

    /// <summary>
    /// The produced value. Throws <see cref="InvalidOperationException"/> when the result failed;
    /// check <see cref="Result.IsSuccess"/> first.
    /// </summary>
    public T Value => IsSuccess ? ValueOrDefault! : throw new InvalidOperationException("Cannot access the value of a failed result.");

    /// <summary>
    /// Runs the success branch with the value when the result succeeded and the failure branch
    /// with the error otherwise.
    /// </summary>
    public TOut Match<TOut>(Func<T, TOut> onSuccess, Func<AppError, TOut> onFailure)
    {
        ArgumentNullException.ThrowIfNull(onSuccess);
        ArgumentNullException.ThrowIfNull(onFailure);

        return IsSuccess ? onSuccess(ValueOrDefault!) : onFailure(Error!);
    }

    /// <summary>
    /// Transforms the carried value on success; a failure passes through unchanged.
    /// </summary>
    public Result<TOut> Map<TOut>(Func<T, TOut> onSuccess)
    {
        ArgumentNullException.ThrowIfNull(onSuccess);

        return IsSuccess ? Success(onSuccess(ValueOrDefault!)) : Failure<TOut>(Error!);
    }

    /// <summary>
    /// Chains the next operation on success; a failure passes through unchanged.
    /// </summary>
    public Result<TOut> Bind<TOut>(Func<T, Result<TOut>> onSuccess)
    {
        ArgumentNullException.ThrowIfNull(onSuccess);

        return IsSuccess ? onSuccess(ValueOrDefault!) : Failure<TOut>(Error!);
    }
}
