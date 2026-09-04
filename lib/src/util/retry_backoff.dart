import 'dart:math' as math;

/// Called before a retry sleeps: the error behind the failed [attempt] and the [delay] chosen.
typedef RetryNotifier = void Function(Object error, int attempt, Duration delay);

/// {@template retry_backoff}
/// Transport-agnostic retry backoff policy for unstable (mobile/cellular) networks.
///
/// Exponential backoff with full jitter, plus two ceilings: [maxDelay] caps each backoff,
/// [maxElapsed] budgets the total time across all attempts.
///
/// Full jitter (`random(0, cap)`) is the recommended default (AWS "Exponential Backoff And
/// Jitter", Google SRE): it spreads retries out so that many clients failing at once, e.g. after
/// a cell outage, do not retry in lockstep and stampede the server as it recovers.
///
/// Server-directed delays (`Retry-After`, gRPC `grpc-retry-pushback-ms`) are already coordinated
/// by the server: use them verbatim (capped at [maxDelay]) instead of [backoff], without jitter.
/// {@endtemplate}
class RetryBackoff {
  /// {@macro retry_backoff}
  const RetryBackoff({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.maxElapsed = const Duration(seconds: 30),
  }) : assert(maxRetries >= 0, 'maxRetries must be non-negative');

  /// Maximum number of retries (additional attempts after the first).
  final int maxRetries;

  /// Backoff unit for the first retry; grows as `baseDelay * 2^attempt`.
  final Duration baseDelay;

  /// Per-attempt ceiling: the exponential term is clamped to this before jitter.
  final Duration maxDelay;

  /// Total budget across all attempts: a retry is skipped once the elapsed time plus the next
  /// delay would exceed it (see [withinBudget]).
  final Duration maxElapsed;

  /// Full-jitter exponential backoff for a 0-based [attempt]:
  /// `random(0, min(maxDelay, baseDelay * 2^attempt))`.
  Duration backoff(int attempt, math.Random random) {
    final shift = attempt.clamp(0, 30); // an absurd attempt count must not overflow the shift
    final exponential = baseDelay.inMilliseconds * (1 << shift);
    final capped = math.min(exponential, maxDelay.inMilliseconds);
    return Duration(milliseconds: random.nextInt(capped + 1));
  }

  /// Whether another attempt that sleeps [nextDelay] still fits within [maxElapsed], given the
  /// time already [elapsed]. Server-directed delays are bounded by this budget alone.
  bool withinBudget(Duration elapsed, Duration nextDelay) => elapsed + nextDelay <= maxElapsed;
}
