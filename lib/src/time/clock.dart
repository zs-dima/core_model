import 'package:meta/meta.dart';

/// The source of the current instant for facts an application records or acts on: an expiry, a
/// scheduled reminder, the date a record is filed under, the time stamped on a step.
///
/// An injected dependency rather than a static call, so a caller can be handed a clock that reports
/// an instant the calendar has not reached. Those states — a DST edge, the next morning, a date
/// past a deadline — are otherwise unreachable, because an application cannot set the system clock.
///
/// Presentation timing does not belong here: a tap window, a coalescing interval, a `2 h ago` label
/// are about the frame in front of the user, and a clock that can be moved would carry that
/// movement into the interface's own reflexes.
abstract interface class Clock {
  /// The current instant, in UTC.
  ///
  /// A caller that needs a wall clock converts to the zone it means, not to the host's, which
  /// travels with the device.
  DateTime now();
}

/// A [Clock] reading the host's system clock: the implementation to compose in production, and the
/// only `DateTime.now()` behind the interface.
@immutable
final class SystemClock implements Clock {
  /// Creates a [SystemClock].
  const SystemClock();

  @override
  DateTime now() => .now().toUtc();
}
