# core_model

[![CI](https://github.com/zs-dima/core_model/actions/workflows/ci.yml/badge.svg)](https://github.com/zs-dima/core_model/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

Three primitives that a Dart application keeps re-deriving, extracted once and tested. No Flutter
dependency: it runs under `dart test`, in an isolate, or in a CLI.

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

## `retryBackoff`: exponential backoff with jitter

The retry schedule as a function, so a client's retry policy is a value that can be tested rather
than a loop that has to be read.

## Also here

`Guid`, a UUID as a string with `GuidX.nil` and `GuidX.empty`; `IDeviceInfo`, the interface an
application implements to describe the device and build it runs on; and a platform-neutral
`VoidCallback` typedef, so a package that uses it stays free of `dart:ui`; `RetryNotifier`, the callback a
retrying middleware reports each attempt through.

## Install

```yaml
dependencies:
  core_model:
    git:
      url: https://github.com/zs-dima/core_model.git
      ref: v0.1.0
```

## Changelog

[CHANGELOG.md](CHANGELOG.md)

## License

[MIT](LICENSE)
