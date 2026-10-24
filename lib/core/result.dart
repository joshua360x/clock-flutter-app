/// Outcome of an operation that can fail in an expected way (network calls,
/// parsing). Exhaustive `switch` over [Ok] / [Err] keeps failure handling
/// visible at the call site instead of hidden in exceptions.
sealed class Result<T, E> {
  const Result();
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
