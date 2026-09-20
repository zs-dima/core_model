/// One step of a staged initialization and how long it took: the step's label and the wall-clock
/// time it ran for.
typedef DiStepTiming = ({String name, Duration duration});

/// Records how long each step of a staged initialization took, in the order the steps ran.
///
/// A diagnostics side-channel held statically, and deliberately outside the dependency container it
/// measures the building of: whatever reports these timings has to work when initialization failed,
/// and in that case there is no container left to read them from.
///
/// One recorder per isolate, with no synchronization across isolates: a second caller recording into
/// it shares the same run, and [reset] discards that run for everyone.
abstract final class DiTimings {
  /// Total time across all recorded steps.
  static Duration get total => _steps.fold(Duration.zero, (sum, step) => sum + step.duration);

  static final List<DiStepTiming> _steps = <DiStepTiming>[];

  /// The steps of the most recent run, in the order they were recorded.
  static List<DiStepTiming> get steps => List<DiStepTiming>.unmodifiableOf(_steps);

  /// Discards the previous run. Call at the start of every initialization, so a retry does not
  /// append to the attempt that failed.
  static void reset() => _steps.clear();

  /// Appends a completed step.
  static void record(String name, Duration duration) => _steps.add((name: name, duration: duration));
}
