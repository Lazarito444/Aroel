namespace Aroel.Core.Results;

/// <summary>
/// Outcome of an operation that either succeeds or fails with an <see cref="AppError"/>
/// and carries no value. <see cref="Result{T}"/> extends this to also carry a value.
/// </summary>
public class Result
{
    private protected Result(bool isSuccess, AppError? error)
    {
        if (isSuccess)
        {
            if (error is not null)
            {
                throw new ArgumentException("A successful result cannot carry an error.", nameof(error));
            }
        }
        else if (error is null)
        {
            throw new ArgumentException("A failed result must carry an error.", nameof(error));
        }

        IsSuccess = isSuccess;
        Error = error;
    }

    /// <summary>
    /// Gets a value indicating whether the operation succeeded.
    /// </summary>
    public bool IsSuccess { get; }

    /// <summary>
    /// Gets a value indicating whether the operation failed.
    /// </summary>
    public bool IsFailure => !IsSuccess;

    /// <summary>
    /// The error when the result failed; <see langword="null"/> when it succeeded.
    /// </summary>
    public AppError? Error { get; }

    /// <summary>
    /// Creates a successful result.
    /// </summary>
    public static Result Success()
    {
        return new Result(isSuccess: true, error: null);
    }

    /// <summary>
    /// Creates a failed result carrying <paramref name="error"/>.
    /// </summary>
    public static Result Failure(AppError error)
    {
        ArgumentNullException.ThrowIfNull(error);

        return new Result(isSuccess: false, error);
    }

    /// <summary>
    /// Creates a successful result carrying <paramref name="value"/>.
    /// </summary>
    public static Result<T> Success<T>(T value)
    {
        return new Result<T>(value, isSuccess: true, error: null);
    }

    /// <summary>
    /// Creates a failed result of type <typeparamref name="T"/> carrying <paramref name="error"/>.
    /// </summary>
    public static Result<T> Failure<T>(AppError error)
    {
        ArgumentNullException.ThrowIfNull(error);

        return new Result<T>(default, isSuccess: false, error);
    }

    /// <summary>
    /// Runs the success branch when the result succeeded and the failure branch otherwise.
    /// </summary>
    public TOut Match<TOut>(Func<TOut> onSuccess, Func<AppError, TOut> onFailure)
    {
        ArgumentNullException.ThrowIfNull(onSuccess);
        ArgumentNullException.ThrowIfNull(onFailure);

        return IsSuccess ? onSuccess() : onFailure(Error!);
    }
}
