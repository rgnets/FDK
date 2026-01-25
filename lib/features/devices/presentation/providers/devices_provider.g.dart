// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredDevicesHash() => r'62d57a55d5bd884c5d2fbca5166b2bf52d255e2f';

/// See also [filteredDevices].
@ProviderFor(filteredDevices)
final filteredDevicesProvider = Provider<List<Device>>.internal(
  filteredDevices,
  name: r'filteredDevicesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredDevicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredDevicesRef = ProviderRef<List<Device>>;
String _$devicesNotifierHash() => r'b04f3d264b41ab17dfd141c9b1b21d9e9f294a64';

/// See also [DevicesNotifier].
@ProviderFor(DevicesNotifier)
final devicesNotifierProvider =
    AsyncNotifierProvider<DevicesNotifier, List<Device>>.internal(
  DevicesNotifier.new,
  name: r'devicesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$devicesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DevicesNotifier = AsyncNotifier<List<Device>>;
String _$deviceNotifierHash() => r'fcf9f8864643aac3eaa605fc14f64f65fd369e66';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$DeviceNotifier extends BuildlessAsyncNotifier<Device?> {
  late final String deviceId;

  FutureOr<Device?> build(
    String deviceId,
  );
}

/// See also [DeviceNotifier].
@ProviderFor(DeviceNotifier)
const deviceNotifierProvider = DeviceNotifierFamily();

/// See also [DeviceNotifier].
class DeviceNotifierFamily extends Family<AsyncValue<Device?>> {
  /// See also [DeviceNotifier].
  const DeviceNotifierFamily();

  /// See also [DeviceNotifier].
  DeviceNotifierProvider call(
    String deviceId,
  ) {
    return DeviceNotifierProvider(
      deviceId,
    );
  }

  @override
  DeviceNotifierProvider getProviderOverride(
    covariant DeviceNotifierProvider provider,
  ) {
    return call(
      provider.deviceId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deviceNotifierProvider';
}

/// See also [DeviceNotifier].
class DeviceNotifierProvider
    extends AsyncNotifierProviderImpl<DeviceNotifier, Device?> {
  /// See also [DeviceNotifier].
  DeviceNotifierProvider(
    String deviceId,
  ) : this._internal(
          () => DeviceNotifier()..deviceId = deviceId,
          from: deviceNotifierProvider,
          name: r'deviceNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deviceNotifierHash,
          dependencies: DeviceNotifierFamily._dependencies,
          allTransitiveDependencies:
              DeviceNotifierFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  DeviceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
  }) : super.internal();

  final String deviceId;

  @override
  FutureOr<Device?> runNotifierBuild(
    covariant DeviceNotifier notifier,
  ) {
    return notifier.build(
      deviceId,
    );
  }

  @override
  Override overrideWith(DeviceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeviceNotifierProvider._internal(
        () => create()..deviceId = deviceId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<DeviceNotifier, Device?> createElement() {
    return _DeviceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceNotifierProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeviceNotifierRef on AsyncNotifierProviderRef<Device?> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _DeviceNotifierProviderElement
    extends AsyncNotifierProviderElement<DeviceNotifier, Device?>
    with DeviceNotifierRef {
  _DeviceNotifierProviderElement(super.provider);

  @override
  String get deviceId => (origin as DeviceNotifierProvider).deviceId;
}

String _$deviceSearchNotifierHash() =>
    r'c160a0e8a8ab0f1cb2282d84141ac5826b4ede3a';

abstract class _$DeviceSearchNotifier
    extends BuildlessAsyncNotifier<List<Device>> {
  late final String query;

  FutureOr<List<Device>> build(
    String query,
  );
}

/// See also [DeviceSearchNotifier].
@ProviderFor(DeviceSearchNotifier)
const deviceSearchNotifierProvider = DeviceSearchNotifierFamily();

/// See also [DeviceSearchNotifier].
class DeviceSearchNotifierFamily extends Family<AsyncValue<List<Device>>> {
  /// See also [DeviceSearchNotifier].
  const DeviceSearchNotifierFamily();

  /// See also [DeviceSearchNotifier].
  DeviceSearchNotifierProvider call(
    String query,
  ) {
    return DeviceSearchNotifierProvider(
      query,
    );
  }

  @override
  DeviceSearchNotifierProvider getProviderOverride(
    covariant DeviceSearchNotifierProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deviceSearchNotifierProvider';
}

/// See also [DeviceSearchNotifier].
class DeviceSearchNotifierProvider
    extends AsyncNotifierProviderImpl<DeviceSearchNotifier, List<Device>> {
  /// See also [DeviceSearchNotifier].
  DeviceSearchNotifierProvider(
    String query,
  ) : this._internal(
          () => DeviceSearchNotifier()..query = query,
          from: deviceSearchNotifierProvider,
          name: r'deviceSearchNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deviceSearchNotifierHash,
          dependencies: DeviceSearchNotifierFamily._dependencies,
          allTransitiveDependencies:
              DeviceSearchNotifierFamily._allTransitiveDependencies,
          query: query,
        );

  DeviceSearchNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<Device>> runNotifierBuild(
    covariant DeviceSearchNotifier notifier,
  ) {
    return notifier.build(
      query,
    );
  }

  @override
  Override overrideWith(DeviceSearchNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeviceSearchNotifierProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<DeviceSearchNotifier, List<Device>>
      createElement() {
    return _DeviceSearchNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceSearchNotifierProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeviceSearchNotifierRef on AsyncNotifierProviderRef<List<Device>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _DeviceSearchNotifierProviderElement
    extends AsyncNotifierProviderElement<DeviceSearchNotifier, List<Device>>
    with DeviceSearchNotifierRef {
  _DeviceSearchNotifierProviderElement(super.provider);

  @override
  String get query => (origin as DeviceSearchNotifierProvider).query;
}

String _$deviceFilterStateHash() => r'82ae11f3a618bf89741881672d83c3c5b570490c';

/// See also [DeviceFilterState].
@ProviderFor(DeviceFilterState)
final deviceFilterStateProvider =
    NotifierProvider<DeviceFilterState, DeviceFilters>.internal(
  DeviceFilterState.new,
  name: r'deviceFilterStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceFilterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceFilterState = Notifier<DeviceFilters>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
