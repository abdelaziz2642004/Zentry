/// Generic result pattern for consistent error handling across the app
abstract class AppResult<T> {
  const AppResult();

  /// Create a successful result
  factory AppResult.success(T data) = AppSuccess<T>;

  /// Create a failure result
  factory AppResult.failure(String error, [Exception? exception]) =
      AppFailure<T>;

  /// Check if the result is successful
  bool get isSuccess => this is AppSuccess<T>;

  /// Check if the result is a failure
  bool get isFailure => this is AppFailure<T>;

  /// Get the data if successful, null otherwise
  T? get data => isSuccess ? (this as AppSuccess<T>).data : null;

  /// Get the error message if failed, null otherwise
  String? get error => isFailure ? (this as AppFailure<T>).error : null;

  /// Get the exception if failed, null otherwise
  Exception? get exception =>
      isFailure ? (this as AppFailure<T>).exception : null;

  /// Execute a function if successful, return original result if failed
  AppResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return AppResult.success(mapper((this as AppSuccess<T>).data));
      } on Exception catch (e) {
        e;
        return AppResult.failure('Mapping failed: $e');
      }
    }
    return AppResult.failure(
      (this as AppFailure<T>).error,
      (this as AppFailure<T>).exception,
    );
  }

  /// Execute a function and return its result if this is successful
  AppResult<R> flatMap<R>(AppResult<R> Function(T data) mapper) {
    if (isSuccess) {
      return mapper((this as AppSuccess<T>).data);
    }
    return AppResult.failure(
      (this as AppFailure<T>).error,
      (this as AppFailure<T>).exception,
    );
  }

  /// Execute different functions based on success/failure
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String error, Exception? exception) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess((this as AppSuccess<T>).data);
    } else {
      final failure = this as AppFailure<T>;
      return onFailure(failure.error, failure.exception);
    }
  }
}

/// Successful result
class AppSuccess<T> extends AppResult<T> {
  @override
  final T data;
  const AppSuccess(this.data);

  @override
  String toString() => 'AppSuccess($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppSuccess<T> && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failed result
class AppFailure<T> extends AppResult<T> {
  @override
  final String error;
  @override
  final Exception? exception;
  const AppFailure(this.error, [this.exception]);

  @override
  String toString() =>
      'AppFailure($error${exception != null ? ', $exception' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure<T> &&
          error == other.error &&
          exception == other.exception;

  @override
  int get hashCode => error.hashCode ^ exception.hashCode;
}
