/// What an application knows about the device and build it runs on.
abstract interface class IDeviceInfo {
  /// A stable per-installation identifier.
  String get installationId;

  /// The device's user-facing name.
  String get deviceName;

  /// The device model.
  String get deviceModel;

  /// The device identifier the platform exposes.
  String get deviceId;

  /// The operating system.
  String get deviceOs;

  /// The operating system version.
  String get deviceOsVersion;

  /// The application version.
  String get appVersion;
}
