// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phase_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availablePhasesHash() => r'a1d7cf6c97eb0b09fa56b62469f68bef8175f0c2';

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

/// Provider for available phases based on current devices
///
/// Copied from [availablePhases].
@ProviderFor(availablePhases)
const availablePhasesProvider = AvailablePhasesFamily();

/// Provider for available phases based on current devices
///
/// Copied from [availablePhases].
class AvailablePhasesFamily extends Family<List<String>> {
  /// Provider for available phases based on current devices
  ///
  /// Copied from [availablePhases].
  const AvailablePhasesFamily();

  /// Provider for available phases based on current devices
  ///
  /// Copied from [availablePhases].
  AvailablePhasesProvider call(
    List<Device> devices,
  ) {
    return AvailablePhasesProvider(
      devices,
    );
  }

  @override
  AvailablePhasesProvider getProviderOverride(
    covariant AvailablePhasesProvider provider,
  ) {
    return call(
      provider.devices,
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
  String? get name => r'availablePhasesProvider';
}

/// Provider for available phases based on current devices
///
/// Copied from [availablePhases].
class AvailablePhasesProvider extends AutoDisposeProvider<List<String>> {
  /// Provider for available phases based on current devices
  ///
  /// Copied from [availablePhases].
  AvailablePhasesProvider(
    List<Device> devices,
  ) : this._internal(
          (ref) => availablePhases(
            ref as AvailablePhasesRef,
            devices,
          ),
          from: availablePhasesProvider,
          name: r'availablePhasesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availablePhasesHash,
          dependencies: AvailablePhasesFamily._dependencies,
          allTransitiveDependencies:
              AvailablePhasesFamily._allTransitiveDependencies,
          devices: devices,
        );

  AvailablePhasesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.devices,
  }) : super.internal();

  final List<Device> devices;

  @override
  Override overrideWith(
    List<String> Function(AvailablePhasesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailablePhasesProvider._internal(
        (ref) => create(ref as AvailablePhasesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        devices: devices,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<String>> createElement() {
    return _AvailablePhasesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailablePhasesProvider && other.devices == devices;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, devices.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AvailablePhasesRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `devices` of this provider.
  List<Device> get devices;
}

class _AvailablePhasesProviderElement
    extends AutoDisposeProviderElement<List<String>> with AvailablePhasesRef {
  _AvailablePhasesProviderElement(super.provider);

  @override
  List<Device> get devices => (origin as AvailablePhasesProvider).devices;
}

String _$phaseFilterNotifierHash() =>
    r'32b6ebd1ab208273f09c579a2bc5c21f27b7dc48';

/// Notifier for managing phase filter state with persistence
///
/// Copied from [PhaseFilterNotifier].
@ProviderFor(PhaseFilterNotifier)
final phaseFilterNotifierProvider =
    AutoDisposeNotifierProvider<PhaseFilterNotifier, PhaseFilterState>.internal(
  PhaseFilterNotifier.new,
  name: r'phaseFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$phaseFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhaseFilterNotifier = AutoDisposeNotifier<PhaseFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
