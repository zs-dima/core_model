import 'package:core_model/core_model.dart';
import 'package:test/test.dart';

void main() {
  group('DiTimings', () {
    setUp(DiTimings.reset);

    test('a recorded step keeps its name and duration, in the order it was recorded', () {
      DiTimings.record('Open the database', const Duration(milliseconds: 40));
      DiTimings.record('Read the settings', const Duration(milliseconds: 12));

      expect(
        DiTimings.steps.map((step) => step.name),
        orderedEquals(<String>['Open the database', 'Read the settings']),
      );
      expect(DiTimings.steps.first.duration, equals(const Duration(milliseconds: 40)));
    });

    test('total is every step added up', () {
      DiTimings.record('one', const Duration(milliseconds: 40));
      DiTimings.record('two', const Duration(milliseconds: 12));

      expect(DiTimings.total, equals(const Duration(milliseconds: 52)));
    });

    test('nothing recorded is a zero total, not a failure', () {
      expect(DiTimings.steps, isEmpty);
      expect(DiTimings.total, equals(Duration.zero));
    });

    test('reset starts a fresh run rather than appending to the attempt that failed', () {
      DiTimings.record('the attempt that threw', const Duration(milliseconds: 90));
      DiTimings.reset();
      DiTimings.record('the attempt that worked', const Duration(milliseconds: 10));

      expect(DiTimings.steps, hasLength(1));
      expect(DiTimings.steps.single.name, equals('the attempt that worked'));
    });

    test('the list handed out cannot be written through', () {
      DiTimings.record('one', const Duration(milliseconds: 1));

      expect(
        // Mutating the snapshot is the call under test; it has to throw.
        // ignore: avoid-collection-mutating-methods
        () => DiTimings.steps.add(const (name: 'forged', duration: Duration.zero)),
        throwsUnsupportedError,
        reason: 'steps is a snapshot; recording goes through record',
      );
    });
  });
}
