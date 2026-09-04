import 'dart:math' as math;

import 'package:core_model/core_model.dart';
import 'package:test/test.dart';

void main() {
  group('RetryBackoff', () {
    test('full-jitter backoff stays within [0, capped] and respects the ceiling', () {
      const policy = RetryBackoff(baseDelay: Duration(milliseconds: 100), maxDelay: Duration(seconds: 1));
      final random = math.Random(42);

      // Caps per attempt: 100, 200, 400, 800ms, then maxDelay = 1000ms from attempt 4 on.
      for (final (attempt, capMs) in const [(0, 100), (1, 200), (2, 400), (3, 800), (4, 1000), (10, 1000)]) {
        for (var i = 0; i < 50; i++) {
          // `random` is stateful: each call samples a new value, so this cannot be hoisted.
          // ignore: move-variable-outside-iteration
          final d = policy.backoff(attempt, random).inMilliseconds;
          expect(d, inInclusiveRange(0, capMs), reason: 'attempt $attempt must be in [0,$capMs]');
        }
      }
    });

    test('backoff is deterministic for a seeded Random', () {
      const policy = RetryBackoff(baseDelay: Duration(milliseconds: 100), maxDelay: Duration(seconds: 10));
      final a = List.generate(5, (i) => policy.backoff(i, math.Random(7)).inMilliseconds);
      final b = List.generate(5, (i) => policy.backoff(i, math.Random(7)).inMilliseconds);
      expect(a, equals(b));
    });

    test('withinBudget caps the total elapsed time across attempts', () {
      const policy = RetryBackoff(maxElapsed: Duration(seconds: 10));
      expect(policy.withinBudget(const Duration(seconds: 3), const Duration(seconds: 5)), isTrue);
      expect(policy.withinBudget(const Duration(seconds: 8), const Duration(seconds: 5)), isFalse);
      expect(policy.withinBudget(const Duration(seconds: 10), .zero), isTrue);
    });
  });
}
