// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_registration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceRegistrationServiceHash() =>
    r'de38667c5f4a7de42fc89396c891e225915dbca6';

/// Provider for the device registration service.
///
/// Copied from [deviceRegistrationService].
@ProviderFor(deviceRegistrationService)
final deviceRegistrationServiceProvider =
    AutoDisposeProvider<DeviceRegistrationService>.internal(
  deviceRegistrationService,
  name: r'deviceRegistrationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceRegistrationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceRegistrationServiceRef
    = AutoDisposeProviderRef<DeviceRegistrationService>;
String _$deviceWebSocketEventsHash() =>
    r'1ddea4e6bc1c431ac9dfa0445dec376aeb629910';

/// Stream provider for device registration events from WebSocket.
///
/// Copied from [deviceWebSocketEvents].
@ProviderFor(deviceWebSocketEvents)
final deviceWebSocketEventsProvider =
    AutoDisposeStreamProvider<SocketMessage>.internal(
  deviceWebSocketEvents,
  name: r'deviceWebSocketEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceWebSocketEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceWebSocketEventsRef = AutoDisposeStreamProviderRef<SocketMessage>;
String _$deviceRegistrationNotifierHash() =>
    r'cbc9ed9509521001157325410f5cd4a3e4417c9a';

/// Provider for device registration with WebSocket integration.
/// Handles checking existing devices and registering new ones.
///
/// Copied from [DeviceRegistrationNotifier].
@ProviderFor(DeviceRegistrationNotifier)
final deviceRegistrationNotifierProvider = NotifierProvider<
    DeviceRegistrationNotifier, DeviceRegistrationState>.internal(
  DeviceRegistrationNotifier.new,
  name: r'deviceRegistrationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceRegistrationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceRegistrationNotifier = Notifier<DeviceRegistrationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
