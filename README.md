# core_model

[![CI](https://github.com/zs-dima/core_model/actions/workflows/ci.yml/badge.svg)](https://github.com/zs-dima/core_model/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

Primitives a Dart application keeps re-deriving, extracted once and tested. No Flutter dependency:
it runs under `dart test`, in an isolate, or in a CLI.

## `Lease`: monotonic ownership over a shared resource

One lease guards one resource scope: a hardware session, a storage key, a composition of
dependencies. An owner calls `acquire()` and keeps the handle; a new term invalidates every handle
issued before it, so a stale owner's deferred work (a queued release, a late callback, a retry)
becomes a no-op instead of tearing down the current owner's state.

```dart
final lease = Lease();

final handle = lease.acquire();
// ... later, on a path that may have been superseded:
lease.guard(handle, () => transport.close());
```

It is not a mutex: it serializes nothing, it decides whose completed work still counts.

## `CancelToken`: cooperative cancellation

A token an operation checks, and a caller cancels. No timers, no zones, no `Future` wrapping.

## `RetryBackoff`: exponential backoff with jitter

The retry schedule as a function, so a client's retry policy is a value that can be tested rather
than a loop that has to be read.

## `Clock`: the current instant as a dependency

Time an application records or acts on — an expiry, a scheduled reminder, the date a record is filed
under — reached through an injected clock rather than a static call, so a caller can be handed one
that reports an instant the calendar has not. `SystemClock` is the real one, and it reads UTC.

```dart
final class Entitlement {
  const Entitlement(this._clock);
  final Clock _clock;

  bool get expired => _expiresAt.isBefore(_clock.now());
}

// production
const Entitlement(SystemClock());
```

Presentation timing does not belong here: a tap window or a "2 h ago" label is about the frame in
front of the user, not a fact being recorded.

## `DiTimings`: what each start-up step cost

A diagnostics side-channel for a staged initialization, held statically and deliberately outside the
container it measures the building of — whatever reports these timings has to work when
initialization failed, and then there is no container left to read them from.

```dart
DiTimings.reset(); // a retry must not append to the attempt that failed
for (final step in steps) {
  final watch = Stopwatch()..start();
  await step.run();
  DiTimings.record(step.name, watch.elapsed);
}
// afterwards, including after a failure:
DiTimings.steps; // List<({String name, Duration duration})>, in order
DiTimings.total;
```

## Also here

`Guid`, a UUID as a string with `GuidX.nil` and `GuidX.empty`; `IDeviceInfo`, the interface an
application implements to describe the device and build it runs on; a platform-neutral
`VoidCallback` typedef, so a package that uses it stays free of `dart:ui`; and `RetryNotifier`, the
callback a retrying middleware reports each attempt through.

## Install

```yaml
dependencies:
  core_model: ^0.1.1
```

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

[MIT](LICENSE)
