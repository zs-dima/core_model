// Each `acquire()` mutates the lease and returns a new term, so the repeated calls are the
// point rather than a duplicated initializer.
// ignore_for_file: avoid-duplicate-initializers
import 'package:core_model/core_model.dart';
import 'package:test/test.dart';

void main() {
  group('Lease', () {
    test('acquire issues monotonically increasing handles', () {
      final lease = Lease();
      final first = lease.acquire();
      final second = lease.acquire();
      expect(second, greaterThan(first));
      expect(lease.current, equals(second));
    });

    test('only the latest handle is current', () {
      final lease = Lease();
      final first = lease.acquire();
      expect(lease.isCurrent(first), isTrue);
      final second = lease.acquire();
      expect(lease.isCurrent(first), isFalse, reason: 'a new term invalidates every earlier handle');
      expect(lease.isCurrent(second), isTrue);
    });

    test('guard runs the action for the current handle and returns its result', () {
      final lease = Lease();
      final h = lease.acquire();
      var ran = false;
      final result = lease.guard(h, () {
        ran = true;
        return 42;
      });
      expect(ran, isTrue);
      expect(result, equals(42));
    });

    test('stale-release is a no-op: guard skips the action and returns null', () {
      // A previous owner's deferred teardown must not tear down the current owner's resource.
      final lease = Lease();
      final stale = lease.acquire();
      lease.acquire(); // ownership moved on
      var ran = false;
      final result = lease.guard(stale, () {
        ran = true;
        return 42;
      });
      expect(ran, isFalse);
      expect(result, isNull);
    });

    test('a handle from before any acquire is never current', () {
      final lease = Lease();
      expect(lease.isCurrent(0), isTrue, reason: 'term 0 is the un-acquired state itself');
      lease.acquire();
      expect(lease.isCurrent(0), isFalse);
    });
  });
}
