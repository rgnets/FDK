// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_ui_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredDevicesListHash() =>
    r'4281ae562a29a7253fa243e72890133263aecd05';

/// Provider for filtered devices based on UI state
///
/// Copied from [filteredDevicesList].
@ProviderFor(filteredDevicesList)
final filteredDevicesListProvider = AutoDisposeProvider<List<Device>>.internal(
  filteredDevicesList,
  name: r'filteredDevicesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredDevicesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredDevicesListRef = AutoDisposeProviderRef<List<Device>>;
String _$uniquePhasesHash() => r'144138e9c0ad060659748f69495033f56f430cb8';

/// Provider for unique phases from all devices
///
/// Copied from [uniquePhases].
@ProviderFor(uniquePhases)
final uniquePhasesProvider = AutoDisposeProvider<List<String>>.internal(
  uniquePhases,
  name: r'uniquePhasesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$uniquePhasesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UniquePhasesRef = AutoDisposeProviderRef<List<String>>;
String _$deviceStatisticsHash() => r'fa3514a939b5a66326e608b66302c1bbf1085133';

/// Provider for device statistics
///
/// Copied from [deviceStatistics].
@ProviderFor(deviceStatistics)
final deviceStatisticsProvider = AutoDisposeProvider<DeviceStatistics>.internal(
  deviceStatistics,
  name: r'deviceStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceStatisticsRef = AutoDisposeProviderRef<DeviceStatistics>;
String _$mockDataStateHash() => r'86cca53ca6efcb1aa9017042d6e92b30c5dbd855';

/// Provider to check if using mock data and error messages
///
/// Copied from [mockDataState].
@ProviderFor(mockDataState)
final mockDataStateProvider = AutoDisposeProvider<MockDataState>.internal(
  mockDataState,
  name: r'mockDataStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mockDataStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MockDataStateRef = AutoDisposeProviderRef<MockDataState>;
String _$deviceUIStateNotifierHash() =>
    r'cb2d326246c40052c56a5fe4a9bbac124ef6f4ba';

/// Provider for device UI state (search, filters, etc.)
///
/// Copied from [DeviceUIStateNotifier].
@ProviderFor(DeviceUIStateNotifier)
final deviceUIStateNotifierProvider =
    AutoDisposeNotifierProvider<DeviceUIStateNotifier, DeviceUIState>.internal(
  DeviceUIStateNotifier.new,
  name: r'deviceUIStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceUIStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceUIStateNotifier = AutoDisposeNotifier<DeviceUIState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
