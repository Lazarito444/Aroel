import 'package:aroel/core/app_error.dart';

/// The outcome of an operation that can fail with a reason the caller has to handle.
///
/// The domain's own `Result` (in `Aroel.Core`) is the model this mirrors: a rule that
/// cannot be met is a value, never an exception the caller can forget.
sealed class Result<T> {
  const Result();

  /// A successful outcome carrying [value].
  const factory Result.success(T value) = Success<T>;

  /// A failed outcome carrying [error].
  const factory Result.failure(AppError error) = Failure<T>;

  /// Whether the operation succeeded.
  bool get isSuccess => this is Success<T>;

  /// Whether the operation failed.
  bool get isFailure => this is Failure<T>;

  /// The value of a successful outcome, or `null` when the operation failed.
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  /// The reason of a failed outcome, or `null` when the operation succeeded.
  AppError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  /// Turns the outcome into another type, keeping the failure as it is.
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(AppError error) onFailure,
  ) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failure<T>(:final error) => onFailure(error),
  };
}

/// A successful outcome.
final class Success<T> extends Result<T> {
  /// Creates a successful outcome.
  const Success(this.value);

  /// The value the operation produced.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => Object.hash(Success, value);

  @override
  String toString() => 'Success($value)';
}

/// A failed outcome.
final class Failure<T> extends Result<T> {
  /// Creates a failed outcome.
  const Failure(this.error);

  /// The reason the operation failed.
  final AppError error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure<T> && other.error.code == error.code);

  @override
  int get hashCode => Object.hash(Failure, error.code);

  @override
  String toString() => 'Failure(${error.code})';
}
