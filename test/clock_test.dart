import 'package:core_model/core_model.dart';
import 'package:test/test.dart';

void main() {
  group('SystemClock', () {
    const clock = SystemClock();

    test('reads UTC, not the host zone', () {
      // Returning local time reads correctly on a developer's machine and shifts every stored
      // instant by the tester's offset.
      expect(clock.now().isUtc, isTrue);
    });

    test('advances between readings', () async {
      final first = clock.now();
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // The second reading is a second reading, not a repeat of the first: that is the assertion.
      // ignore: use-existing-variable
      expect(clock.now().isAfter(first), isTrue);
    });

    test('is const, so a composition holds one without allocating', () {
      // Two identical const expressions is what canonicalization is being checked on.
      // ignore: no-equal-arguments
      expect(identical(const SystemClock(), const SystemClock()), isTrue);
    });
  });
}
