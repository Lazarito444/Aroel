/// The source of the current moment.
///
/// Time is injected so that expiry, lockouts and rotations can be tested without waiting.
abstract interface class Clock {
  /// The current moment, in UTC.
  DateTime nowUtc();
}

/// A clock that reads the device.
final class SystemClock implements Clock {
  /// Creates a clock that reads the device.
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// A clock that stands still, for tests.
final class FixedClock implements Clock {
  /// Creates a clock frozen at [instant].
  FixedClock(this.instant);

  /// The moment the clock stands at.
  DateTime instant;

  @override
  DateTime nowUtc() => instant;
}
