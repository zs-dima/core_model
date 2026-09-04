/// Monotonic ownership lease over a shared resource.
///
/// One [Lease] guards one resource scope: a hardware session, a storage key, a composition of
/// dependencies. Each owner calls [acquire] and keeps the returned handle; a new term invalidates
/// every handle issued before it, so a stale owner's deferred work (a queued release, a late
/// callback, a retry) becomes a no-op instead of overwriting the current owner's state.
///
/// Compare-before-commit against the epoch: hold a handle, check it, then act. Not a mutex: it
/// serializes nothing, it decides whose completed work still counts.
///
/// Single-isolate semantics: reads and writes are not synchronized across isolates.
class Lease {
  int _current = 0;

  /// The current term, for logging and diagnostics; comparisons belong in [isCurrent].
  int get current => _current;

  /// Starts a new ownership term and returns its handle, invalidating every handle issued before
  /// it. Call when the new owner takes the resource (connect, initialize).
  int acquire() => ++_current;

  /// Whether [handle] still owns the resource: no [acquire] happened since it was issued.
  bool isCurrent(int handle) => handle == _current;

  /// Runs [action] only if [handle] is still the current term; otherwise does nothing and returns
  /// `null`. The guard for deferred teardown and commit paths:
  ///
  /// ```dart
  /// final handle = lease.acquire();
  /// await work();
  /// lease.guard(handle, () => resource.release()); // no-op if ownership moved on
  /// ```
  T? guard<T>(int handle, T Function() action) => isCurrent(handle) ? action() : null;
}
