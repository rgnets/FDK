// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stageTimestampTrackerHash() =>
    r'd150efc7596b298d253cca6c42a28b00ea39522e';

/// Provider for StageTimestampTracker service
///
/// Copied from [stageTimestampTracker].
@ProviderFor(stageTimestampTracker)
final stageTimestampTrackerProvider = Provider<StageTimestampTracker>.internal(
  stageTimestampTracker,
  name: r'stageTimestampTrackerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stageTimestampTrackerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StageTimestampTrackerRef = ProviderRef<StageTimestampTracker>;
String _$messageResolverHash() => r'245ff6cf373fdcfafbb803e27d51c1746a3194d3';

/// Provider for MessageResolver
///
/// Copied from [messageResolver].
@ProviderFor(messageResolver)
final messageResolverProvider = AutoDisposeProvider<MessageResolver>.internal(
  messageResolver,
  name: r'messageResolverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageResolverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MessageResolverRef = AutoDisposeProviderRef<MessageResolver>;
String _$deviceOnboardingStateHash() =>
    r'78fa397037352d508c551bff635a9650bdc6ca6b';

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

/// Provider for a single device's onboarding state.
/// Falls back to WebSocket cache if not in notifier state.
///
/// Copied from [deviceOnboardingState].
@ProviderFor(deviceOnboardingState)
const deviceOnboardingStateProvider = DeviceOnboardingStateFamily();

/// Provider for a single device's onboarding state.
/// Falls back to WebSocket cache if not in notifier state.
///
/// Copied from [deviceOnboardingState].
class DeviceOnboardingStateFamily extends Family<OnboardingState?> {
  /// Provider for a single device's onboarding state.
  /// Falls back to WebSocket cache if not in notifier state.
  ///
  /// Copied from [deviceOnboardingState].
  const DeviceOnboardingStateFamily();

  /// Provider for a single device's onboarding state.
  /// Falls back to WebSocket cache if not in notifier state.
  ///
  /// Copied from [deviceOnboardingState].
  DeviceOnboardingStateProvider call(
    String deviceId,
  ) {
    return DeviceOnboardingStateProvider(
      deviceId,
    );
  }

  @override
  DeviceOnboardingStateProvider getProviderOverride(
    covariant DeviceOnboardingStateProvider provider,
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
  String? get name => r'deviceOnboardingStateProvider';
}

/// Provider for a single device's onboarding state.
/// Falls back to WebSocket cache if not in notifier state.
///
/// Copied from [deviceOnboardingState].
class DeviceOnboardingStateProvider
    extends AutoDisposeProvider<OnboardingState?> {
  /// Provider for a single device's onboarding state.
  /// Falls back to WebSocket cache if not in notifier state.
  ///
  /// Copied from [deviceOnboardingState].
  DeviceOnboardingStateProvider(
    String deviceId,
  ) : this._internal(
          (ref) => deviceOnboardingState(
            ref as DeviceOnboardingStateRef,
            deviceId,
          ),
          from: deviceOnboardingStateProvider,
          name: r'deviceOnboardingStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deviceOnboardingStateHash,
          dependencies: DeviceOnboardingStateFamily._dependencies,
          allTransitiveDependencies:
              DeviceOnboardingStateFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  DeviceOnboardingStateProvider._internal(
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
  Override overrideWith(
    OnboardingState? Function(DeviceOnboardingStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeviceOnboardingStateProvider._internal(
        (ref) => create(ref as DeviceOnboardingStateRef),
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
  AutoDisposeProviderElement<OnboardingState?> createElement() {
    return _DeviceOnboardingStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceOnboardingStateProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeviceOnboardingStateRef on AutoDisposeProviderRef<OnboardingState?> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _DeviceOnboardingStateProviderElement
    extends AutoDisposeProviderElement<OnboardingState?>
    with DeviceOnboardingStateRef {
  _DeviceOnboardingStateProviderElement(super.provider);

  @override
  String get deviceId => (origin as DeviceOnboardingStateProvider).deviceId;
}

String _$hasOnboardingDataHash() => r'e51ba46666a90b52d1e5b514dc1a812e18a4c7c6';

/// Provider to check if a device has onboarding data
///
/// Copied from [hasOnboardingData].
@ProviderFor(hasOnboardingData)
const hasOnboardingDataProvider = HasOnboardingDataFamily();

/// Provider to check if a device has onboarding data
///
/// Copied from [hasOnboardingData].
class HasOnboardingDataFamily extends Family<bool> {
  /// Provider to check if a device has onboarding data
  ///
  /// Copied from [hasOnboardingData].
  const HasOnboardingDataFamily();

  /// Provider to check if a device has onboarding data
  ///
  /// Copied from [hasOnboardingData].
  HasOnboardingDataProvider call(
    String deviceId,
  ) {
    return HasOnboardingDataProvider(
      deviceId,
    );
  }

  @override
  HasOnboardingDataProvider getProviderOverride(
    covariant HasOnboardingDataProvider provider,
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
  String? get name => r'hasOnboardingDataProvider';
}

/// Provider to check if a device has onboarding data
///
/// Copied from [hasOnboardingData].
class HasOnboardingDataProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a device has onboarding data
  ///
  /// Copied from [hasOnboardingData].
  HasOnboardingDataProvider(
    String deviceId,
  ) : this._internal(
          (ref) => hasOnboardingData(
            ref as HasOnboardingDataRef,
            deviceId,
          ),
          from: hasOnboardingDataProvider,
          name: r'hasOnboardingDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasOnboardingDataHash,
          dependencies: HasOnboardingDataFamily._dependencies,
          allTransitiveDependencies:
              HasOnboardingDataFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  HasOnboardingDataProvider._internal(
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
  Override overrideWith(
    bool Function(HasOnboardingDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasOnboardingDataProvider._internal(
        (ref) => create(ref as HasOnboardingDataRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _HasOnboardingDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasOnboardingDataProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HasOnboardingDataRef on AutoDisposeProviderRef<bool> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _HasOnboardingDataProviderElement extends AutoDisposeProviderElement<bool>
    with HasOnboardingDataRef {
  _HasOnboardingDataProviderElement(super.provider);

  @override
  String get deviceId => (origin as HasOnboardingDataProvider).deviceId;
}

String _$isOnboardingCompleteHash() =>
    r'a44d61f4c67f34b2fd29233300f29dca665db644';

/// Provider to check if a device's onboarding is complete
///
/// Copied from [isOnboardingComplete].
@ProviderFor(isOnboardingComplete)
const isOnboardingCompleteProvider = IsOnboardingCompleteFamily();

/// Provider to check if a device's onboarding is complete
///
/// Copied from [isOnboardingComplete].
class IsOnboardingCompleteFamily extends Family<bool> {
  /// Provider to check if a device's onboarding is complete
  ///
  /// Copied from [isOnboardingComplete].
  const IsOnboardingCompleteFamily();

  /// Provider to check if a device's onboarding is complete
  ///
  /// Copied from [isOnboardingComplete].
  IsOnboardingCompleteProvider call(
    String deviceId,
  ) {
    return IsOnboardingCompleteProvider(
      deviceId,
    );
  }

  @override
  IsOnboardingCompleteProvider getProviderOverride(
    covariant IsOnboardingCompleteProvider provider,
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
  String? get name => r'isOnboardingCompleteProvider';
}

/// Provider to check if a device's onboarding is complete
///
/// Copied from [isOnboardingComplete].
class IsOnboardingCompleteProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a device's onboarding is complete
  ///
  /// Copied from [isOnboardingComplete].
  IsOnboardingCompleteProvider(
    String deviceId,
  ) : this._internal(
          (ref) => isOnboardingComplete(
            ref as IsOnboardingCompleteRef,
            deviceId,
          ),
          from: isOnboardingCompleteProvider,
          name: r'isOnboardingCompleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isOnboardingCompleteHash,
          dependencies: IsOnboardingCompleteFamily._dependencies,
          allTransitiveDependencies:
              IsOnboardingCompleteFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  IsOnboardingCompleteProvider._internal(
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
  Override overrideWith(
    bool Function(IsOnboardingCompleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsOnboardingCompleteProvider._internal(
        (ref) => create(ref as IsOnboardingCompleteRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsOnboardingCompleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsOnboardingCompleteProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsOnboardingCompleteRef on AutoDisposeProviderRef<bool> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _IsOnboardingCompleteProviderElement
    extends AutoDisposeProviderElement<bool> with IsOnboardingCompleteRef {
  _IsOnboardingCompleteProviderElement(super.provider);

  @override
  String get deviceId => (origin as IsOnboardingCompleteProvider).deviceId;
}

String _$isOnboardingOverdueHash() =>
    r'2600ee6c867ca99cf3f0c232c1e4bbef03b23dc5';

/// Provider to check if a device's onboarding is overdue
///
/// Copied from [isOnboardingOverdue].
@ProviderFor(isOnboardingOverdue)
const isOnboardingOverdueProvider = IsOnboardingOverdueFamily();

/// Provider to check if a device's onboarding is overdue
///
/// Copied from [isOnboardingOverdue].
class IsOnboardingOverdueFamily extends Family<bool> {
  /// Provider to check if a device's onboarding is overdue
  ///
  /// Copied from [isOnboardingOverdue].
  const IsOnboardingOverdueFamily();

  /// Provider to check if a device's onboarding is overdue
  ///
  /// Copied from [isOnboardingOverdue].
  IsOnboardingOverdueProvider call(
    String deviceId,
  ) {
    return IsOnboardingOverdueProvider(
      deviceId,
    );
  }

  @override
  IsOnboardingOverdueProvider getProviderOverride(
    covariant IsOnboardingOverdueProvider provider,
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
  String? get name => r'isOnboardingOverdueProvider';
}

/// Provider to check if a device's onboarding is overdue
///
/// Copied from [isOnboardingOverdue].
class IsOnboardingOverdueProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a device's onboarding is overdue
  ///
  /// Copied from [isOnboardingOverdue].
  IsOnboardingOverdueProvider(
    String deviceId,
  ) : this._internal(
          (ref) => isOnboardingOverdue(
            ref as IsOnboardingOverdueRef,
            deviceId,
          ),
          from: isOnboardingOverdueProvider,
          name: r'isOnboardingOverdueProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isOnboardingOverdueHash,
          dependencies: IsOnboardingOverdueFamily._dependencies,
          allTransitiveDependencies:
              IsOnboardingOverdueFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  IsOnboardingOverdueProvider._internal(
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
  Override overrideWith(
    bool Function(IsOnboardingOverdueRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsOnboardingOverdueProvider._internal(
        (ref) => create(ref as IsOnboardingOverdueRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsOnboardingOverdueProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsOnboardingOverdueProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsOnboardingOverdueRef on AutoDisposeProviderRef<bool> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _IsOnboardingOverdueProviderElement
    extends AutoDisposeProviderElement<bool> with IsOnboardingOverdueRef {
  _IsOnboardingOverdueProviderElement(super.provider);

  @override
  String get deviceId => (origin as IsOnboardingOverdueProvider).deviceId;
}

String _$deviceOnboardingNotifierHash() =>
    r'fd552dca8ca1f115f474c7dea6c529b519b84922';

/// Main provider for device onboarding state.
/// Transforms DeviceModelSealed into OnboardingState with timing information.
///
/// Copied from [DeviceOnboardingNotifier].
@ProviderFor(DeviceOnboardingNotifier)
final deviceOnboardingNotifierProvider = NotifierProvider<
    DeviceOnboardingNotifier, Map<String, OnboardingState>>.internal(
  DeviceOnboardingNotifier.new,
  name: r'deviceOnboardingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceOnboardingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceOnboardingNotifier = Notifier<Map<String, OnboardingState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
