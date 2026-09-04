// Each `acquire()` mutates the lease and returns a new term, so the repeated calls are the
// point rather than a duplicated initializer.
// ignore_for_file: avoid-duplicate-initializers
// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:core_model/core_model.dart';

Future<void> main() async {
  // Lease: whoever acquired last owns the resource; stale owners' deferred work becomes a no-op.
  final lease = Lease();
  final first = lease.acquire();
  final second = lease.acquire();
  lease
    ..guard(first, () => print('never runs: the first term is over'))
    ..guard(second, () => print('runs: the second term is current'));

  // CancelToken: cooperative cancellation, with children that follow their parent.
  final parent = CancelToken();
  final child = CancelToken();
  parent.link(child);
  unawaited(child.whenCancel.then((_) => print('child cancelled: ${child.isCancelled}')));
  parent.cancel('user left the screen');
  await Future<void>.delayed(.zero);

  // RetryBackoff: exponential backoff with full jitter, bounded per attempt and in total.
  const policy = RetryBackoff(maxRetries: 3, baseDelay: Duration(milliseconds: 200));
  final random = Random(1);
  var elapsed = Duration.zero;
  for (var attempt = 0; attempt <= policy.maxRetries; attempt++) {
    final delay = policy.backoff(attempt, random);
    if (!policy.withinBudget(elapsed, delay)) break;
    elapsed += delay;
    print('attempt $attempt after ${delay.inMilliseconds} ms');
  }
}
