# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-09-20

### Added

- `Clock` and `SystemClock`: the current instant as an injected dependency, so a caller can be handed
  a clock that reports a time the system clock has not reached. `SystemClock` is the only
  `DateTime.now()` behind the interface.
- `DiTimings` and `DiStepTiming`: how long each step of a staged initialization took, recorded in
  order and readable after the run, including after it failed. `DiStepTiming` is a typedef over
  `({String name, Duration duration})`, so a caller that already speaks in records needs no
  conversion.
- A library doc on `core_model.dart`, which is the package's dartdoc landing page.

### Changed

- Dart SDK constraint raised to `^3.13.4`.
- Formatter settings dropped from `analysis_options.yaml`; `lints_tool` 1.1.1 supplies them.
- `README.md` and the package description cover the whole surface, and `README.md` installs from
  pub.dev rather than by git ref.

## [0.1.0] - 2026-09-04

### Added

- First released version: `Lease`, `CancelToken`, `RetryBackoff` and `RetryNotifier` with their tests; `Guid`,
  `IDeviceInfo` and a platform-neutral `VoidCallback`.

### Changed

- Versioned `0.1.0`: the API is young and may still move. The build number a Flutter template
  writes means nothing on a library and is gone.
